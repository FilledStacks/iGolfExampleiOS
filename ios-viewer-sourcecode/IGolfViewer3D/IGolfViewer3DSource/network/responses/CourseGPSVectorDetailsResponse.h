//
//  CourseGPSVectorDetailsResponse.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "DefaultResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourseGPSVectorDetailsResponse : DefaultResponse

@property (nonatomic, readonly) NSDictionary* vectorGPSObject;

@end

NS_ASSUME_NONNULL_END
