//
//  CartPathCap.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "../IGolfViewer3DPrivateImports.h"

@class Vector;

@interface CartPathCap : NSObject

- (id)initWithPosition:(Vector*)position andRadius:(double)radius;
- (void)renderWithFrustum:(Frustum*)frustum;
- (void)destroy;

@end
