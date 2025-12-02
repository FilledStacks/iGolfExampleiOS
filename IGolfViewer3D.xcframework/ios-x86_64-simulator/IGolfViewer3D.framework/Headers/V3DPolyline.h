//
//  V3DPolyLine.h
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

@interface V3DPolyline : V3DShape

@property (nonatomic, readonly) NSArray<CLLocation*>* locations;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, readonly) double width;
@property (nonatomic, readonly) BOOL interpolate;

-(id)initWithLocations:(NSArray<CLLocation*>*)locations
                 color:(UIColor*)color
                 width:(double)width
           interpolate:(BOOL)interpolate;

@end

NS_ASSUME_NONNULL_END
