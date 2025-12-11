//
//  LayerPolygon.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface LayerPolygon () {
    CGRect _boundingBox;
    NSMutableArray<Vector*>* _vectorArray;
    NSNumberFormatter* formatter;
}

@property (nonatomic, retain) GLKTextureInfo* texture;
@property (nonatomic, retain) NSArray* drawObjectList;

@end

@implementation LayerPolygon

- (CGRect)boundingBox {
    return _boundingBox;
}

- (NSArray<Vector*>*)vectorArray {
    return _vectorArray;
}

-(id)initWithJsonObject:(NSDictionary *)jsonObject andTexture:(GLKTextureInfo *)texture andInterpolation:(unsigned int)interpolation andExtend:(double)extend {

    self = [super init];
    
    self.texture = texture;

  
    
    NSString* points = [jsonObject objectForKey:@"Points"];
    NSArray<NSString*>* lonLatPointsArray = [points componentsSeparatedByString:@","];
    _vectorArray = [NSMutableArray new];
    for (NSString* lonLatPoints in lonLatPointsArray) {
        NSArray<NSString*>* lonLatPair = [lonLatPoints componentsSeparatedByString:@" "];
        
        double lon = [Layer transformLonFromString:lonLatPair[0]];
        double lat = [Layer transformLatFromString:lonLatPair[1]];
        
        Vector* newVector = [[Vector alloc] initWithX:lon andY:lat];
        if (_vectorArray.count > 0) {
            if ([_vectorArray.lastObject isEqualToVector:newVector]) {
                continue;
            }
        }
        
        [_vectorArray addObject:newVector];
    }

    if ([_vectorArray.firstObject isEqualToVector:_vectorArray.lastObject] == NO) {
        [_vectorArray addObject:_vectorArray.firstObject];
    }

    VectorOrder order = [VectorMath getVectorOrderWithVectorArray:_vectorArray];
    
    if (order == VectorOrderCCW) {
        _vectorArray = [NSMutableArray arrayWithArray:[[_vectorArray reverseObjectEnumerator] allObjects]];
    }
    
    if (interpolation == PointInterpolationInterpolate) {
        NSArray* arr =[Interpolator interpolateWithCoordinateArray:_vectorArray andPointsPerSegment:3 andCurveType:CatmullRomTypeCentripetal];
        _vectorArray = [NSMutableArray arrayWithArray:arr];
    }

    if (extend > 0) {
        NSArray* arr = [PolygonOffsetter extendPolygonWithPointList:_vectorArray andExtend:extend];
        _vectorArray = [NSMutableArray arrayWithArray:arr];
    }


    _boundingBox = CGRectZero;
    BOOL firstIteration = YES;
    NSMutableArray* vertices = [NSMutableArray new];
    for (Vector* v in _vectorArray) {
        CGRect thisRect = CGRectMake(v.x, v.y, 0, 0);
        if (firstIteration) {
            firstIteration = NO;
            _boundingBox = thisRect;
            _extremeLeft = [[Vector alloc] initWithVector:v];
            _extremeTop = [[Vector alloc] initWithVector:v];
            _extremeRight = [[Vector alloc] initWithVector:v];
            _extremeBottom = [[Vector alloc] initWithVector:v];
        } else {
            _boundingBox = CGRectUnion(_boundingBox, thisRect);
            
            if (v.x < _extremeLeft.x) {
                _extremeLeft = [[Vector alloc] initWithVector:v];
            }
            if (v.x > _extremeRight.x) {
                _extremeRight = [[Vector alloc] initWithVector:v];
            }
            if (v.y < _extremeBottom.y) {
                _extremeBottom = [[Vector alloc] initWithVector:v];
            }
            if (v.y > _extremeTop.y) {
                _extremeTop = [[Vector alloc] initWithVector:v];
            }
        }
        [vertices addObject:[NSNumber numberWithDouble:v.x]];
        [vertices addObject:[NSNumber numberWithDouble:v.y]];
        [vertices addObject:[NSNumber numberWithDouble:0]];

    }

    self.drawObjectList = [Triangulator2 triangulate:vertices];
    
    
    double baseU = 0;
    double baseV = 0;
    firstIteration = YES;
    for (TriangulatedDrawObject* drawObject in self.drawObjectList) {
        NSArray* vertexList = drawObject.vertexList;
        
        NSMutableArray* uvList = [NSMutableArray new];
        for (int i = 0 ; i < vertexList.count / 3 ; i++) {
            double u = [[vertexList objectAtIndex:i*3 + 0] doubleValue];
            double v = [[vertexList objectAtIndex:i*3 + 1] doubleValue];
 
            if (firstIteration) {
                baseU = u;
                baseV = v;
                
                firstIteration = NO;
            }
            
            [uvList addObject:[NSNumber numberWithDouble:u - baseU]];
            [uvList addObject:[NSNumber numberWithDouble:v - baseV]];
            
        }
        
        drawObject.uvList = uvList;
        [drawObject allocateRawBuffers];
        
    }
    
    return self;
}

- (void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum {

    [GLHelper prepareTextureToStartDraw:_texture andEffect:effect];
   
    for (TriangulatedDrawObject* element in self.drawObjectList) {
        //if ([frustum isVertexListVisible:element.vertexList])
            [GLHelper drawVertexBuffer:element.vertexBuffer andTexCoordBuffer:element.uvBuffer andMode:element.type andCount:element.numVertices];
    }
    
    [GLHelper disableTextureForEffect:effect];
}

- (BOOL)isInFrustum:(Frustum*)frustum {
    
    BOOL retval = true;
    
    for (TriangulatedDrawObject* element in self.drawObjectList) {
        if (![frustum isVertexListVisible: element.vertexList]) {
            retval = false;
            break;
        }
    }
    
    return retval;
}

- (void)destroy {
    for (TriangulatedDrawObject* drawObject in self.drawObjectList) {
        [drawObject releaseRawBuffers];
    }
}

@end
