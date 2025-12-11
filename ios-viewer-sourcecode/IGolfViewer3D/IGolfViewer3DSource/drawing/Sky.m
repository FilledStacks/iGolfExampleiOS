//
//  Sky.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Sky.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import "../IGolfViewer3DPrivateImports.h"


@interface Sky () {
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    unsigned int _numVertices;
}

@property (nonatomic, retain) GLKTextureInfo* textureDefault;
@property (nonatomic, retain) GLKTextureInfo* textureFlyover;

@end

@implementation Sky


- (id)initWithDefaultFilePath:(NSString*)defaultFilePath andTextureFilePath:(NSString*)flyoverFilePath {
    self = [super init];
    
    NSMutableArray* vertexList = [NSMutableArray new];
    NSMutableArray* uvList = [NSMutableArray new];
    
    double currentAngle = 0.0;
    double height = 1500;
    while (currentAngle < M_PI * 2) {
        double x = cos(currentAngle) * Ground.SceneRadius;
        double y = sin(currentAngle) * Ground.SceneRadius;
        double u = currentAngle / M_PI;
        
        [vertexList addObject:@(x)];
        [vertexList addObject:@(y)];
        [vertexList addObject:@(-height/2)];
        
        [uvList addObject:@(u)];
        [uvList addObject:@(1)];

        [vertexList addObject:@(x)];
        [vertexList addObject:@(y)];
        [vertexList addObject:@(height)];
        
        [uvList addObject:@(u)];
        [uvList addObject:@(0)];

        currentAngle += [VectorMath deg2radWithDeg: Ground.SceneAngleStepDegrees];
    }

    self.textureDefault = [GLKTextureInfo loadFromCacheWithFilePath:defaultFilePath];
    self.textureFlyover = [GLKTextureInfo loadFromCacheWithFilePath:flyoverFilePath];
    
    _vertexBuffer = [GLHelper getBuffer:vertexList];
    _uvBuffer = [GLHelper getBuffer:uvList];
    _numVertices = (GLuint)(vertexList.count / 3);
    
    return self;
}
-(void)renderWithEffect:(GLKBaseEffect*)effect andIsFlyover:(Boolean) isFlyover {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    effect.texture2d0.enabled = GL_TRUE;
    if(isFlyover){
        effect.texture2d0.name = _textureFlyover.name;
        [effect prepareToDraw];
        glBindTexture(_textureFlyover.target, _textureFlyover.name);
    } else {
        effect.texture2d0.name = _textureDefault.name;
        [effect prepareToDraw];
        glBindTexture(_textureDefault.target, _textureDefault.name);
    }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    [GLHelper drawVertexBuffer:_vertexBuffer andTexCoordBuffer:_uvBuffer andMode:GL_TRIANGLE_STRIP andCount:_numVertices];
    
    glDisable(GL_BLEND);
    effect.texture2d0.enabled = GL_FALSE;
}

- (void)destroy {
    [self releaseRawBuffers];
}

- (void)releaseRawBuffers {
    [GLHelper deleteBuffer:_vertexBuffer];
    [GLHelper deleteBuffer:_uvBuffer];
}

@end
