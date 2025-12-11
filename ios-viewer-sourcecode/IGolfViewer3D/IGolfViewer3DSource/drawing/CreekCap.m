//
//  CreekCap.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CreekCap.h"
#import <OpenGLES/ES3/gl.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface CreekCap () {
    GLuint _vertexBuffer;
    unsigned int _numVertices;
}

@end

@implementation CreekCap

- (id)initWithPosition:(Vector*)position andRadius:(double)radius {
    self = [super init];
    
    NSMutableArray* vertexList = [NSMutableArray new];

    double currentAngle = 0.0;

    while (currentAngle < M_PI * 2) {
        
        double x = cos(currentAngle) * radius + position.x;
        double y = sin(currentAngle) * radius + position.y;
        
        [vertexList addObject:@(x)];
        [vertexList addObject:@(y)];
        [vertexList addObject:@(0)];

        currentAngle += [VectorMath deg2radWithDeg:10];
    }

    _vertexBuffer = [GLHelper getEmptyBuffer];

    [self allocateRawBuffersWithVertexList:vertexList];
    
    return self;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect {
    
}

-(void)render {
    [GLHelper drawVertexBuffer:_vertexBuffer andMode:GL_TRIANGLE_FAN andCount:_numVertices];
}

- (void)destroy {
    [self releaseRawBuffers];
}

- (void)allocateRawBuffersWithVertexList:(NSArray*)vertexList {

    [GLHelper updateBuffer:_vertexBuffer andData:vertexList];
    _numVertices = (GLuint)(vertexList.count / 3);
}

- (void)releaseRawBuffers {
    [GLHelper deleteBuffer:_vertexBuffer];
}

@end
