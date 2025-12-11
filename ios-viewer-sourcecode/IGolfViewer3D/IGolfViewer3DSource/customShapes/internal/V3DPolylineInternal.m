//
//  V3DPolylineInternal.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DPolylineInternal.h"
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DPolylineInternal() {
    
    NSArray* _drawObjectList;
    CGRect _boundingBox;
    GLKVector4 _color;
}

@end

@implementation V3DPolylineInternal

-(id)initWithLine:(V3DPolyline *)line {
    
    self = [super init];
    
    if (self != nil) {

        NSMutableArray<Vector*>* pointList = [NSMutableArray new];

        for (CLLocation* location in line.locations) {
            Vector* v = [[Vector alloc] initWithX:[Layer transformLonFromDouble:location.coordinate.longitude]
                                             andY:[Layer transformLatFromDouble:location.coordinate.latitude]];
            [pointList addObject:v];
        }
        
        if (line.interpolate) {
            pointList = [Interpolator interpolateWithCoordinateArray:pointList
                                                 andPointsPerSegment:10 andCurveType:CatmullRomTypeCentripetal].mutableCopy;
        }
        
        NSMutableArray<Line*>* leftLines = [NSMutableArray new];
        NSMutableArray<Line*>* rightLines = [NSMutableArray new];
        
        for (int i = 0; i < pointList.count - 1; i ++) {
            
            Vector* pt1 = [pointList objectAtIndex:i];
            Vector* pt2 = [pointList objectAtIndex:i + 1];
            
            Vector* leftPoint1 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:-(M_PI / 2) + M_PI] addedWithVector:pt1];
            Vector* leftPoint2 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:-(M_PI / 2) + M_PI] addedWithVector:pt2];
            Vector* rightPoint1 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:(M_PI / 2) + M_PI] addedWithVector:pt1];
            Vector* rightPoint2 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:(M_PI / 2) + M_PI] addedWithVector:pt2];
            
            
            [leftLines addObject:[[Line alloc] initWithP1:leftPoint1 andP2:leftPoint2]];
            [rightLines addObject:[[Line alloc] initWithP1:rightPoint1 andP2:rightPoint2]];
        }
        
        NSMutableArray<Vector*>* leftPoints = [NSMutableArray new];
        
        [leftPoints addObject: leftLines.firstObject.p1];
        
        for (int i = 0; i < leftLines.count - 1; i ++) {
            
            Line* current = [leftLines objectAtIndex:i];
            Line* next = [leftLines objectAtIndex:i + 1];
            
            Vector* intersection = [VectorMath intersectionWithLineA:current andLineB:next];
            
            if (intersection != nil) {
                [leftPoints addObject:intersection];
            }
        }
        
        [leftPoints addObject:leftLines.lastObject.p2];
        
        NSMutableArray<Vector*>* rightPoints = [NSMutableArray new];
        
        [rightPoints addObject: rightLines.firstObject.p1];
        
        for (int i = 0; i < rightLines.count - 1; i ++) {
            Line* current = [rightLines objectAtIndex:i];
            Line* next = [rightLines objectAtIndex:i + 1];
            
            Vector* intersection = [VectorMath intersectionWithLineA:current andLineB:next];
            
            if (intersection != nil) {
                [rightPoints addObject:intersection];
            }
        }
        
        [rightPoints addObject:rightLines.lastObject.p2];
        
        double maxX = 0.0;
        double maxY = 0.0;
        double minX = 0.0;
        double minY = 0.0;
        
        if (leftPoints.count == rightPoints.count) {
 
            NSMutableArray* drawObjectList = [NSMutableArray new];
            
            BOOL isFirstInterpolation = true;
            
            for (int i = 0; i < leftPoints.count - 1; i ++) {
                
                NSMutableArray<Vector*>* vectorList = [NSMutableArray new];
                
                Vector* p1 = [leftPoints objectAtIndex:i];
                Vector* p2 = [leftPoints objectAtIndex:i + 1];
                Vector* p3 = [rightPoints objectAtIndex:i + 1];
                Vector* p4 = [rightPoints objectAtIndex:i];
                              
                [vectorList addObject:p1];
                [vectorList addObject:p2];
                [vectorList addObject:p3];
                [vectorList addObject:p4];
                
                vectorList = [VectorMath closedVectorList:vectorList];
                
                NSMutableArray* vertices = [NSMutableArray new];
                
                for (Vector* v in vectorList) {
                    
                    if (isFirstInterpolation) {
                        maxX = v.x;
                        maxY = v.y;
                        minX = v.x;
                        minY = v.y;
                        
                        isFirstInterpolation = false;
                    } else {
                        maxX = fmax(maxX, v.x);
                        maxY = fmax(maxY, v.y);
                        minX = fmin(minX, v.x);
                        minY = fmin(minY, v.y);
                    }
                    
                    [vertices addObject:[NSNumber numberWithDouble:v.x]];
                    [vertices addObject:[NSNumber numberWithDouble:v.y]];
                    [vertices addObject:[NSNumber numberWithDouble:0]];
                }
                
                NSArray* objects = [Triangulator2 triangulate:vertices];
                
                for (TriangulatedDrawObject* obj in objects) {
                    [drawObjectList addObject:obj];
                }
            }
            
            self->_drawObjectList = drawObjectList;
            
        } else {
            
            BOOL isFirstInterpolation = true;
            
            NSMutableArray<Vector*>* vectorList = [NSMutableArray new];
            
            for (int i = 0; i < leftPoints.count; i ++) {
                [vectorList addObject:[leftPoints objectAtIndex:i]];
            }
            
            for (int i = (int) rightPoints.count - 1; i >= 0; i--) {
                [vectorList addObject:[rightPoints objectAtIndex:i]];
            }
            
            vectorList = [VectorMath closedVectorList:vectorList];
            
            NSMutableArray* vertices = [NSMutableArray new];
            
            for (Vector* v in vectorList) {
                
                if (isFirstInterpolation) {
                    maxX = v.x;
                    maxY = v.y;
                    minX = v.x;
                    minY = v.y;
                    
                    isFirstInterpolation = false;
                } else {
                    maxX = fmax(maxX, v.x);
                    maxY = fmax(maxY, v.y);
                    minX = fmin(minX, v.x);
                    minY = fmin(minY, v.y);
                }
                
                [vertices addObject:[NSNumber numberWithDouble:v.x]];
                [vertices addObject:[NSNumber numberWithDouble:v.y]];
                [vertices addObject:[NSNumber numberWithDouble:0]];
            }
            
            self->_drawObjectList = [Triangulator2 triangulate:vertices];
        }
        
        self->_boundingBox = CGRectMake(minX, minY, maxX - minX, maxY - minY);
        
        const CGFloat *components = CGColorGetComponents(line.color.CGColor);
        
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        
        self->_color = GLKVector4Make(red, green, blue, alpha);
        
        for (TriangulatedDrawObject* drawObject in _drawObjectList) {
            [drawObject allocateVertexBuffer];
        }
        
    }
    
    return self;
}

//SHAPE: <V3DLine: 0x280dcc5a0> ({{45.171705827866461, -107.29157912351567}, {1.8382404133941534, 10.808240644489388}}), intersects with TILE: <DrawTile: 0x2811e2a30> ({{42.219075152174277, -100.8229448880687}, {6.0312964503200561, 7.2016389205847986}})
//SHAPE: <V3DPolyline: 0x280dc1f40> ({{45.058127165813836, -108.12464894318101}, {0.25938706632300779, 0.11826309493561382}}), intersects with TILE: <DrawTile: 0x2811e31b0> ({{42.219075152174277, -108.02458380865349}, {6.0312964503200561, 7.2016389205847844}})

- (void)renderWithEffect:(GLKBaseEffect*)effect {
    
    effect.constantColor    = _color;
    effect.useConstantColor = true;
    [effect prepareToDraw];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    for (TriangulatedDrawObject* element in _drawObjectList) {
        [GLHelper drawVertexBuffer:element.vertexBuffer andMode:element.type andCount:element.numVertices];
    }
    
    effect.useConstantColor = false;
    
    glDisable(GL_BLEND);
}

-(CGRect)boundingBox {
    
    return _boundingBox;
}

-(void)dealloc {
    
    for (TriangulatedDrawObject* element in _drawObjectList) {
        [element releaseRawBuffers];
    }
}

@end



