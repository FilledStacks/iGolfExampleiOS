//
//  V3DPolygonBorder.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DPolygonBorder.h"
#import <UIKit/UIKit.h>
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DPolygonBorder() {
    NSArray* _drawObjectList;
    CGRect _boundingBox;
    GLKVector4 _color;
}

@end

@implementation V3DPolygonBorder

- (id)initWithVectorList:(NSMutableArray<Vector *> *)vectorList color:(UIColor *)color width:(double)width {
    self = [super init];
    
    if (self) {
        
        NSMutableArray<Vector*>* pointList = [VectorMath unclosedVectorList:vectorList];
        
        NSMutableArray<Line*>* leftLines = [NSMutableArray new];
        NSMutableArray<Line*>* rightLines = [NSMutableArray new];
        
        for (int i = 0; i < pointList.count; i ++) {
            
            Vector* pt1 = [pointList objectAtIndex:i];
            Vector* pt2 = (i + 1 >= pointList.count) ? pointList.firstObject : [pointList objectAtIndex:i + 1];
            
            Vector* leftPoint1 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:width * METERS_IN_POINT / 2] rotatedWithAngle:-(M_PI / 2) + M_PI] addedWithVector:pt1];
            Vector* leftPoint2 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:width * METERS_IN_POINT / 2] rotatedWithAngle:-(M_PI / 2) + M_PI] addedWithVector:pt2];

            Vector* rightPoint1 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:width * METERS_IN_POINT / 2] rotatedWithAngle:(M_PI / 2) + M_PI] addedWithVector:pt1];
            Vector* rightPoint2 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:width * METERS_IN_POINT / 2] rotatedWithAngle:(M_PI / 2) + M_PI] addedWithVector:pt2];
            
            [leftLines addObject:[[Line alloc] initWithP1:leftPoint1 andP2:leftPoint2]];
            [rightLines addObject:[[Line alloc] initWithP1:rightPoint1 andP2:rightPoint2]];
        }
        
        NSMutableArray<Vector*>* leftPoints = [NSMutableArray new];
       
        Line* leftFirst = leftLines.firstObject;
        Line* leftLast = leftLines.lastObject;
        
        Vector* leftIntersection = [VectorMath intersectionWithLineA:leftFirst andLineB:leftLast];
        
        if (leftIntersection != nil) {
            [leftPoints addObject:leftIntersection];
        }
        
        for (int i = 0; i < leftLines.count - 1; i ++) {
            Line* current = [leftLines objectAtIndex:i];
            Line* next = [leftLines objectAtIndex:i + 1];
            
            Vector* intersection = [VectorMath intersectionWithLineA:current andLineB:next];
            
            if (intersection != nil) {
                [leftPoints addObject:intersection];
            }
        }
        
        if (leftIntersection != nil) {
            [leftPoints addObject:leftIntersection];
        }
        
        NSMutableArray<Vector*>* rightPoints = [NSMutableArray new];
        
        Line* rightFirst = rightLines.firstObject;
        Line* rightLast = rightLines.lastObject;
        
        Vector* rightIntersection = [VectorMath intersectionWithLineA:rightFirst andLineB:rightLast];
        
        if (rightIntersection != nil) {
            [rightPoints addObject:rightIntersection];
        }
        
        for (int i = 0; i < rightLines.count - 1; i ++) {
            Line* current = [rightLines objectAtIndex:i];
            Line* next = [rightLines objectAtIndex:i + 1];
            
            Vector* intersection = [VectorMath intersectionWithLineA:current andLineB:next];
            
            if (intersection != nil) {
                [rightPoints addObject:intersection];
            }
        }
        
        if (rightIntersection != nil) {
            [rightPoints addObject:rightIntersection];
        }
        
        double maxX = 0.0;
        double maxY = 0.0;
        double minX = 0.0;
        double minY = 0.0;

        if (leftPoints.count == rightPoints.count) {
            
            BOOL isFirstInterpolation = true;
            
            NSMutableArray* drawObjectList = [NSMutableArray new];
            
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
                        isFirstInterpolation = false;
                        
                        maxX = v.x;
                        maxY = v.y;
                        minX = v.x;
                        minY = v.y;
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
                    isFirstInterpolation = false;
                    
                    maxX = v.x;
                    maxY = v.y;
                    minX = v.x;
                    minY = v.y;
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
        
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        
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

- (void)renderWithEffect:(GLKBaseEffect*)effect {
    
    effect.constantColor    = _color;
    effect.useConstantColor = true;
    [effect prepareToDraw];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    for (TriangulatedDrawObject* element in _drawObjectList) {
        [GLHelper drawVertexBuffer:element.vertexBuffer andMode:element.type andCount:element.numVertices];
    }
    
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
