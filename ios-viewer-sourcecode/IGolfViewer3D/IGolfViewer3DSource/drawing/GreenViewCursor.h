//
//  GreenViewCursor.h
//  IGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

NS_ASSUME_NONNULL_BEGIN

@class Camera;
@class Vector;

@interface GreenViewCursor : NSObject

@property (nonatomic, readonly) CLLocation* location;
@property (nonatomic, assign, nullable) Vector* position;
@property (nonatomic, readonly) BOOL hasFocus;

- (id)initWithCursorTextureFilePath:(NSString*)cursorTexture andVertexbuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (BOOL)onTouchDown:(Vector*)coordinate andCamera:(Camera*)camera;
- (BOOL)onTouchMove:(Vector*)coordinate;
- (BOOL)onTouchUp:(Vector*)coordinate;
- (void)destroy;

@end

NS_ASSUME_NONNULL_END




