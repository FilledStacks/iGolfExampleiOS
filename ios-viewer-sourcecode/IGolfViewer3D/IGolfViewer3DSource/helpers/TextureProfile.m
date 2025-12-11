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
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    for (int i = 1; i <= 5; i++) {
        [retval addObject:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"v3d_tree_%d", i] ofType:@"png"]]];
    }
    
    
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getDeciduousTreeShadowTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    for (int i = 1; i <= 5; i++ )
        [retval addObject:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"v3d_tree_%d_shadow", i] ofType:@"png"]]];
    
    return retval;
}



-(NSMutableArray<GLKTextureInfo*>*) getDesertTreeTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    for (int i = 1; i <= 4; i++)
        [retval addObject:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"v3d_tree_%d_desert", i] ofType:@"png"]]];
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) getDesertTreeShadowTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    for (int i = 1; i <= 4; i++)
        [retval addObject:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"v3d_tree_%d_shadow_desert", i] ofType:@"png"]]];
    
    return retval;
}



-(NSMutableArray<GLKTextureInfo*>*) _getEvergreenTreeTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    for (int i = 1; i <= 6; i++)
        [retval addObject:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"v3d_evergreen_tree_%d", i] ofType:@"png"]]];
    
    return retval;
}

-(NSMutableArray<GLKTextureInfo*>*) _getEvergreenTreeShadowTextureSet {
    
    NSMutableArray<GLKTextureInfo*>* retval = [NSMutableArray new];
    
    for (int i = 1; i <= 6; i++)
        [retval addObject:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"v3d_evergreen_tree_%d_shadow", i] ofType:@"png"]]];
    
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
