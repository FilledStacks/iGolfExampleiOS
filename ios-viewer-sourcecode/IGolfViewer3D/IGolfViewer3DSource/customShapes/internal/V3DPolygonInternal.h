//
//  V3DPolygonInternal.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "../external/V3DPolygon.h"

NS_ASSUME_NONNULL_BEGIN


@interface V3DPolygonInternal : NSObject

@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithPolygon:(V3DPolygon*)polygon;
- (void)renderWithEffect:(GLKBaseEffect*)effect;

@end

NS_ASSUME_NONNULL_END
