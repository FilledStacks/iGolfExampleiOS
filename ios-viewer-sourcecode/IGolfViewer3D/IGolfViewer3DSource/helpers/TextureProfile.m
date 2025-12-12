//
//  TextureProfile.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import "TextureProfile.h"
#import "TextureType.h"
#import "../IGolfViewer3DPrivateImports.h"


@interface TextureProfile() {
    
    TextureType _type;
}

@end

@implementation TextureProfile

+(TextureType)determineTextureTypeWithVectorData:(NSDictionary*)data {
    
    TextureType retval = TextureTypeRough;
    
    NSDictionary* backgroundObject = [data valueForKey:@"Background"];
    NSDictionary* shapesObject = [backgroundObject valueForKey:@"Shapes"];
    NSArray* shapeArray = [shapesObject valueForKey:@"Shape"];
    
    if (shapeArray != nil){
        if (shapeArray.count != 0) {
            NSDictionary* shape = [shapeArray objectAtIndex:0];
            NSDictionary* attributes = [shape valueForKey:@"Attributes"];
            NSNumber* description = [attributes valueForKey:@"Description"];
            int type = [description intValue];
            if (type == 2) {
                retval = TextureTypeMixedDesert;
            }
        }
    }
    
    return retval;
}


-(NSString *)backgroundTexture2DName {
    NSString * retval = @"v3d_background";
    
    if (_type == TextureTypeDesert || _type == TextureTypeMixedDesert) {
        retval = [retval stringByAppendingString:@"_desert"];
    }
    
    return retval;
}

-(NSString *)backgroundTexture3DName {
    NSString * retval = @"v3d_gpsmap_background";
    
    if (_type == TextureTypeDesert || _type == TextureTypeMixedDesert) {
        retval = @"v3d_background";
        retval = [retval stringByAppendingString:@"_desert"];
    }
    
    return retval;
}

-(NSString *)perimeterTextureName {
    NSString * retval;
    
    switch (_type) {
        case TextureTypeDesert:
            retval = self.backgroundTexture2DName;
            break;
        default:retval = @"v3d_gpsmap_background";
            break;
    }
    
    return retval;
}

-(NSString *)flyoverTextureName {
    NSString * retval = @"v3d_gpsmap_background";
    
    if (_type == TextureTypeDesert || _type == TextureTypeMixedDesert) {
        retval = @"v3d_background";
        retval = [retval stringByAppendingString:@"_desert"];
    }
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getEvergreenTreeTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    switch (_type) {
        case TextureTypeRough:
            //[retval addObjectsFromArray:[self getDeciduousTreeTextureSet]];
            [retval addObjectsFromArray:[self _getEvergreenTreeTextureSet]];
            break;
            
        default:
            [retval addObjectsFromArray:[self getDeciduousTreeTextureSet]];
            [retval addObjectsFromArray:[self getDesertTreeTextureSet]];
            break;
    }
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getEvergreenTreeShadowTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    switch (_type) {
        case TextureTypeRough:
            //[retval addObjectsFromArray:[self getDeciduousTreeShadowTextureSet]];
            [retval addObjectsFromArray:[self _getEvergreenTreeShadowTextureSet]];
            break;
            
        default:
            [retval addObjectsFromArray:[self getDeciduousTreeShadowTextureSet]];
            [retval addObjectsFromArray:[self getDesertTreeShadowTextureSet]];
            break;
    }
    
    return retval;
}



-(NSMutableArray<GLKTextureInfo*>*) getDefaultTreeTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    switch (_type) {
        case TextureTypeRough:
            [retval addObjectsFromArray:[self getDeciduousTreeTextureSet]];
            //[retval addObjectsFromArray:[self getEvergreenTreeTextureSet]];
            break;
            
        default:
            [retval addObjectsFromArray:[self getDeciduousTreeTextureSet]];
            [retval addObjectsFromArray:[self getDesertTreeTextureSet]];
            break;
    }
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getDefaultTreeShadowTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    switch (_type) {
        case TextureTypeRough:
            [retval addObjectsFromArray:[self getDeciduousTreeShadowTextureSet]];
            //[retval addObjectsFromArray:[self getEvergreenTreeShadowTextureSet]];
            break;
            
        default:
            [retval addObjectsFromArray:[self getDeciduousTreeShadowTextureSet]];
            [retval addObjectsFromArray:[self getDesertTreeShadowTextureSet]];
            break;
    }
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getDeciduousTreeTextureSet {

    NSLog(@"🌳 [IGolfViewer3D] Loading deciduous tree texture set...");
    NSLog(@"📍 [IGolfViewer3D] Main bundle path: %@", [[NSBundle mainBundle] bundlePath]);

    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];

    for (int i = 1; i <= 5; i++) {
        NSString *resourceName = [NSString stringWithFormat:@"v3d_tree_%d", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];

        NSLog(@"🔎 [IGolfViewer3D] Looking for resource: %@.png", resourceName);
        NSLog(@"🔎 [IGolfViewer3D] Path returned by bundle: %@", path ? path : @"(nil)");

        GLKTextureInfo *texture = [GLKTextureInfo loadFromCacheWithFilePath:path];
        if (texture != nil) {
            [retval addObject:texture];
        } else {
            NSLog(@"❌ [IGolfViewer3D] SKIPPING nil texture for %@.png - would cause crash!", resourceName);
        }
    }

    NSLog(@"🌳 [IGolfViewer3D] Loaded %lu/%d deciduous tree textures", (unsigned long)retval.count, 5);

    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getDeciduousTreeShadowTextureSet {

    NSLog(@"🌲 [IGolfViewer3D] Loading deciduous tree shadow texture set...");
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];

    for (int i = 1; i <= 5; i++) {
        NSString *resourceName = [NSString stringWithFormat:@"v3d_tree_%d_shadow", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
        NSLog(@"🔎 [IGolfViewer3D] Looking for: %@.png -> %@", resourceName, path ? path : @"(nil)");

        GLKTextureInfo *texture = [GLKTextureInfo loadFromCacheWithFilePath:path];
        if (texture != nil) {
            [retval addObject:texture];
        } else {
            NSLog(@"❌ [IGolfViewer3D] SKIPPING nil texture - would cause crash!");
        }
    }

    NSLog(@"🌲 [IGolfViewer3D] Loaded %lu/%d shadow textures", (unsigned long)retval.count, 5);
    return retval;
}



-(NSMutableArray<GLKTextureInfo*>*) getDesertTreeTextureSet {

    NSLog(@"🏜️ [IGolfViewer3D] Loading desert tree texture set...");
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];

    for (int i = 1; i <= 4; i++) {
        NSString *resourceName = [NSString stringWithFormat:@"v3d_tree_%d_desert", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
        NSLog(@"🔎 [IGolfViewer3D] Looking for: %@.png -> %@", resourceName, path ? path : @"(nil)");

        GLKTextureInfo *texture = [GLKTextureInfo loadFromCacheWithFilePath:path];
        if (texture != nil) {
            [retval addObject:texture];
        } else {
            NSLog(@"❌ [IGolfViewer3D] SKIPPING nil texture - would cause crash!");
        }
    }

    NSLog(@"🏜️ [IGolfViewer3D] Loaded %lu/%d desert tree textures", (unsigned long)retval.count, 4);
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getDesertTreeShadowTextureSet {

    NSLog(@"🏜️ [IGolfViewer3D] Loading desert tree shadow texture set...");
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];

    for (int i = 1; i <= 4; i++) {
        NSString *resourceName = [NSString stringWithFormat:@"v3d_tree_%d_shadow_desert", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
        NSLog(@"🔎 [IGolfViewer3D] Looking for: %@.png -> %@", resourceName, path ? path : @"(nil)");

        GLKTextureInfo *texture = [GLKTextureInfo loadFromCacheWithFilePath:path];
        if (texture != nil) {
            [retval addObject:texture];
        } else {
            NSLog(@"❌ [IGolfViewer3D] SKIPPING nil texture - would cause crash!");
        }
    }

    NSLog(@"🏜️ [IGolfViewer3D] Loaded %lu/%d desert shadow textures", (unsigned long)retval.count, 4);
    return retval;
}



-(NSMutableArray<GLKTextureInfo*>*) _getEvergreenTreeTextureSet {

    NSLog(@"🌲 [IGolfViewer3D] Loading evergreen tree texture set...");
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];

    for (int i = 1; i <= 6; i++) {
        NSString *resourceName = [NSString stringWithFormat:@"v3d_evergreen_tree_%d", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
        NSLog(@"🔎 [IGolfViewer3D] Looking for: %@.png -> %@", resourceName, path ? path : @"(nil)");

        GLKTextureInfo *texture = [GLKTextureInfo loadFromCacheWithFilePath:path];
        if (texture != nil) {
            [retval addObject:texture];
        } else {
            NSLog(@"❌ [IGolfViewer3D] SKIPPING nil texture - would cause crash!");
        }
    }

    NSLog(@"🌲 [IGolfViewer3D] Loaded %lu/%d evergreen tree textures", (unsigned long)retval.count, 6);
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) _getEvergreenTreeShadowTextureSet {

    NSLog(@"🌲 [IGolfViewer3D] Loading evergreen tree shadow texture set...");
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];

    for (int i = 1; i <= 6; i++) {
        NSString *resourceName = [NSString stringWithFormat:@"v3d_evergreen_tree_%d_shadow", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
        NSLog(@"🔎 [IGolfViewer3D] Looking for: %@.png -> %@", resourceName, path ? path : @"(nil)");

        GLKTextureInfo *texture = [GLKTextureInfo loadFromCacheWithFilePath:path];
        if (texture != nil) {
            [retval addObject:texture];
        } else {
            NSLog(@"❌ [IGolfViewer3D] SKIPPING nil texture - would cause crash!");
        }
    }

    NSLog(@"🌲 [IGolfViewer3D] Loaded %lu/%d evergreen shadow textures", (unsigned long)retval.count, 6);
    return retval;
}

-(id)initWithTextureType:(TextureType)type {
    
    self = [[TextureProfile alloc] init];
    
    if (self) {
        self->_type = type;
    }
    
    return self;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        self->_type = TextureTypeRough;
    }
    
    return self;
}

@end
