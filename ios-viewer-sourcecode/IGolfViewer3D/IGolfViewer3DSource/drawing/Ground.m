//
//  Ground.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import "Ground.h"

#import "../IGolfViewer3DPrivateImports.h"

@interface Ground () {
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    GLuint _indexBuffer;
    
    unsigned int _numVertices;
}

@property (nonatomic, retain) GLKTextureInfo* texture2d;
@property (nonatomic, retain) GLKTextureInfo* texture3d;
@property (nonatomic, retain) GLKTextureInfo* textureFlyover;

@end

@implementation Ground

+ (double)SceneRadius {
    return 1000;
}
+ (double)SceneAngleStepDegrees {
    return 10.0;
}


- (id)initWith2DTextureFilePath:(NSString*)textureFilePath2d and3DTextureFilePath:(NSString*)textureFilePath3d andFlyoverTextureFilePath:(NSString *)flyoverTextureFilePath {
    self = [super init];
    
    NSMutableArray* vertexList = [NSMutableArray new];
    NSMutableArray* uvList = [NSMutableArray new];

    double currentAngle = 0.0;

    while (currentAngle < M_PI * 2) {
        double x = cos(currentAngle) * Ground.SceneRadius;
        double y = sin(currentAngle) * Ground.SceneRadius;
        double z = 0;
        [vertexList addObject:@(x)];
        [vertexList addObject:@(y)];
        [vertexList addObject:@(z)];

        [uvList addObject:@(x)];
        [uvList addObject:@(y)];

        currentAngle += [VectorMath deg2radWithDeg:Ground.SceneAngleStepDegrees];
    }
    
    self.texture2d = [GLKTextureInfo loadFromCacheWithFilePath:textureFilePath2d];
    self.texture3d = [GLKTextureInfo loadFromCacheWithFilePath:textureFilePath3d];
    self.textureFlyover = [GLKTextureInfo loadFromCacheWithFilePath:flyoverTextureFilePath];
    
    _vertexBuffer = [GLHelper getBuffer:vertexList];
    _uvBuffer = [GLHelper getBuffer:uvList];
    _numVertices = (GLuint)(vertexList.count / 3);

    return self;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect using2DTexture:(BOOL)texture2d isFlyover:(BOOL)isFlyover {


    glDisable(GL_DEPTH_TEST);
    
    
    if(isFlyover){
        [GLHelper prepareTextureToStartDraw:_textureFlyover andEffect:effect];
    } else if (texture2d) {
        [GLHelper prepareTextureToStartDraw:_texture2d andEffect:effect];
    } else {
        [GLHelper prepareTextureToStartDraw:_texture3d andEffect:effect];
    }
    [GLHelper drawVertexBuffer:_vertexBuffer andTexCoordBuffer:_uvBuffer andMode:GL_TRIANGLE_FAN andCount:_numVertices];
    [GLHelper disableTextureForEffect:effect];
}

- (void)destroy {
    [GLHelper deleteBuffer:_vertexBuffer];
    [GLHelper deleteBuffer:_uvBuffer];
}

@end
