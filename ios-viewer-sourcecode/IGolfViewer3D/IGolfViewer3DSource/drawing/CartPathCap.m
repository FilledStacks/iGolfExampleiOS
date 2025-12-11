//
//  CartPathCap.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CartPathCap.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

#import "../IGolfViewer3DPrivateImports.h"

@interface CartPathCap () {
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    NSArray* _vertexList;
    unsigned int _numVertices;
}

@end

@implementation CartPathCap

- (id)initWithPosition:(Vector*)position andRadius:(double)radius{
    self = [super init];
    
    NSMutableArray* vertexList = [NSMutableArray new];
    NSMutableArray* uvList = [NSMutableArray new];
    
    double currentAngle = 0.0;

    while (currentAngle < M_PI * 2) {
        double x = cos(currentAngle) * radius + position.x;
        double y = sin(currentAngle) * radius + position.y;
        
        [vertexList addObject:@(x)];
        [vertexList addObject:@(y)];
        [vertexList addObject:@(0)];

        [uvList addObject:@(x)];
        [uvList addObject:@(y)];
        
        currentAngle += [VectorMath deg2radWithDeg:10];
    }

    _vertexBuffer = [GLHelper getEmptyBuffer];
    _uvBuffer = [GLHelper getEmptyBuffer];
    _vertexList = vertexList;
    [self allocateRawBuffersWithVertexList:vertexList andUvList:uvList];
    
    return self;
}
-(void)renderWithFrustum:(Frustum *)frustum {
    if ([frustum isVertexListVisible:_vertexList])
        [GLHelper drawVertexBuffer:_vertexBuffer andTexCoordBuffer:_uvBuffer andMode:GL_TRIANGLE_FAN andCount:_numVertices];
    
}


- (void)destroy {
    [self releaseRawBuffers];
}

- (void)allocateRawBuffersWithVertexList:(NSArray*)vertexList andUvList:(NSArray*)uvList {
    [GLHelper updateBuffer:_vertexBuffer andData:vertexList];
    [GLHelper updateBuffer:_uvBuffer andData:uvList];
    
    _numVertices = (GLuint)(vertexList.count / 3);
}

- (void)releaseRawBuffers {
    [GLHelper deleteBuffer:_vertexBuffer];
    [GLHelper deleteBuffer:_uvBuffer];
}

@end
