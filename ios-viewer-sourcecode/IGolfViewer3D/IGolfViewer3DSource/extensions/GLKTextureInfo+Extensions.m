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

    NSLog(@"🔍 [IGolfViewer3D] Attempting to load texture from path: %@", filePath);

    if (GLKTextureInfo_textureCache == nil) {
        GLKTextureInfo_textureCache = [NSMutableDictionary new];
        NSLog(@"📦 [IGolfViewer3D] Texture cache initialized");
    }

    GLKTextureInfo* retval = [GLKTextureInfo_textureCache objectForKey:filePath];
    if (retval == nil) {
        NSLog(@"⚠️ [IGolfViewer3D] Texture not in cache, loading from disk...");
        retval = [self loadTextureWithFilePath:filePath];
    } else {
        NSLog(@"✅ [IGolfViewer3D] Texture found in cache!");
    }

    return retval;
}

+ (GLKTextureInfo*)loadTextureWithFilePath:(NSString*)filePath {

    if (filePath == nil || filePath.length == 0) {
        NSLog(@"❌ [IGolfViewer3D] ERROR: filePath is nil or empty!");
        NSLog(@"🚨 [IGolfViewer3D] This will cause a crash when added to NSMutableArray!");
        return nil;
    }

    NSLog(@"📂 [IGolfViewer3D] Full file path: %@", filePath);

    // Check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSLog(@"❌ [IGolfViewer3D] ERROR: File does NOT exist at path: %@", filePath);
        NSLog(@"🚨 [IGolfViewer3D] Texture loading will fail!");
    } else {
        NSLog(@"✅ [IGolfViewer3D] File exists at path");
    }

    NSError *error = nil;
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&error];

    if (texture != nil) {
        NSLog(@"✅ [IGolfViewer3D] Texture loaded successfully! Name: %u", texture.name);
        [GLKTextureInfo_textureCache setObject:texture forKey:filePath];
        maxTextureIndex = MAX(maxTextureIndex, texture.name);
    } else {
        NSLog(@"❌ [IGolfViewer3D] ERROR: Failed to load texture from: %@", filePath);
        if (error != nil) {
            NSLog(@"❌ [IGolfViewer3D] Error details: %@", error.localizedDescription);
        }
        NSLog(@"🚨 [IGolfViewer3D] Returning nil - this will cause crash if added to NSMutableArray!");
    }

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
