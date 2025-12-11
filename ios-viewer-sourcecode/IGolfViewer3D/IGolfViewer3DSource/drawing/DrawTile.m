//
//  DrawTile.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "DrawTile.h"
#import <OpenGLES/ES3/gl.h>
#import "../IGolfViewer3DPrivateImports.h"


@interface DrawTile() {
    
    GLuint _vertexBuffer;
    GLuint _uvBuffer;
    GLuint _indexBuffer;
    GLuint _normalBuffer;
    GLuint _numVertices;
    GLuint _defaultTextureName;
    GLuint _textureName;
    GLuint _depthStensilTextureName;
    GLuint _textureFrameBuffer;
    GLuint _renderBuffer;
    GLuint _additionalTextureName;
    GLuint _additionalTextureFrameBuffer;
    
    CGRect _boundingBox;
    
    double _midX;
    double _midY;
    double _midZ;
    double _maxZ;
    
    Vector* _position;
    
    int _viewportWidth;
    int _viewportHeight;
    
    double _tileWidth;
    double _tileHeight;
    
    TextureQuality _textureQuality;
    TextureQuality _requestedTextureQuality;
    
    GLKVector4 _lightPosition;
    NSMutableArray<NSMutableArray<Vector*>*>* _vectorList;
    
    Vector* _topLeft;
    Vector* _topRight;
    Vector* _bottomLeft;
    Vector* _bottomRight;
    
    Frustum* _frustum;
    NSMutableArray* _vertexList;
    NSArray<NSArray<Vertex*>*>* _vertexArray;
    BOOL _hasAdditionalTexture;
}

@end

@implementation DrawTile

-(id)initWithVertexArray:(NSArray *)vertexArray andLightPosition:(GLKVector4)lightPosition {
    self = [super init];
    
    if (self) {
        self->_vertexArray = vertexArray;
        self->_vectorList = [NSMutableArray new];
        self->_textureQuality = TextureQualityNone;
        self->_requestedTextureQuality = TextureQualityNone;
        self->_lightPosition = lightPosition;
        self->_defaultTextureName = [GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_background" ofType:@"png"]].name;
        [self makeVerticesWithVertexArray:vertexArray];
        self->_frustum = [[Frustum alloc] init];
        self->_maxZ = 0;
        
        self->_hasAdditionalTexture = false;
    }
    
    return self;
}

-(NSArray<NSArray<Vertex*>*>*)getVertexArray {
    return _vertexArray;
}

-(NSArray *)getVertexList {
    return _vertexList;
}

- (void)makeVerticesWithVertexArray:(NSArray*)vertexArray {
    
    int _mapHeight = (int)[vertexArray count];
    
    NSArray* firstRow = vertexArray[0];
    
    int _mapWidth = (int)[firstRow count];
    
    NSArray* lastRow = vertexArray[_mapHeight - 1];
    
    Vertex* firstVertexInLastRow = lastRow[0];
    Vertex* firstVertexInFirstRow = firstRow[0];
    Vertex* lastVertexInFirstRow = firstRow[_mapWidth - 1];
    Vertex* lastVertexInLastRow = lastRow[_mapWidth - 1];
    
    _tileHeight = ABS(firstVertexInFirstRow.vector.y - firstVertexInLastRow.vector.y);
    _tileWidth = ABS(lastVertexInFirstRow.vector.x - firstVertexInFirstRow.vector.x);
    
    _topLeft = firstVertexInFirstRow.vector;
    _topRight = lastVertexInFirstRow.vector;
    _bottomLeft = firstVertexInLastRow.vector;
    _bottomRight = lastVertexInLastRow.vector;
    
    _vertexList = [NSMutableArray new];
    NSMutableArray* _uvList = [NSMutableArray new];
    NSMutableArray* _indexList = [NSMutableArray new];
    NSMutableArray* _normalList = [NSMutableArray new];
    
    double maxX = 0.0;
    double maxY = 0.0;
    double minX = 0.0;
    double minY = 0.0;
    
    BOOL isFirstIterration = true;
    
    for (int y = 0 ; y < _mapHeight ; y++) {
        
        NSArray* row = vertexArray[y];
        NSMutableArray<Vector*>* vectorRow = [NSMutableArray new];
        for (int x = 0 ; x < _mapWidth ; x++) {
            Vertex* v = row[x];
            
            if (isFirstIterration) {
                
                maxX = v.vector.x;
                maxY = v.vector.y;
                minX = v.vector.x;
                minY = v.vector.y;
                
                isFirstIterration = false;
                
            } else {
                
                maxX = fmax(v.vector.x, maxX);
                maxY = fmax(v.vector.y, maxY);
                minX = fmin(v.vector.x, minX);
                minY = fmin(v.vector.y, minY);
            }
            
            [_vertexList addObject:@(v.vector.x)];
            [_vertexList addObject:@(v.vector.y)];
            [_vertexList addObject:@(v.vector.z)];
            
            _maxZ = MAX(v.vector.z, _maxZ);
            
            [_uvList addObject:@((x / ((double)row.count - 1)))];
            [_uvList addObject:@((((vertexArray.count - 1) - y) / ((double)vertexArray.count - 1)))];
        
            [_normalList addObject:@(v.normalVector.x)];
            [_normalList addObject:@(v.normalVector.y)];
            [_normalList addObject:@(v.normalVector.z)];
            
            [vectorRow addObject:v.vector];
        }

        [_vectorList addObject:vectorRow];
    }
    
    for (int i = 0; i <= _mapHeight - 2; i++) {
        for (int j = 0; j <= _mapWidth - 2; j++) {
            
            int t = j + i * _mapWidth;
            
            [_indexList addObject:@(t + _mapWidth + 1)];
            [_indexList addObject:@((t + 1))];
            [_indexList addObject:@(t)];
            
            [_indexList addObject:@(t + _mapWidth)];
            [_indexList addObject:@((t + _mapWidth + 1))];
            [_indexList addObject:@(t)];
            
        }
    }
    
    _vertexBuffer   = [GLHelper getBuffer:_vertexList];
    _uvBuffer       = [GLHelper getBuffer:_uvList];
    _indexBuffer    = [GLHelper getIndexBuffer:_indexList];
    _numVertices    = (int)_indexList.count;
    _normalBuffer   = [GLHelper getBuffer:_normalList];
    _boundingBox    = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    Vector* firstPoint = [[Vector alloc] initWithX:firstVertexInFirstRow.vector.x andY:firstVertexInFirstRow.vector.y];
    Vector* lastPoint = [[Vector alloc] initWithX:lastVertexInLastRow.vector.x andY:lastVertexInLastRow.vector.y];
    
    Vector* position = [VectorMath multipliedWithVector:([VectorMath addedWithVector1:lastPoint andVector2:firstPoint]) andFactor:0.5];
    
    _midX = -position.x;
    _midY = -position.y;
    _midZ = -(_tileHeight / 2) * tan((67.5) * M_PI / 180);
    
    _position = [[Vector alloc] initWithX:_midX andY:_midY andZ:_midZ];
    
}



-(Vector*)getPosition {
    return _position;
}

-(TextureQuality)getTextureQuality {
    return _textureQuality;
}

-(BOOL)setTextureQuality:(TextureQuality)q {
    
    if (_textureQuality == q) {
        
        return false;
    } else {
        
        _requestedTextureQuality = q;
        
        [self deleteTexture];
        
        if (q == TextureQualityNone) {
            
            return false;
        } else {
            
            [self prepareTexture];
            
            return true;
        }
    }
}

-(void)prepareAdditionalBuffersForCapture {

    glBindFramebuffer(GL_FRAMEBUFFER, _additionalTextureFrameBuffer);
    glViewport(0, 0, _viewportWidth, _viewportHeight);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    _hasAdditionalTexture = true;
    
    [_frustum updateFrustrumWithModelviewMatrix:self.modelViewMatrix andProjectionMatrix:self.projectionMatrix];
}

-(void)prepareBuffersForCapture {
    glBindFramebuffer(GL_FRAMEBUFFER, _textureFrameBuffer);
    [self checkError:@"30"];
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self checkError:@"31"];
//    NSLog(@"texture id $%d ", _textureName);
//    NSLog(@"_depthStensilTextureName id $%d ", _depthStensilTextureName);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureName, 0);
    [self checkError:@"32"];
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, _depthStensilTextureName, 0);
    [self checkError:@"33"];
    glViewport(0, 0, _viewportWidth, _viewportHeight);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [_frustum updateFrustrumWithModelviewMatrix:self.modelViewMatrix andProjectionMatrix:self.projectionMatrix];
}

-(Frustum*)captureTextureWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {

    effect.transform.modelviewMatrix = self.modelViewMatrix;
    effect.transform.projectionMatrix = self.projectionMatrix;
    
    [effect prepareToDraw];
    
    return _frustum;
}

-(void)endCapture {
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    
    
    _textureQuality = _requestedTextureQuality;
}


-(GLKMatrix4)modelViewMatrix {
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, _midX, _midY, _midZ);
    return modelViewMatrix;
}

-(GLKMatrix4)projectionMatrix {

    double w = _viewportWidth;
    double h = _viewportHeight;
    double zNear = 0.1;
    double zFar = 5000.0;
    double aspect = fabs(w/h);
    double fovy = 45.0;
    double top = zNear * tan(fovy * M_PI/360.0);
    double bottom = -top;
    double left = bottom * aspect;
    double right = top * aspect;
    
    return GLKMatrix4MakeFrustum(left, right, bottom, top, zNear, zFar);
}

- (void)prepareTexture {
    
    double maxTexSize = _requestedTextureQuality;
    
    if (_tileWidth > _tileHeight) {
        _viewportWidth  = maxTexSize;
        _viewportHeight = (_tileHeight * maxTexSize) / _tileWidth;
    } else {
        _viewportHeight = maxTexSize;
        _viewportWidth = (_tileWidth * maxTexSize) / _tileHeight;
    }
    
    int texSizeW = _viewportWidth;
    int texSizeH = _viewportHeight;
    
    glGenFramebuffers(1, &_textureFrameBuffer);
    [self checkError:@"1"];
    glBindFramebuffer(GL_FRAMEBUFFER, _textureFrameBuffer);
    [self checkError:@"2"];
    glGenRenderbuffers(1, &_renderBuffer);
    [self checkError:@"3"];
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self checkError:@"4"];
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, texSizeW, texSizeH);
    [self checkError:@"5"];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _renderBuffer);
    [self checkError:@"6"];
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    [self checkError:@"7"];
    
    
    glGenTextures(1, &_textureName);
    [self checkError:@"8"];
    glBindTexture(GL_TEXTURE_2D, _textureName);
    [self checkError:@"9"];
    [self setupTexture];
    [self checkError:@"10"];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texSizeW, texSizeH, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    [self checkError:@"11"];
    glBindTexture(GL_TEXTURE_2D, 0);
    [self checkError:@"12"];

    
    glGenTextures(1, &_depthStensilTextureName);
    [self checkError:@"13"];
    glBindTexture(GL_TEXTURE_2D, _depthStensilTextureName);
    [self checkError:@"14"];
    [self setupTexture];
    [self checkError:@"15"];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH24_STENCIL8, texSizeW, texSizeH, 0, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8,NULL);
    [self checkError:@"16"];
    glBindTexture(GL_TEXTURE_2D, 0);
    [self checkError:@"17"];
    
    
    GLenum status;
    
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if(status != GL_FRAMEBUFFER_COMPLETE) {
//        NSLog(@"status != GL_FRAMEBUFFER_COMPLETE");
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }else {
//        NSLog(@"status ==== GL_FRAMEBUFFER_COMPLETE");
    }
    
    glGenFramebuffers(1, &_additionalTextureFrameBuffer);
    [self checkError:@"18"];
    glGenTextures(1, &_additionalTextureName);
    [self checkError:@"19"];
    glBindFramebuffer(GL_FRAMEBUFFER, _additionalTextureFrameBuffer);
    [self checkError:@"20"];
    glBindTexture(GL_TEXTURE_2D, _additionalTextureName);
    [self checkError:@"21"];
    [self setupTexture];
    [self checkError:@"22"];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texSizeW, texSizeH, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    [self checkError:@"23"];
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _additionalTextureName, 0);
    [self checkError:@"24"];
    
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        
        glBindFramebuffer(GL_FRAMEBUFFER,0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }
}

-(void) checkError:(NSString *) who {
//    Boolean erro = glGetError() == GL_NO_ERROR;
//    NSLog( erro ? @"ALL OK" : @"SOME ERROR" );
//    NSLog(@"checkError called by %@", who);
}

-(void)deleteTexture {
    
    if (_textureFrameBuffer != 0) {
        glDeleteFramebuffers(1, &_textureFrameBuffer);
        _textureFrameBuffer = 0;
    }
    
    if(_renderBuffer !=0){
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }

    if (_textureName != 0) {
        glDeleteTextures(1, &_textureName);
        _textureName = 0;
    }
    
    if (_depthStensilTextureName != 0) {
        glDeleteTextures(1, &_depthStensilTextureName);
        _depthStensilTextureName = 0;
    }
    
    if (_additionalTextureFrameBuffer != 0) {
        glDeleteFramebuffers(1, &_additionalTextureFrameBuffer);
        _additionalTextureFrameBuffer = 0;
    }

    if (_additionalTextureName != 0) {
        glDeleteTextures(1, &_additionalTextureName);
        _additionalTextureName = 0;
    }
    
    _hasAdditionalTexture = false;
    
    _textureQuality = TextureQualityNone;
}

-(void) setupTexture {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

-(void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {
    
    if (_textureQuality == TextureQualityNone) {
        return;
        
    } else {

        effect.lightingType = GLKLightingTypePerVertex;
        
        effect.colorMaterialEnabled = GL_TRUE;
        
        effect.light0.enabled = GL_TRUE;
        effect.light0.position = _lightPosition;
        
        effect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1);
        effect.light0.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
        effect.light0.ambientColor = GLKVector4Make(0.3, 0.3, 0.3, 1);
         
        
        effect.texture2d0.enabled = true;
        effect.texture2d0.name = _textureName;
        effect.texture2d0.envMode = GLKTextureEnvModeModulate;
        
        [effect prepareToDraw];
        
        
        
        [GLHelper drawVertexBuffer:_vertexBuffer andIndexBuffer:_indexBuffer andTexCoordBuffer:_uvBuffer andNormalBuffer:_normalBuffer andMode:GL_TRIANGLES andCount:_numVertices];

        effect.light0.enabled = GL_FALSE;
        effect.colorMaterialEnabled = GL_FALSE;
    }
}

-(void)additionalRenderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {
    
    if (_textureQuality == TextureQualityNone || !_hasAdditionalTexture) {
        
        return;
        
    } else {
    
        effect.lightingType         = GLKLightingTypePerVertex;
        
        effect.colorMaterialEnabled = GL_TRUE;
        
        effect.light0.enabled       = GL_TRUE;
        effect.light0.position      = _lightPosition;
        
        effect.light0.diffuseColor  = GLKVector4Make(0.7, 0.7, 0.7, 1);
        effect.light0.specularColor = GLKVector4Make(0.1, 0.1, 0.1, 1);
        effect.light0.ambientColor  = GLKVector4Make(0.3, 0.3, 0.3, 1);
        
        effect.texture2d0.enabled   = true;
        effect.texture2d0.name      = _additionalTextureName;
        effect.texture2d0.envMode   = GLKTextureEnvModeModulate;
        
        [effect prepareToDraw];
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        [GLHelper drawVertexBuffer:_vertexBuffer andIndexBuffer:_indexBuffer andTexCoordBuffer:_uvBuffer andNormalBuffer:_normalBuffer andMode:GL_TRIANGLES andCount:_numVertices];
        
        effect.light0.enabled = GL_FALSE;
        effect.colorMaterialEnabled = GL_FALSE;
    }
}

-(Vector*)topLeft {
    return _topLeft;
}

-(Vector*)topRight {
    return _topRight;
}

-(Vector*)bottomLeft {
    return _bottomLeft;
}

-(Vector*)bottomRight {
    return _bottomRight;
}

-(CGRect)boundingBox {
    return _boundingBox;
}

-(NSArray<NSArray<Vector*>*>*)getVector2DList {
    return _vectorList;
}

-(void)clean {
    
    [self deleteTexture];
}

@end
