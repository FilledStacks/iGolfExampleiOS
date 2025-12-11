//
//  V3DShapeRenderable.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface V3DShape : NSObject

@property (nonatomic, readonly) CGRect boundingBox;

- (void)renderWithEffect:(GLKBaseEffect*)effect;

@end

NS_ASSUME_NONNULL_END
