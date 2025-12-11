//
//  CreekRenderer.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>

#import "CreekRenderer.h"

#import "../IGolfViewer3DPrivateImports.h"


@implementation CreekRenderer

-(void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum {
    for (Creek* creek in _creekList) {
        [creek renderWithEffect:effect];
    }
}

-(void)setDrawableId:(NSString *)drawableId {
    
}

-(NSString *)drawableId {
    
    return @"CreekRenderer";
}


@end
