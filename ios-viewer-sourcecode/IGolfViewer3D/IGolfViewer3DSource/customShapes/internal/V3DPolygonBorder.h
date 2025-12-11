//
//  V3DPolygonBorder.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "../../math/Vector.h"

NS_ASSUME_NONNULL_BEGIN

@interface V3DPolygonBorder : NSObject

@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithVectorList:(NSMutableArray<Vector*>*)vectorList
                   color:(UIColor*)color
                   width:(double)width;
- (void)renderWithEffect:(GLKBaseEffect*)effect;

@end

NS_ASSUME_NONNULL_END
