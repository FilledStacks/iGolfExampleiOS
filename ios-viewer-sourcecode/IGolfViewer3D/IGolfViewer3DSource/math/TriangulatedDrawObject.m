//
//  TriangulatedDrawObject.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "TriangulatedDrawObject.h"
#import "GLHelper.h"
#import "VectorMath.h"
#import "Vector.h"

@interface TriangulatedDrawObject () {
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    GLuint _normalBuffer;
    GLuint _numVertices;
    GLuint _colorBuffer;
}

@end

@implementation TriangulatedDrawObject


- (GLuint)vertexBuffer {
    return _vertexBuffer;
}

- (GLuint)uvBuffer {
    return _uvBuffer;
}

- (GLuint)numVertices {
    return _numVertices;
}

-(GLuint)normalBuffer {
    return _normalBuffer;
}

-(GLuint)colorBuffer {
    return _colorBuffer;
}

-(void)allocateVerticalNormalBuffer {
    
    NSMutableArray* normalList = [NSMutableArray new];
    
    for (int i = 0; i < self.vertexList.count / 3; i ++) {
        [normalList addObject:@(0)];
        [normalList addObject:@(0)];
        [normalList addObject:@(1)];
    }

    _normalBuffer = [GLHelper getBuffer:normalList];
}

-(void)allocateNormalBuffer {
    
    NSMutableArray* normalList = [NSMutableArray new];

    if (self.type == GL_TRIANGLE_FAN) {
        
        double x1 = [[self.vertexList objectAtIndex:0] doubleValue];
        double y1 = [[self.vertexList objectAtIndex:1] doubleValue];
        double z1 = [[self.vertexList objectAtIndex:2] doubleValue];
        
        Vector* v1 = [[Vector alloc] initWithX:x1 andY:y1 andZ:z1];
        
        BOOL isFirstIteration = true;
        
        for (int i = 1; i < (self.vertexList.count / 3) - 1; i++) {
            
            double x2 = [[self.vertexList objectAtIndex:i * 3 + 0] doubleValue];
            double y2 = [[self.vertexList objectAtIndex:i * 3 + 1] doubleValue];
            double z2 = [[self.vertexList objectAtIndex:i * 3 + 2] doubleValue];
            
            Vector* v2 = [[Vector alloc] initWithX:x2 andY:y2 andZ:z2];
            
            double x3 = [[self.vertexList objectAtIndex:i * 3 + 3] doubleValue];
            double y3 = [[self.vertexList objectAtIndex:i * 3 + 4] doubleValue];
            double z3 = [[self.vertexList objectAtIndex:i * 3 + 5] doubleValue];
            
            Vector* v3 = [[Vector alloc] initWithX:x3 andY:y3 andZ:z3];
                
            Vector* normal = [VectorMath getTriangleNormalWithV1:v1 andV2:v2 andV3:v3];
            
            if (isFirstIteration) {
                
                [normalList addObject:@(normal.x)];
                [normalList addObject:@(normal.y)];
                [normalList addObject:@(normal.z)];
                
                [normalList addObject:@(normal.x)];
                [normalList addObject:@(normal.y)];
                [normalList addObject:@(normal.z)];
                
                isFirstIteration = false;
            }
            
            [normalList addObject:@(normal.x)];
            [normalList addObject:@(normal.y)];
            [normalList addObject:@(normal.z)];
            
        }
        
    } else if (self.type == GL_TRIANGLE_STRIP) {
        
        BOOL isFirstIteration = true;
        
        for (int i = 0; i < (self.vertexList.count / 3) - 2; i ++) {
            
            double x1 = [[self.vertexList objectAtIndex:i * 3 + 0] doubleValue];
            double y1 = [[self.vertexList objectAtIndex:i * 3 + 1] doubleValue];
            double z1 = [[self.vertexList objectAtIndex:i * 3 + 2] doubleValue];
            
            Vector* v1 = [[Vector alloc] initWithX:x1 andY:y1 andZ:z1];
            
            double x2 = [[self.vertexList objectAtIndex:i * 3 + 3] doubleValue];
            double y2 = [[self.vertexList objectAtIndex:i * 3 + 4] doubleValue];
            double z2 = [[self.vertexList objectAtIndex:i * 3 + 5] doubleValue];
            
            Vector* v2 = [[Vector alloc] initWithX:x2 andY:y2 andZ:z2];
            
            double x3 = [[self.vertexList objectAtIndex:i * 3 + 6] doubleValue];
            double y3 = [[self.vertexList objectAtIndex:i * 3 + 7] doubleValue];
            double z3 = [[self.vertexList objectAtIndex:i * 3 + 8] doubleValue];
            
            Vector* v3 = [[Vector alloc] initWithX:x3 andY:y3 andZ:z3];
            
            Vector* normal;
            
            if (i % 2 == 0) {
                normal = [VectorMath getTriangleNormalWithV1:v1 andV2:v2 andV3:v3];
            } else {
                normal = [VectorMath getTriangleNormalWithV1:v1 andV2:v3 andV3:v2];
            }

            if (isFirstIteration) {
                
                [normalList addObject:@(normal.x)];
                [normalList addObject:@(normal.y)];
                [normalList addObject:@(normal.z)];
                
                [normalList addObject:@(normal.x)];
                [normalList addObject:@(normal.y)];
                [normalList addObject:@(normal.z)];
                
                isFirstIteration = false;
            }
            
            [normalList addObject:@(normal.x)];
            [normalList addObject:@(normal.y)];
            [normalList addObject:@(normal.z)];
        }
    } else if (self.type == GL_TRIANGLES) {

        for (int i = 0; i < self.vertexList.count / 3; i += 3) {
            double x1 = [[self.vertexList objectAtIndex:i * 3 + 0] doubleValue];
            double y1 = [[self.vertexList objectAtIndex:i * 3 + 1] doubleValue];
            double z1 = [[self.vertexList objectAtIndex:i * 3 + 2] doubleValue];
            
            Vector* v1 = [[Vector alloc] initWithX:x1 andY:y1 andZ:z1];
            
            double x2 = [[self.vertexList objectAtIndex:i * 3 + 3] doubleValue];
            double y2 = [[self.vertexList objectAtIndex:i * 3 + 4] doubleValue];
            double z2 = [[self.vertexList objectAtIndex:i * 3 + 5] doubleValue];
            
            Vector* v2 = [[Vector alloc] initWithX:x2 andY:y2 andZ:z2];
            
            double x3 = [[self.vertexList objectAtIndex:i * 3 + 6] doubleValue];
            double y3 = [[self.vertexList objectAtIndex:i * 3 + 7] doubleValue];
            double z3 = [[self.vertexList objectAtIndex:i * 3 + 8] doubleValue];
            
            Vector* v3 = [[Vector alloc] initWithX:x3 andY:y3 andZ:z3];
            
            Vector* normal = [VectorMath getTriangleNormalWithV1:v1 andV2:v2 andV3:v3];
            
            [normalList addObject:@(normal.x)];
            [normalList addObject:@(normal.y)];
            [normalList addObject:@(normal.z)];
            
            [normalList addObject:@(normal.x)];
            [normalList addObject:@(normal.y)];
            [normalList addObject:@(normal.z)];
            
            [normalList addObject:@(normal.x)];
            [normalList addObject:@(normal.y)];
            [normalList addObject:@(normal.z)];
        }
    } else {
        for (int i = 0; i < self.vertexList.count / 3; i ++) {
            [normalList addObject:@(0)];
            [normalList addObject:@(0)];
            [normalList addObject:@(1)];
        }
    }

    _normalBuffer = [GLHelper getBuffer:normalList];
}

- (void)allocateVertexBuffer {
    _vertexBuffer = [GLHelper getBuffer:_vertexList];
    _numVertices = (GLuint)(self.vertexList.count / 3);
}

- (void)allocateColorBuffer {
    
    _colorBuffer = [GLHelper getBuffer:_colorList];
}



- (void)allocateRawBuffers {
    
    _vertexBuffer = [GLHelper getBuffer:_vertexList];
    _uvBuffer = [GLHelper getBuffer:_uvList];
    _numVertices = (GLuint)(self.vertexList.count / 3);
}

- (void)releaseRawBuffers {
    [GLHelper deleteBuffer:_vertexBuffer];
    [GLHelper deleteBuffer:_uvBuffer];
    [GLHelper deleteBuffer:_normalBuffer];
    [GLHelper deleteBuffer:_colorBuffer];
}



@end
