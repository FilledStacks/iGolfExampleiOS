//
//  V3DLineInternal.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DLineInternal.h"
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DLineInternal() {

    NSArray* _drawObjectList;
    GLKVector4 _color;
    CGRect _boundingBox;
}

@end

@implementation V3DLineInternal

-(id)initWithLine:(V3DLine *)line {
    
    self = [super init];
    
    if (self != nil) {

        Vector* pt1 = [[Vector alloc] initWithX:[Layer transformLonFromDouble:line.startLocation.coordinate.longitude]
                                           andY:[Layer transformLatFromDouble:line.startLocation.coordinate.latitude]];
        
        Vector* pt2 = [[Vector alloc] initWithX:[Layer transformLonFromDouble:line.endLocation.coordinate.longitude]
                                                  andY:[Layer transformLatFromDouble:line.endLocation.coordinate.latitude]];
        
        NSMutableArray<Vector*>* vectorList = [NSMutableArray new];
        
        Vector* newPoint1 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:-(M_PI / 2) + M_PI] addedWithVector:pt1];
        Vector* newPoint2 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:-(M_PI / 2) + M_PI] addedWithVector:pt2];
        Vector* newPoint3 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:(M_PI / 2) + M_PI] addedWithVector:pt2];
        Vector* newPoint4 = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:line.width * METERS_IN_POINT / 2] rotatedWithAngle:(M_PI / 2) + M_PI] addedWithVector:pt1];
        
        [vectorList addObject:newPoint1];
        [vectorList addObject:newPoint2];
        [vectorList addObject:newPoint3];
        [vectorList addObject:newPoint4];
        
        vectorList = [VectorMath closedVectorList:vectorList];

        NSMutableArray* vertices = [NSMutableArray new];
        
        double maxX = 0.0;
        double maxY = 0.0;
        double minX = 0.0;
        double minY = 0.0;
        
        BOOL isFirstInterpolation = true;
        
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
        
        self->_boundingBox = CGRectMake(minX, minY, maxX - minX, maxY - minY);
        self->_drawObjectList = [Triangulator2 triangulate:vertices];
        
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
