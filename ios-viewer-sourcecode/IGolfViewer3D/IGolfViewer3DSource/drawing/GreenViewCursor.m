//
//  GreenViewCursor.m
//  IGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "GreenViewCursor.h"

#import <OpenGLES/ES3/gl.h>
#import "../IGolfViewer3DPrivateImports.h"

#define CALLOUT_SCALE 0.03
#define LOCATION_SCALE 0.023
#define CURSOR_SCALE 0.025
#define DISTANCE_LABEL_SCALE 0.018


@interface GreenViewCursor () {

    TexturedPolygon* _cursorPolygon;
    
    BOOL _hasFocus;
    Vector* _position;
}

@end

@implementation GreenViewCursor


- (BOOL)hasFocus {
    return _hasFocus;
}


- (id)initWithCursorTextureFilePath:(NSString*)cursorTexture andVertexbuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer {
    self = [super init];
    
    if (self) {
        self->_cursorPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:cursorTexture] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    }
    
    return self;
}

- (Vector *)position {
    return _position;
}

- (CLLocation *)location {
    double lat = [Layer transformToLatWithDouble:_position.y];
    double lon = [Layer transformToLonWithDouble:_position.x];
    return [[CLLocation alloc] initWithLatitude:lat longitude:lon];
}

- (void)setPosition:(Vector *)position {
    _position = position;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    if (camera.navigationMode != NavigationMode2DGreenView || _position == nil) {
        return;
    }
    
    CGFloat _cursorScale = fabs(camera.z * CURSOR_SCALE);
    
    GLKMatrix4 modelViewMatrix3 = GLKMatrix4Identity;
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, 0, 0, camera.z);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, camera.x + _position.x, camera.y + _position.y, 0);
    modelViewMatrix3 = GLKMatrix4Scale(modelViewMatrix3, _cursorScale, _cursorScale, _cursorScale);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    effect.transform.modelviewMatrix = modelViewMatrix3;
    [effect prepareToDraw];
    
    [_cursorPolygon renderWithEffect:effect];
}

- (BOOL)onTouchDown:(Vector*)coordinate andCamera:(Camera*)camera {
    
    if (camera.navigationMode != NavigationMode2DGreenView) {
        return false;
    }
    
    double distance = [coordinate distanceWithVector: _position];
    
    if (distance < fabs(camera.z) * 0.03) {
        _hasFocus = true;
        return YES;
    }
    
    return NO;
}

- (BOOL)onTouchMove:(Vector*)coordinate {
    
    _position = coordinate;
    
    return YES;
}

- (BOOL)onTouchUp:(Vector*)coordinate {
    _hasFocus = NO;
    return YES;
}

- (void)destroy {
    
    [_cursorPolygon destroy];
}


@end
