//
//  CourseHole.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CourseHole : NSObject

@property (nonatomic, readonly) NSUInteger holeNumber;
@property (nonatomic, readonly) CLLocation* centerLocation;
@property (nonatomic, readonly) CLLocation* frontLocation;
@property (nonatomic, readonly) CLLocation* backLocation;

-(id)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
