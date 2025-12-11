//
//  V3DPointInternal.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DCircleInternal.h"
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DCircleInternal() {
    
    V3DPolygonBorder*   _border;

    GLuint              _vertexBuffer;
    unsigned int        _numVertices;
    CGRect              _boundingBox;
    GLKVector4          _color;
}

@end

@implementation V3DCircleInternal

- (id)initWithPoint:(V3DCircle *)point {
    
    self = [super init];
    
    if (self != nil) {
        
        CGFloat x = [Layer transformLonFromDouble:point.location.coordinate.longitude];
        CGFloat y = [Layer transformLatFromDouble:point.location.coordinate.latitude];
        
        Vector* position = [[Vector alloc] initWithX:x andY:y];
        
        const CGFloat *components = CGColorGetComponents(point.fillColor.CGColor);
        
        CGFloat red   = components[0];
        CGFloat green = components[1];
        CGFloat blue  = components[2];
        CGFloat alpha = components[3];
        
        self->_color = GLKVector4Make(red, green, blue, alpha);
        
        NSMutableArray* vertexArray = [NSMutableArray new];
        NSMutableArray* vectorList = [NSMutableArray new];
        
        double currentAngle = 0.0;
        double stepDegrees = 5;
        
        BOOL isFirstIterration = true;
        
        double maxX = 0.0;
        double maxY = 0.0;
        double minX = 0.0;
        double minY = 0.0;
        
        while (currentAngle < M_PI * 2) {
            
            double x = position.x + cos(currentAngle) * point.radius * METERS_IN_POINT;
            double y = position.y - sin(currentAngle) * point.radius * METERS_IN_POINT;
            double z = 0;
            
            if (isFirstIterration) {
                
                maxX = x;
                maxY = y;
                minX = x;
                minY = y;
                
                isFirstIterration = false;
            }
            
            if (!isFirstIterration) {
                
                maxX = fmax(x, maxX);
                maxY = fmax(y, maxY);
                minX = fmin(x, minX);
                minY = fmin(y, minY);
                
                [vectorList addObject:[[Vector alloc] initWithX:x andY:y]];
            }
            
            [vertexArray addObject:@(x)];
            [vertexArray addObject:@(y)];
            [vertexArray addObject:@(z)];
            
            currentAngle += [VectorMath deg2radWithDeg:stepDegrees];
        }
        
        if (point.borderWidth != 0) {
            self->_border = [[V3DPolygonBorder alloc] initWithVectorList:vectorList color:point.borderColor width:point.borderWidth];
        } else {
            self->_border = nil;
        }
        
        self->_vertexBuffer = [GLHelper getBuffer : vertexArray];
        self->_numVertices  = (GLuint)(vertexArray.count / 3);
        self->_boundingBox  = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    
    return self;
}

-(CGRect)boundingBox {
    
    if (_border != nil) {
        return _border.boundingBox;
    }
    
    return _boundingBox;
}

- (void)renderWithEffect:(GLKBaseEffect*)effect {
    
    effect.constantColor    = _color;
    effect.useConstantColor = true;
    [effect prepareToDraw];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    [GLHelper drawVertexBuffer:_vertexBuffer andMode:GL_TRIANGLE_FAN andCount:_numVertices];
    
    if (_border != nil) {
        [_border renderWithEffect:effect];
    }
    
    glDisable(GL_BLEND);
    
    effect.useConstantColor = false;
}


-(void)dealloc {
    
    [GLHelper deleteBuffer:_vertexBuffer];
}

@end
