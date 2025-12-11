//
//  V3DLine.h
//  iGolfViewer3D
//
//  Created by Dmitry Klenov on 11/10/2018.
//  Copyright © 2018 Yevhen Paschenko. All rights reserved.
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
