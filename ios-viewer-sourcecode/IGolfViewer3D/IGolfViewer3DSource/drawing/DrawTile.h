//
//  DrawTile.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"
#import "TextureQuality.h"


@class Frustum;
@class Vertex;

@interface DrawTile : NSObject

@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithVertexArray:(NSArray*)vertexArray andLightPosition:(GLKVector4)lightPosition;

- (Frustum*)captureTextureWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)prepareBuffersForCapture;
- (void)prepareAdditionalBuffersForCapture;
- (void)endCapture;
- (TextureQuality)getTextureQuality;
- (BOOL)setTextureQuality:(TextureQuality)q;
- (void)clean;

- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)additionalRenderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (Vector*)getPosition;
- (NSArray*)getVertexList;
- (NSArray<NSArray<Vector*>*>*)getVector2DList;
- (NSArray<NSArray<Vertex*>*>*)getVertexArray;

@end
