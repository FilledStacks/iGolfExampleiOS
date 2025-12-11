//
//  CartPositionMarker.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>
#import "../IGolfViewer3DPrivateImports.h"


@interface CartPositionMarker : NSObject

@property (nonatomic, readonly) int cartId;

- (id)initWithCartName:(NSString*)name andId:(int)cartId andLocation:(CLLocation*)location andUVBuffer:(GLuint)uvBuffer andVertexbuffer:(GLuint)vertexBuffer;
- (void)renderWithCamera:(Camera*)camera andEffect:(GLKBaseEffect*)effect;
- (void)updateLocation:(CLLocation*)location;

@end
