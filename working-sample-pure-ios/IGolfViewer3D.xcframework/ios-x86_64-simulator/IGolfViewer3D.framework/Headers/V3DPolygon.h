//
//  V3DPolygon.h
//  iGolfViewer3D
//
//  Created by Dmitry Klenov on 12/10/2018.
//  Copyright © 2018 Yevhen Paschenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "V3DShape.h"
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface V3DPolygon : V3DShape

@property (nonatomic, readonly) NSArray<CLLocation*>* locations;
@property (nonatomic, readonly) UIColor* fillColor;
@property (nonatomic, readonly) UIColor* borderColor;
@property (nonatomic, readonly) double borderWidth;
@property (nonatomic, readonly) BOOL interpolate;

-(id)initWithLocations:(NSArray<CLLocation*>*)locations
             fillColor:(UIColor*)fillColor
           borderColor:(UIColor*)borderColor
           borderWidth:(double)borderWidth
           interpolate:(BOOL)interpolate;

-(void)renderWithEffect:(GLKBaseEffect*)effect;


@end

NS_ASSUME_NONNULL_END
