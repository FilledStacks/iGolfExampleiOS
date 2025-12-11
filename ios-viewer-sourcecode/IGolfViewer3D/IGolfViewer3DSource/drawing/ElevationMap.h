//
//  ElevationMap.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "TextureProfile.h"
#import "Camera.h"
#import "TextureQuality.h"
#import "Bunker3D.h"
#import "DrawTile.h"


@class Camera;
@class Vector;
@class Bunker3D;
@class DrawTile;
@class TextureProfile;

@interface ElevationMap : NSObject

-(id)initWithJsonObject:(NSDictionary*)jsonObject andTextureQuality:(TextureQuality)textureQuality andTextureProfile:(TextureProfile*)textureProfile;

-(NSMutableArray*)getTilesForRedraw;
-(NSMutableArray*)getVertex2DArray;

-(GLKVector4)lightPosition;

-(double)getZPositionForLocation:(CLLocation*)location;
-(double)getZForPointX:(double)uX andY:(double)uY;

-(void)clearRedrawTiles;
-(void)setCurrentTileWithPosition:(Vector*)position andCamera:(Camera*)camera;
-(void)clean;
-(NSMutableArray*)getTiles;
-(NSArray<DrawTile*>*)getCurrentTiles;
-(void)renderBorderTilesWithEffect:(GLKBaseEffect *)effect isFlyover:(BOOL) isFlyover;
-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera*)camera andDepthFunk:(GLenum)depthFunc;
-(void)renderTilesWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
-(void)additionalRenderTilesWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
@end
