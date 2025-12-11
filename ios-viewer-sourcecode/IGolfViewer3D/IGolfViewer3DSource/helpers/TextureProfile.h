//
//  TextureProfile.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "../IGolfViewer3DPrivateImports.h"
#import "TextureType.h"

@interface TextureProfile : NSObject

@property (nonatomic, readonly) NSString* backgroundTexture2DName;
@property (nonatomic, readonly) NSString* backgroundTexture3DName;
@property (nonatomic, readonly) NSString* perimeterTextureName;
@property (nonatomic, readonly) NSString* flyoverTextureName;


- (id)initWithTextureType:(TextureType)type;
+ (TextureType)determineTextureTypeWithVectorData:(NSDictionary*)data;
- (NSMutableArray<GLKTextureInfo*>*) getDefaultTreeTextureSet;
- (NSMutableArray<GLKTextureInfo*>*) getDefaultTreeShadowTextureSet;
- (NSMutableArray<GLKTextureInfo*>*) getEvergreenTreeTextureSet;
- (NSMutableArray<GLKTextureInfo*>*) getEvergreenTreeShadowTextureSet;
@end
