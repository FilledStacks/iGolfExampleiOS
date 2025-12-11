//
//  Ray.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@implementation Ray


- (id)initWithTouchX:(int)touchX andTouchY:(int)touchY andCamera:(Camera*)camera {
    self = [super init];
    
    if (self) {

        int viewport[4] = {camera.viewportXOffset, 0, camera.viewport.size.width, camera.viewport.size.height};

        GLKVector3 nearCoords = GLKVector3Make(0, 0, 0);
        GLKVector3 farCoords = GLKVector3Make(0, 0, 0);
        GLKVector4 temp;
        GLKVector4 temp2;

        float winx = touchX;
        float winy = viewport[3] - touchY;

        GLKMatrix4 modelViewMatrix = camera.modelViewMatrix;
        GLKMatrix4 projectionMatrix = camera.projectionMatrix;
        BOOL success = NO;

        temp = GLKVector4MakeWithVector3(GLKMathUnproject(GLKVector3Make(winx, winy, 1), modelViewMatrix, projectionMatrix, viewport, &success), 1);
        temp2 = GLKMatrix4MultiplyVector4(modelViewMatrix, temp);
        

        if (success) {
            nearCoords.x = temp2.x / temp2.w;
            nearCoords.y = temp2.y / temp2.w;
            nearCoords.z = temp2.z / temp2.w;
        }
        temp = GLKVector4MakeWithVector3(GLKMathUnproject(GLKVector3Make(winx, winy, 0), modelViewMatrix, projectionMatrix, viewport, &success), 1);
        temp2 = GLKMatrix4MultiplyVector4(modelViewMatrix, temp);
        
        if (success) {
            farCoords.x = temp2.x / temp2.w;
            farCoords.y = temp2.y / temp2.w;
            farCoords.z = temp2.z / temp2.w;
        }

        self->P0[0] = farCoords.x;
        self->P0[1] = farCoords.y;
        self->P0[2] = farCoords.z;

        self->P1[0] = nearCoords.x;
        self->P1[1] = nearCoords.y;
        self->P1[2] = nearCoords.z;
    }
    
    return self;
}

- (id)initForLineFlagWith:(int)touchX andTouchY:(int)touchY andCamera:(Camera*)camera andMatrix:(GLKMatrix4) modelViewMatrix {
    self = [super init];
    
    if (self) {
        
        
        

        int viewport[4] = {camera.viewportXOffset, 0, camera.viewport.size.width, camera.viewport.size.height};

        GLKVector3 nearCoords = GLKVector3Make(0, 0, 0);
        GLKVector3 farCoords = GLKVector3Make(0, 0, 0);
        GLKVector4 temp;
        GLKVector4 temp2;

        float winx = touchX;
        float winy = viewport[3] - touchY;

        GLKMatrix4 projectionMatrix = camera.projectionMatrix;
        BOOL success = NO;

        temp = GLKVector4MakeWithVector3(GLKMathUnproject(GLKVector3Make(winx, winy, 1), modelViewMatrix, projectionMatrix, viewport, &success), 1);
        temp2 = GLKMatrix4MultiplyVector4(modelViewMatrix, temp);
        

        if (success) {
            nearCoords.x = temp2.x / temp2.w;
            nearCoords.y = temp2.y / temp2.w;
            nearCoords.z = temp2.z / temp2.w;
        }
        temp = GLKVector4MakeWithVector3(GLKMathUnproject(GLKVector3Make(winx, winy, 0), modelViewMatrix, projectionMatrix, viewport, &success), 1);
        temp2 = GLKMatrix4MultiplyVector4(modelViewMatrix, temp);
        
        if (success) {
            farCoords.x = temp2.x / temp2.w;
            farCoords.y = temp2.y / temp2.w;
            farCoords.z = temp2.z / temp2.w;
        }

        self->P0[0] = farCoords.x;
        self->P0[1] = farCoords.y;
        self->P0[2] = farCoords.z;

        self->P1[0] = nearCoords.x;
        self->P1[1] = nearCoords.y;
        self->P1[2] = nearCoords.z;
    }
    
    return self;
}

@end
