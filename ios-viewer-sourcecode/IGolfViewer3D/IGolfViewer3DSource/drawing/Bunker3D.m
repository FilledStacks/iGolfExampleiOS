//
//  Bunker3D.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Bunker3D.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface Bunker3D() {
    
    GLKTextureInfo* _texture;

    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    GLuint _indexBuffer;
    GLuint _normalBuffer;
    GLuint _numVertices;
    

    LayerPolygon* _border;
    
    ElevationMap* _grid;

    NSArray<TriangulatedDrawObject*>* _bottomObjects;
}

@end

@implementation Bunker3D

-(instancetype)initWithDictionary:(NSDictionary *)dict andElevationMap:(ElevationMap*)grid {

    self = [super init];
    
    if (self != nil) {
        self->_grid = grid;
        
        [self processBunkerDataWithDictionary:dict];
    }
    
    return self;
}

-(void)processBunkerDataWithDictionary:(NSDictionary*)dict {
    
    _border = [[LayerPolygon alloc] initWithJsonObject:dict andTexture:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_bunker_border" ofType:@"png"]] andInterpolation:PointInterpolationInterpolate andExtend:METERS_IN_POINT];
    
    NSMutableArray<Vector*>* vectorList         = [NSMutableArray new];

    NSArray<NSString*>* lonLatPairs             = [[dict objectForKey:@"Points"] componentsSeparatedByString:@","];
    
    
    for (NSString* lonLatPair in lonLatPairs) {
        
        NSArray<NSString*>* pair = [lonLatPair componentsSeparatedByString:@" "];
        
        double longitude = [[pair firstObject] doubleValue];
        double latitude = [[pair lastObject] doubleValue];
     
        double x = [Layer transformLonFromDouble:longitude];
        double y = [Layer transformLatFromDouble:latitude];
        
        Vector* newVector = [[Vector alloc] initWithX:x andY:y];
        
        if (vectorList.count > 0) {
            if ([vectorList.lastObject isEqualToVector:newVector]) {
                continue;
            }
        }
        
        [vectorList addObject:newVector];
    }

    vectorList = [VectorMath vectorList:vectorList withOrder:VectorOrderCCW];
    vectorList = [VectorMath unclosedVectorList:vectorList];
    vectorList = [[Interpolator interpolateWithCoordinateArray:vectorList andPointsPerSegment:3 andCurveType:CatmullRomTypeCentripetal] mutableCopy];
    vectorList = [VectorMath unclosedVectorList:vectorList];
    vectorList = [VectorMath normalizedVectorList:vectorList];
    
    [self createBunkerFormWithVectorList:vectorList];
}


-(void)createBunkerFormWithVectorList:(NSArray<Vector*>*)vectorList {
    
    NSMutableArray<NSMutableArray<Vertex*>*>* form = [NSMutableArray new];
    NSMutableArray<NSMutableArray<Vector*>*>* vectorArrays = [NSMutableArray new];
    NSMutableArray<NSNumber*>* baseAltitudes = [NSMutableArray new];
    
    for (double offset = -1.0; offset <= 1.0; offset += 0.1) {
        
        NSMutableArray<Vector*>* polygon = [VectorMath makeOffset:offset * 0.5 * METERS_IN_POINT forVectorList:vectorList];
        polygon = [VectorMath normalizedVectorList:polygon];
        
        [vectorArrays addObject:[VectorMath vectorList:polygon withOrder:VectorOrderCCW]];
    }
    
    BOOL isFirstIterration = true;
    
    for (int i = (int)vectorArrays.count - 1; i >= 0; i --) {
        
        NSMutableArray<Vertex*>* polygon = [NSMutableArray new];
        
        for (int j = 0; j < [vectorArrays objectAtIndex:i].count; j++) {

            Vector* vector = [[vectorArrays objectAtIndex:i] objectAtIndex:j];

            CLLocation* location = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:vector.y] longitude:[Layer transformToLonWithDouble:vector.x]];
            
            double z;
            
            if (isFirstIterration) {
                double baseAltitude = [_grid getZPositionForLocation:location];
                z = [self getZpositionForLocation:location polygonIndex:((int)vectorArrays.count - 1) - i andBaseAltitude: baseAltitude];
                [baseAltitudes addObject:@(baseAltitude)];
            } else {
                z = [self getZpositionForLocation:location polygonIndex:((int)vectorArrays.count - 1) - i andBaseAltitude:[[baseAltitudes objectAtIndex:j]doubleValue]];
            }
            
            [polygon addObject:[[Vertex alloc] initWithX:vector.x Y:vector.y Z:z]];
        }
        
        if (isFirstIterration) {
            isFirstIterration = false;
        }
        
        [form addObject:polygon];
    }
    
    [self processBunkerForm:form];
}

- (void)processBunkerForm:(NSMutableArray<NSMutableArray<Vertex*>*>*)form {

    BunkerTriangulator* triangulator = [[BunkerTriangulator alloc] initWithBunkerForm:form];
    _bottomObjects  = triangulator.bottomObjects;
    _vertexBuffer   = [GLHelper getBuffer:triangulator.vertexList];
    _uvBuffer       = [GLHelper getBuffer:triangulator.uvList];
    _indexBuffer    = [GLHelper getIndexBuffer:triangulator.indexList];
    _normalBuffer   = [GLHelper getBuffer:triangulator.normalList];
    _numVertices    = (int)triangulator.indexList.count;
    _texture        = [GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource: @"v3d_bunker" ofType:@"png"]];
}

-(double)getZpositionForLocation:(CLLocation*)location polygonIndex:(double)index andBaseAltitude:(double)baseAltitude {

    if (index == 0.0) {
        return [_grid getZPositionForLocation:location];
    } else {
        double diff = baseAltitude - (baseAltitude - 0.6 * METERS_IN_POINT);
        double k = index / 20;
        return baseAltitude - diff * sqrt(k);
    }
}

-(void)destroy {
    
    [GLHelper deleteBuffer:_vertexBuffer];
    [GLHelper deleteBuffer:_indexBuffer];
    [GLHelper deleteBuffer:_normalBuffer];
    [GLHelper deleteBuffer:_uvBuffer];
    
    for (TriangulatedDrawObject* object in _bottomObjects) {
        [object releaseRawBuffers];
    }
}

-(void)dealloc {
    
    [self destroy];
}




-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera*)camera andDepthFunc:(GLenum)depthFunc {

    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(depthFunc);
    
    effect.light0.enabled = GL_TRUE;
    effect.light0.position = _grid.lightPosition;
    effect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1);
    effect.light0.specularColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0);
    effect.light0.ambientColor = GLKVector4Make(0.4, 0.4, 0.4, 1);
    
    effect.lightingType = GLKLightingTypePerPixel;
    
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = _texture.name;
    
    effect.colorMaterialEnabled = GL_TRUE;
    
    [effect prepareToDraw];
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    for (TriangulatedDrawObject* object in _bottomObjects) {
        [GLHelper drawVertexBuffer:object.vertexBuffer andTexCoordBuffer:object.uvBuffer andNormalBuffer:object.normalBuffer andMode:object.type andCount:object.numVertices];
    }
    
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = _texture.name;
    
    [effect prepareToDraw];

    [GLHelper drawVertexBuffer:_vertexBuffer andIndexBuffer:_indexBuffer andTexCoordBuffer:_uvBuffer andNormalBuffer:_normalBuffer andMode:GL_TRIANGLES andCount:_numVertices];
    
    glDisable(GL_DEPTH_TEST);
}

-(LayerPolygon *)border {
    return _border;
}

@end

