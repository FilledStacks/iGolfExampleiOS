//
//  CartPath.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CartPath.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface CartPath () {
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    NSArray* _vertexList;
    unsigned int _numVertices;
    CartPathCap* startCap;
    CartPathCap* endCap;
}

@property (nonatomic, retain) GLKTextureInfo* texture;

@end

@implementation CartPath

- (id)initWithTextureFilename:(NSString*)textureFilename andPointList:(PointList*)pointList andWidth:(double)width {
    self = [super init];

    NSMutableArray* vertexList = [NSMutableArray new];
    NSMutableArray* uvList = [NSMutableArray new];
    
    self.texture = [GLKTextureInfo loadFromCacheWithFilePath:textureFilename];
    
    NSArray* _pointList = pointList.pointList;
    
    for (int i = 0 ; i < _pointList.count-1 ; i++) {
        
        Vector* start = [_pointList objectAtIndex:i];
        Vector* end = [_pointList objectAtIndex:i+1];
        Vector* diff = [end substractedWithVector:start];
        Vector* normalized = [diff normalized];
        Vector* multiplied = [normalized multipliedWithFactor:width/2];
        Vector* pt1 = [multiplied rotatedWithAngle:M_PI / 2];
        
        pt1 = [pt1 addedWithVector:start];
        
        Vector* pt2 = [multiplied rotatedWithAngle:-M_PI / 2];
        
        pt2 = [pt2 addedWithVector:start];
        
        if (i == 0) {
            [vertexList addObject:@(pt1.x)];
            [vertexList addObject:@(pt1.y)];
            [vertexList addObject:@(0)];

            [uvList addObject:@(pt1.x)];
            [uvList addObject:@(pt1.y)];
        }
        
        [vertexList addObject:@(pt2.x)];
        [vertexList addObject:@(pt2.y)];
        [vertexList addObject:@(0)];

        [uvList addObject:@(pt2.x)];
        [uvList addObject:@(pt2.y)];


        start = [_pointList objectAtIndex:i+1];
        end = [_pointList objectAtIndex:i];
        diff = [end substractedWithVector:start];
        normalized = [diff normalized];
        multiplied = [normalized multipliedWithFactor:width/2];

        pt1 = [multiplied rotatedWithAngle:-M_PI/2];
        pt1 = [pt1 addedWithVector:start];

        pt2 = [multiplied rotatedWithAngle:M_PI/2];
        pt2 = [pt2 addedWithVector:start];

        [vertexList addObject:@(pt1.x)];
        [vertexList addObject:@(pt1.y)];
        [vertexList addObject:@(0)];

        [uvList addObject:@(pt1.x)];
        [uvList addObject:@(pt1.y)];
        
        if (i == _pointList.count - 2) {
            
            [vertexList addObject:@(pt2.x)];
            [vertexList addObject:@(pt2.y)];
            [vertexList addObject:@(0)];
            
            [uvList addObject:@(pt2.x)];
            [uvList addObject:@(pt2.y)];
        }
        
    }
    
    _vertexBuffer = [GLHelper getEmptyBuffer];
    _uvBuffer = [GLHelper getEmptyBuffer];
    
    [self allocateRawBuffersWithVertexList:vertexList andUvList:uvList];
    _vertexList = vertexList;
    startCap = [[CartPathCap alloc] initWithPosition:_pointList.firstObject andRadius: width/2];
    endCap = [[CartPathCap alloc] initWithPosition:_pointList.lastObject andRadius:width/2];
    
    return self;
}

-(void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum {

    [GLHelper prepareTextureToStartDraw:_texture andEffect:effect];
    
    if ([frustum isVertexListVisible:_vertexList])
         [GLHelper drawVertexBuffer:_vertexBuffer andTexCoordBuffer:_uvBuffer andMode:GL_TRIANGLE_STRIP andCount:_numVertices];

    [GLHelper disableTextureForEffect:effect];
    [startCap renderWithFrustum:frustum];
    [endCap renderWithFrustum:frustum];
}

- (void)destroy {
    [self releaseRawBuffers];
    
    [startCap destroy];
    [endCap destroy];
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
