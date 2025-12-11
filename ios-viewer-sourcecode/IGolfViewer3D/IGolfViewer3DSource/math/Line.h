//
//  Line.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "Vector.h"

NS_ASSUME_NONNULL_BEGIN

@interface Line : NSObject

@property (nonatomic, assign) Vector* p1;
@property (nonatomic, assign) Vector* p2;

-(id)initWithP1:(Vector*)p1 andP2:(Vector*)p2;

@end

NS_ASSUME_NONNULL_END
