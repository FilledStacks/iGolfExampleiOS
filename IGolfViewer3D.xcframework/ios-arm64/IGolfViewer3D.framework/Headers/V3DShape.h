//
//  V3DShapeRenderable.h
//  iGolfViewer3D
//
//  Created by Dmitry Klenov on 19/10/2018.
//  Copyright © 2018 Yevhen Paschenko. All rights reserved.
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
