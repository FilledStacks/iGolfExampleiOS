//
//  V3DPolylineInternal.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "../external/V3DPolyline.h"

NS_ASSUME_NONNULL_BEGIN
@class V3DPolyline;
@interface V3DPolylineInternal : NSObject

@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithLine:(V3DPolyline*)line;
- (void)renderWithEffect:(GLKBaseEffect*)effect;

@end

NS_ASSUME_NONNULL_END
