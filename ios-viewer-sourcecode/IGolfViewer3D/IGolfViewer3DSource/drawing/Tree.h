//
//  Tree.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"

@class Camera;
@class Vector;
@class GLKTextureInfo;

@interface Tree : NSObject

@property (nonatomic, assign) float scale;
@property (nonatomic, readonly) float zPosition;
@property (nonatomic, readonly) float yPosition;

- (id)initWithTreeTexure3D:(GLKTextureInfo*)treeTexture3D
          andShadowtexture:(GLKTextureInfo*)shadowTexture
               andPosition:(Vector*)position
         andVertexBuffer3D:(GLuint)vertexBuffer3D
             andUVBuffer3D:(GLuint)uvBuffer3D
           andVertexBuffer:(GLuint)vertexBuffer
               andUVBuffer:(GLuint)uvBuffer;

- (void)calculatePositionWithCamera:(Camera*)camera;
- (void)drawShadowWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)drawTreeWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)drawTree3DWithWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera;
- (void)drawShadowForPosition:(Vector*)position andEffect:(GLKBaseEffect *)effect andFrustum:(Frustum*)frustum;
- (CLLocationCoordinate2D)getCoordinate;

@end
