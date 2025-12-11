//
//  BorderTile.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import <TextureProfile.h>

@class TextureProfile;

@interface BorderTile : NSObject

-(id)initWithVertexArray:(NSArray *)vertexArray andLightPosition:(GLKVector4)lightPosition andTextureProfile:(TextureProfile*)textureProfile;
-(void)renderWithEffect:(GLKBaseEffect *)effect isFlyover:(BOOL)isFlyover;

@end
