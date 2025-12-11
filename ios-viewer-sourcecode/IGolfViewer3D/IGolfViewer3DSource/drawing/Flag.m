//
//  Flag.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Flag.h"
#import <CoreLocation/CoreLocation.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"


Flag* instance;

@interface Flag () {
    TexturedPolygon* _polygon;
    Vector* _position;
    ElevationMap* _grid;
    double _scale;
    double _zPosition;
    CLLocation* _location;
}

@end

@implementation Flag

+(Flag*)INSTANCE {
    return instance;
}

- (void)setFlagPosition:(Vector*)flagPosition {
    _position = flagPosition;
}

- (Vector*)flagPosition {
    return _position;
}

-(CLLocation *)location {
    return _location;
}

-(id)initWithTextureFilename:(NSString *)textureFilename andPosition:(Vector *)position andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer {
    self = [super init];

    self->_polygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:textureFilename] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_position = position;

    self->_scale = 0.3 * METERS_IN_POINT;
    
    double lat = [Layer transformToLatWithDouble:position.y];
    double lon = [Layer transformToLonWithDouble:position.x];
    
    self->_location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    
    instance = self;
    
    return self;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    camera.navigationMode == NavigationMode2DView || camera.navigationMode == NavigationMode2DGreenView ? [self render2DWithEffect:effect andCamera:camera] : [self render3DWithEffect:effect andCamera:camera];
}


- (void)render3DWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {
    
    if ([camera.frustum isPointVisibleWithX:_position.x andY:_position.y andZ:_position.z]) {
        
        double scale = 3 * METERS_IN_POINT;
        scale *= 0.9;
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:90], 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 1, 0);
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale, scale, scale);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
        
        effect.transform.modelviewMatrix = modelViewMatrix;
        [effect prepareToDraw];
        
        [_polygon renderWithEffect:effect];
        
    }
    
    [GLHelper getObjectScreenCoordinate:_position camera:camera];
}

- (void)calculateMatricesWithCamera:(Camera*)camera {
    
    GLKMatrix4 modelView = GLKMatrix4Identity;
    modelView = GLKMatrix4Translate(modelView, 0, 0, camera.z);
    modelView = GLKMatrix4Rotate(modelView, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelView = GLKMatrix4Rotate(modelView, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelView = GLKMatrix4Translate(modelView, camera.x + _position.x, camera.y + _position.y, _position.z);
    
    GLKVector4 vertex = GLKMatrix4MultiplyVector4(modelView, GLKVector4Make(0, 0, 0, 1));
    _zPosition = vertex.z / vertex.w;

}

- (double)zPosition {
    return _zPosition;
}

- (void)render2DWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera {

    CGFloat _flagScale = MAX(4 * METERS_IN_POINT, fabs(camera.z * _scale));
    _flagScale *= 0.95;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _flagScale, _flagScale, _flagScale);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_polygon renderWithEffect:effect];

}

@end
