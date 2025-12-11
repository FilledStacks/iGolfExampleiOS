//
//  Tree.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <OpenGLES/ES3/gl.h>

#import "Tree.h"
#import "../IGolfViewer3DPrivateImports.h"

@interface Tree() {
    float _zPosition;
    float _yPozition;
    
    Vector* _position;
    TexturedPolygon3D* _treePolygon;
    TexturedPolygon* _treePolygon2d;
    TexturedPolygon* _shadowPolygon;
    
    float _additionalRoration;
}

@property (nonatomic, readonly) float ShadowOpacity;

@end

@implementation Tree

- (float)ShadowOpacity {
    return 35 / 100.0;
}

- (id)init {
    self = [super init];
    
    self->_zPosition = 0;
    self->_yPosition = 0;
    self->_scale = 20 * METERS_IN_POINT;
    
    return self;
}

- (id)initWithTreeTexure3D:(GLKTextureInfo*)treeTexture3D
          andShadowtexture:(GLKTextureInfo*)shadowTexture
               andPosition:(Vector*)position
         andVertexBuffer3D:(GLuint)vertexBuffer3D
             andUVBuffer3D:(GLuint)uvBuffer3D
           andVertexBuffer:(GLuint)vertexBuffer
               andUVBuffer:(GLuint)uvBuffer {
    self = [super init];
    self->_position = position;
    self->_treePolygon = [[TexturedPolygon3D alloc] initWithTexture:treeTexture3D andVertexBuffer:vertexBuffer3D andUVBuffer:uvBuffer3D];
    self->_shadowPolygon = [[TexturedPolygon alloc] initWithTexture:shadowTexture andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_additionalRoration = rand() % 90;

    return self;
}

-(CLLocationCoordinate2D)getCoordinate {
    return [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:_position.y] longitude:[Layer transformToLonWithDouble:_position.x]].coordinate;
}

- (void)drawTree3DWithWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    double additionalScale = 0.3;
    
    if ([camera.frustum isSphereVisibleWithX:_position.x andY:_position.y andZ:_position.z andR:0.3]) {
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:90], 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:_additionalRoration], 0, 1, 0);
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, additionalScale * _scale, additionalScale * _scale, additionalScale * _scale);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
        
        effect.transform.modelviewMatrix = modelViewMatrix;
        [effect prepareToDraw];

        [_treePolygon renderWithEffect:effect];
    }
}

- (void)calculatePositionWithCamera:(Camera*)camera {
    GLKMatrix4 mvp = GLKMatrix4Identity;
    mvp = GLKMatrix4Translate(mvp, 0, 0, camera.z);
    mvp = GLKMatrix4Rotate(mvp, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    mvp = GLKMatrix4Rotate(mvp, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    mvp = GLKMatrix4Translate(mvp, camera.x + _position.x, camera.y + _position.y, _position.z);
    mvp = GLKMatrix4Multiply(camera.projectionMatrix, mvp);

    GLKVector4 vertex = GLKMatrix4MultiplyVector4(mvp, GLKVector4Make(0, 0, 0, 1));
    _zPosition = vertex.z / vertex.w;
    _yPosition = vertex.y / vertex.w;
}


-(void)drawShadowForPosition:(Vector*)position andEffect:(GLKBaseEffect *)effect andFrustum:(Frustum*)frustum {
    
   if ([frustum isCubeVisibleWithX:_position.x y:_position.y z:0 xSize:1.0 ySize:1.0 zSize:1.0]) {
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, position.z);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x + _position.x, position.y + _position.y, 0);
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.3 * _scale, 0.3 * _scale, 0.3 * _scale);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
        
        effect.transform.modelviewMatrix = modelViewMatrix;
        [effect prepareToDraw];
        
        [_shadowPolygon renderWithEffect:effect];
    }
}

-(void)drawShadowWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    if (camera.navigationMode == NavigationMode2DView || camera.navigationMode == NavigationMode2DGreenView) {
        return;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z + 0.02);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.3 * _scale, 0.3 * _scale, 0.3 * _scale);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    
    
    [_shadowPolygon renderWithEffect:effect];
    
}

-(void)drawTreeWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    camera.navigationMode == NavigationMode2DView || camera.navigationMode == NavigationMode2DGreenView ? [self drawTree2DWithEffect:effect andCamera:camera] : [self drawTree3DWithWithEffect:effect andCamera:camera];
}

- (void)drawTree2DWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.3 * _scale, 0.3 * _scale, 0.3 * _scale);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_treePolygon renderWithEffect:effect];
}

@end
