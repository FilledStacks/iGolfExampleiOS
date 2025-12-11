//
//  GLKTextureInfo+Extensions.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLKTextureInfo (Extensions)

+ (GLKTextureInfo*)loadFromCacheWithFilePath:(NSString*)filePath;
- (void)releaseTexture;
+ (void)releaseAll;

@end
