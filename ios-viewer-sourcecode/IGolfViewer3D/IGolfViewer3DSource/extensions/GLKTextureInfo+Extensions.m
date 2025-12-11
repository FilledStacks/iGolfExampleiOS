//
//  GLKTextureInfo+Extensions.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "GLKTextureInfo+Extensions.h"

static NSMutableDictionary<NSString*, GLKTextureInfo*>* GLKTextureInfo_textureCache;
static GLuint maxTextureIndex = 0;


@implementation GLKTextureInfo (Extensions)

+ (GLKTextureInfo*)loadFromCacheWithFilePath:(NSString*)filePath {
    
    if (GLKTextureInfo_textureCache == nil) {
        GLKTextureInfo_textureCache = [NSMutableDictionary new];
    }
    
    GLKTextureInfo* retval = [GLKTextureInfo_textureCache objectForKey:filePath];
    if (retval == nil) {
        retval = [self loadTextureWithFilePath:filePath];
    }
    
    return retval;
}

+ (GLKTextureInfo*)loadTextureWithFilePath:(NSString*)filePath {
    
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:nil];
    
    if (texture != nil) {
        [GLKTextureInfo_textureCache setObject:texture forKey:filePath];
    }
    
    maxTextureIndex = MAX(maxTextureIndex, texture.name);
    
    return texture;
}

+ (void)releaseAll {
    
    GLKTextureInfo_textureCache = nil;
    
    for (int i = 0; i < maxTextureIndex; i++) {
        GLuint tex_id = i;
        glDeleteTextures(1, &tex_id);
    }
    
    
}

- (void)releaseTexture {
    GLuint tex_id = self.name;
    glDeleteTextures(1, &tex_id);
}

@end
