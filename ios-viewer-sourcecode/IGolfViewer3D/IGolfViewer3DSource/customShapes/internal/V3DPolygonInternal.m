//
//  V3DPolygonInternal.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DPolygonInternal.h"
#import "../../IGolfViewer3DPrivateImports.h"


@interface V3DPolygonInternal() {
    
    NSArray* _drawObjectList;
    V3DPolygonBorder* _border;
    CGRect _boundingBox;
    GLKVector4 _color;
}

@end

@implementation V3DPolygonInternal

-(id)initWithPolygon:(V3DPolygon *)polygon {
    
    self = [super init];
    
    if (self != nil) {

        NSMutableArray<Vector*>* vectorList = [NSMutableArray new];
        
        for (CLLocation* location in polygon.locations) {
        
            double lon = [Layer transformLonFromDouble:location.coordinate.longitude];
            double lat = [Layer transformLatFromDouble:location.coordinate.latitude];
            
            Vector* newVector = [[Vector alloc] initWithX:lon andY:lat];
            
            if (vectorList.count > 0) {
                if ([vectorList.lastObject isEqualToVector:newVector]) {
                    continue;
                }
            }
            
            [vectorList addObject:newVector];
        }

        VectorOrder order = [VectorMath getVectorOrderWithVectorArray:vectorList];
        
        if (order == VectorOrderCCW) {
            vectorList = [NSMutableArray arrayWithArray:[[vectorList reverseObjectEnumerator] allObjects]];
        }
        
        vectorList = [VectorMath unclosedVectorList:vectorList];
        
        NSMutableArray<Vector*>* intersectionPoint = [VectorMath intersectionPointsWithVectorList:vectorList];
        
        if (intersectionPoint.count > 0) {
            
            for (Vector* v in intersectionPoint) {
                [vectorList addObject:v];
            }
            
            vectorList = [VectorMath polygonizeVectorList:vectorList].mutableCopy;
        }
        
        vectorList = [VectorMath closedVectorList:vectorList];
        
        if (polygon.interpolate) {
            vectorList = [Interpolator interpolateWithCoordinateArray:vectorList andPointsPerSegment:10 andCurveType:CatmullRomTypeCentripetal].mutableCopy;
        }

        NSMutableArray* vertices = [NSMutableArray new];
        
        double maxX = 0.0;
        double maxY = 0.0;
        double minX = 0.0;
        double minY = 0.0;
        
        BOOL isFirstInterpolation = true;
        
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

        if (polygon.borderWidth != 0) {
           self->_border = [[V3DPolygonBorder alloc] initWithVectorList:vectorList color:polygon.borderColor width:polygon.borderWidth];
        } else {
            self->_border = nil;
        }
        
        
        self->_drawObjectList = [Triangulator2 triangulate:vertices];
        self->_boundingBox = CGRectMake(minX, minY, maxX - minX, maxY - minY);
        
        const CGFloat *components = CGColorGetComponents(polygon.fillColor.CGColor);
        
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        
        self->_color = GLKVector4Make(red, green, blue, alpha);
        
        for (TriangulatedDrawObject* object in _drawObjectList) {
            [object allocateVertexBuffer];
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
    
    if (_border != nil) {
        [_border renderWithEffect:effect];
    }
    
    glDisable(GL_BLEND);
    
    effect.useConstantColor = false;
}

-(CGRect)boundingBox {
    
    if (_border != nil) {
        return _border.boundingBox;
    }
    
    return _boundingBox;
}

- (void)dealloc {
    
    for (TriangulatedDrawObject* element in _drawObjectList) {
        [element releaseRawBuffers];
    }
}

@end
