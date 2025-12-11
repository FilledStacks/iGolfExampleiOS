//
//  TexturedPolygon.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class GLKTextureInfo;

@interface TexturedPolygon : NSObject

@property (nonatomic, retain) GLKTextureInfo* texture;

- (id)initWithTexture:(GLKTextureInfo*)texture andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer;
- (void)renderWithEffect:(GLKBaseEffect*)effect;
- (void)destroy;

@end
