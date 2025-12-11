//
//  V3DPoint.h
//  iGolfViewer3D
//
//  Created by Dmitry Klenov on 11/10/2018.
//  Copyright © 2018 Yevhen Paschenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "V3DShape.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface V3DCircle : V3DShape

@property (nonatomic, readonly) CLLocation* location;
@property (nonatomic, readonly) UIColor* fillColor;
@property (nonatomic, readonly) UIColor* borderColor;
@property (nonatomic, readonly) double borderWidth;
@property (nonatomic, readonly) double radius;

-(id)initWithLocation:(CLLocation*)location
               radius:(double)radius
            fillColor:(UIColor*)fillColor
          borderColor:(UIColor*)borderColor
          borderWidth:(double)borderWidth;

@end

NS_ASSUME_NONNULL_END
