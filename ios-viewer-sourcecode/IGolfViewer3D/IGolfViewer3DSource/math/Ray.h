//
//  Ray.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class Camera;

@interface Ray : NSObject {
    
@public
    float P0[3];
    float P1[3];
}

- (id)initWithTouchX:(int)touchX andTouchY:(int)touchY andCamera:(Camera*)camera;

- (id)initForLineFlagWith:(int)touchX andTouchY:(int)touchY andCamera:(Camera*)camera andMatrix:(GLKMatrix4) modelViewMatrix;

@end
