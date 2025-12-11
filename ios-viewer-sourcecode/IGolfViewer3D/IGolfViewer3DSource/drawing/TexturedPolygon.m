//
//  TexturedPolygon.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "TexturedPolygon.h"
#import <OpenGLES/ES3/gl.h>
#import "../extensions/GLKTextureInfo+Extensions.h"
#import "GLHelper.h"
#import <GLKit/GLKit.h>

@interface TexturedPolygon () {
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    unsigned int _numVertices;
}

@end

@implementation TexturedPolygon

- (id)initWithTexture:(GLKTextureInfo*)texture andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer {
    self = [super init];
    
    _vertexBuffer = vertexBuffer;
    _uvBuffer = uvBuffer;
    _numVertices = 6;
    
    self.texture = texture;
    
    return self;
}

- (void)renderWithEffect:(GLKBaseEffect *)effect {

    effect.texture2d0.name = _texture.name;
    effect.texture2d0.enabled = GL_TRUE;
    [effect prepareToDraw];

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    [GLHelper drawVertexBuffer:_vertexBuffer andTexCoordBuffer:_uvBuffer andMode:GL_TRIANGLES andCount:_numVertices];
    
    effect.texture2d0.enabled = false;
}

- (void)destroy {
    [_texture releaseTexture];
}

@end
