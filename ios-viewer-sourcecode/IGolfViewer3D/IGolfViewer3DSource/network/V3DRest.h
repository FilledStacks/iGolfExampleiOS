//
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "responses/DefaultResponse.h"
#import "responses/CourseGPSVectorDetailsResponse.h"
#import "responses/CourseGPSDetailsResponse.h"
#import "responses/CourseElevationDataDetailsResponse.h"
#import "responses/CoursePinPositionDetailsResponse.h"
#import "responses/CourseScorecardDetailsResponse.h"
#import "../VNetworkClient/VNetworkClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface V3DRest : NSObject

- (id)initWithEndpoint:(VEndpoint*)endpoint;

-(void)courseGPSVectorDetails:(NSString *)idCourse
                      success:(void (^)(CourseGPSVectorDetailsResponse * _Nullable))success
                       failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed;

-(void)courseGPSDetails:(NSString *)idCourse
                success:(void (^)(CourseGPSDetailsResponse * _Nullable))success
                 failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed;

-(void)courseElevationDataDetails:(NSString *)idCourse
                          success:(void (^)(CourseElevationDataDetailsResponse * _Nullable))success
                           failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed;

-(void)coursePinPositionDetails:(NSString *)idCourse
                        success:(void (^)(CoursePinPositionDetailsResponse * _Nullable))success
                        failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed;

-(void)courseScorecardDetails:(NSString *)idCourse
                      success:(void (^)(CourseScorecardDetailsResponse * _Nullable))success
                       failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed;

- (NSURLSessionDataTask*)get:(NSURL*)url
                 httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders
           completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;


@end

NS_ASSUME_NONNULL_END
