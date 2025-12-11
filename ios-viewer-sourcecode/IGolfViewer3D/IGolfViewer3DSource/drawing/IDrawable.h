//
//  IDrawable.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import "Frustum.h"

@protocol IDrawable <NSObject>

@property (nonatomic, assign) NSString* drawableId;

@optional
- (void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum;
- (void)destroy;

@end
