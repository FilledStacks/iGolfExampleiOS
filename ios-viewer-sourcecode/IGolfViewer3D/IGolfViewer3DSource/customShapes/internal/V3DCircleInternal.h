//
//  V3DPointInternal.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "../external/V3DCircle.h"

NS_ASSUME_NONNULL_BEGIN

@class V3DCircle;

@interface V3DCircleInternal : NSObject

@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithPoint:(V3DCircle*)point;
- (void)renderWithEffect:(GLKBaseEffect*)effect;

@end

NS_ASSUME_NONNULL_END
