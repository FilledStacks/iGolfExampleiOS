//
//  CourseScorecardDetailsResponse.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "DefaultResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourseScorecardDetailsResponse : DefaultResponse

@property (nonatomic, readonly) NSArray* menParHole;
@property (nonatomic, readonly) NSArray* wmnParHole;

@end

NS_ASSUME_NONNULL_END
