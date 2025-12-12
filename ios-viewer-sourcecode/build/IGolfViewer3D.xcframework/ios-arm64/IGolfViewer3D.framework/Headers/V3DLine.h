//
//  V3DLine.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "V3DShape.h"

NS_ASSUME_NONNULL_BEGIN

@class V3DLineInternal;

@interface V3DLine : V3DShape

@property (nonatomic, readonly) CLLocation* startLocation;
@property (nonatomic, readonly) CLLocation* endLocation;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, readonly) double width;

-(id)initWithStartLocation:(CLLocation*)startLocation
               endLocation:(CLLocation*)endLocation
                     color:(UIColor*)color
                     width:(double)width;

@end

NS_ASSUME_NONNULL_END
