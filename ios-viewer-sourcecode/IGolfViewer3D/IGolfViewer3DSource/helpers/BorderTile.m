//
//  BorderTile.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//
#import "BorderTile.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface BorderTile() {
    
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    GLuint _indexBuffer;
    GLuint _normalBuffer;
    GLuint _numVertices;
    
    GLKVector4 _lightPosition;
    
    GLKTextureInfo* _texture;
    GLKTextureInfo* _textureFlyover;
}
@end

@implementation BorderTile

-(id)initWithVertexArray:(NSArray *)vertexArray andLightPosition:(GLKVector4)lightPosition andTextureProfile:(TextureProfile*)textureProfile; {
    self = [super init];
    
    if (self) {
        self->_lightPosition = lightPosition;
        self->_texture = [GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:textureProfile.backgroundTexture3DName ofType:@"png"]];
        self->_textureFlyover = [GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:textureProfile.flyoverTextureName ofType:@"png"]];
        [self makeVerticesWithVertexArray:vertexArray];
    }
    
    return self;
}

- (void)makeVerticesWithVertexArray:(NSArray*)vertexArray {
    
    int _mapHeight = (int)[vertexArray count];
    
    NSArray* firstRow = vertexArray[0];
    
    int _mapWidth = (int)[firstRow count];
    
    NSMutableArray* _vertexList = [NSMutableArray new];
    NSMutableArray* _vertexArray = [NSMutableArray new];
    NSMutableArray* _uvList = [NSMutableArray new];
    NSMutableArray* _indexList = [NSMutableArray new];
    NSMutableArray* _normalList = [NSMutableArray new];
    
    for (int y = 0 ; y < _mapHeight ; y++) {
        
        NSArray* row = vertexArray[y];
        
        for (int x = 0 ; x < _mapWidth ; x++) {
            Vertex* v = row[x];
            [_vertexArray addObject:v];
        }
    }
    
    for (int i = 0; i <= _mapHeight - 2; i++) {
        for (int j = 0; j <= _mapWidth - 2; j++) {
            
            Vertex* v1;
            Vertex* v2;
            Vertex* v3;
            Vector* normal;
            
            int t = j + i * _mapWidth;
            
            [_indexList addObject:@(t + _mapWidth + 1)];
            [_indexList addObject:@((t + 1))];
            [_indexList addObject:@(t)];
            
            v1 = [_vertexArray objectAtIndex:(t + _mapWidth + 1)];
            v2 = [_vertexArray objectAtIndex:(t + 1)];
            v3 = [_vertexArray objectAtIndex:(t)];
            
            normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];
            
            
            [v1 setNormalVector: normal];
            [v2 setNormalVector: normal];
            [v3 setNormalVector: normal];
            
            
            [_indexList addObject:@(t + _mapWidth)];
            [_indexList addObject:@((t + _mapWidth + 1))];
            [_indexList addObject:@(t)];
            
            v1 = [_vertexArray objectAtIndex:(t + _mapWidth)];
            v2 = [_vertexArray objectAtIndex:(t + _mapWidth + 1)];
            v3 = [_vertexArray objectAtIndex:(t)];
            
            normal = [VectorMath getTriangleNormalWithV1:v1.vector andV2:v2.vector andV3:v3.vector];
            
            [v1 setNormalVector: normal];
            [v2 setNormalVector: normal];
            [v3 setNormalVector: normal];
            
        }
    }
    
    for (Vertex* vertex in _vertexArray) {
        
        [_vertexList addObject:@(vertex.vector.x)];
        [_vertexList addObject:@(vertex.vector.y)];
        [_vertexList addObject:@(vertex.vector.z)];
        
        [_uvList addObject:@(vertex.vector.x)];
        [_uvList addObject:@(vertex.vector.y)];
        
        [_normalList addObject:@(vertex.normalVector.x)];
        [_normalList addObject:@(vertex.normalVector.y)];
        [_normalList addObject:@(vertex.normalVector.z)];
    }
    
    _vertexBuffer   = [GLHelper getBuffer:_vertexList];
    _uvBuffer       = [GLHelper getBuffer:_uvList];
    _indexBuffer    = [GLHelper getIndexBuffer:_indexList];
    _numVertices    = (int)_indexList.count;
    _normalBuffer   = [GLHelper getBuffer:_normalList];
}

-(void)renderWithEffect:(GLKBaseEffect *)effect isFlyover:(BOOL)isFlyover {
    GLKTextureInfo* currentTexture = isFlyover ? _textureFlyover : _texture;
    effect.light0.enabled = GL_TRUE;
    effect.light0.position = _lightPosition;
    effect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1);
    effect.light0.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
    effect.light0.ambientColor = GLKVector4Make(0.3, 0.3, 0.3, 1);
    
    effect.lightingType = GLKLightingTypePerPixel;
    
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = currentTexture.name;
    
    effect.colorMaterialEnabled = GL_TRUE;
    
    [effect prepareToDraw];
    
    glBindTexture(currentTexture.target, currentTexture.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    [GLHelper drawVertexBuffer:_vertexBuffer andIndexBuffer:_indexBuffer andTexCoordBuffer:_uvBuffer andNormalBuffer:_normalBuffer andMode:GL_TRIANGLES andCount:_numVertices];
    
    effect.light0.enabled = GL_FALSE;
    effect.colorMaterialEnabled = GL_FALSE;
}


@end
