//
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DRest.h"

@interface V3DRest() {
    VNetworkClient* _networkClient;
}

@end

@implementation V3DRest

-(id)initWithEndpoint:(VEndpoint *)endpoint {
    self = [super init];
    
    if([endpoint.applicationAPIKey  isEqual: @""] || [endpoint.applicationSecretKey  isEqual: @""]){
        [NSException raise:@"[CourseRenderView]" format:@"Please spicify the API and secret keys in the loader."];
    }
    if (self) {
        self->_networkClient = [[VNetworkClient alloc] init:endpoint];
        
//        #if DEBUG
//        [_networkClient setIsDebugLogEnabled:true];
//        #endif
    }
    
    return self;
}

-(void)courseGPSVectorDetails:(NSString *)idCourse success:(void (^)(CourseGPSVectorDetailsResponse * _Nullable))success failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed {
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:idCourse forKey:@"id_course"];
    
    NSData* parameters = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [_networkClient executePublicAction:@"CourseGPSVectorDetails" parameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failed(nil, error);
            } else {
                if (data) {
                    CourseGPSVectorDetailsResponse* response = [[CourseGPSVectorDetailsResponse alloc] init:data];
                    
                    if (response != nil && response.status.integerValue == 1) {
                        success(response);
                    } else {
                        DefaultResponse* errorResponse = [[DefaultResponse alloc] init:data];
                        failed(errorResponse, error);
                    }
                } else {
                    failed(nil, error);
                }
            }
        });
    }];
}

- (void)courseGPSDetails:(NSString *)idCourse success:(void (^)(CourseGPSDetailsResponse * _Nullable))success failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed {
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:idCourse forKey:@"id_course"];
    
    NSData* parameters = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [_networkClient executePublicAction:@"CourseGPSDetails" parameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failed(nil, error);
            } else {
                if (data) {
                    CourseGPSDetailsResponse* response = [[CourseGPSDetailsResponse alloc] init:data];
                    
                    if (response != nil && response.status.integerValue == 1) {
                        success(response);
                    } else {
                        DefaultResponse* errorResponse = [[DefaultResponse alloc] init:data];
                        failed(errorResponse, error);
                    }
                } else {
                    failed(nil, error);
                }
            }
        });
    }];
}

- (void)courseElevationDataDetails:(NSString *)idCourse success:(void (^)(CourseElevationDataDetailsResponse * _Nullable))success failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed {
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:idCourse forKey:@"id_course"];
    
    NSData* parameters = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [_networkClient executePublicAction:@"CourseElevationDataDetails" parameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failed(nil, error);
            } else {
                if (data) {
                    CourseElevationDataDetailsResponse* response = [[CourseElevationDataDetailsResponse alloc] init:data];
                    
                    if (response != nil && response.status.integerValue == 1) {
                        success(response);
                    } else {
                        DefaultResponse* errorResponse = [[DefaultResponse alloc] init:data];
                        failed(errorResponse, error);
                    }
                } else {
                    failed(nil, error);
                }
            }
        });
    }];
}

-(void)coursePinPositionDetails:(NSString *)idCourse success:(void (^)(CoursePinPositionDetailsResponse * _Nullable))success failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed {
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:idCourse forKey:@"id_course"];
    [dict setValue:[formatter stringFromDate:[[NSDate alloc] init]] forKey:@"currentCourseDate"];
    
    NSData* parameters = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [_networkClient executePublicAction:@"CoursePinPositionDetails" parameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failed(nil, error);
            } else {
                if (data) {
                    CoursePinPositionDetailsResponse* response = [[CoursePinPositionDetailsResponse alloc] init:data];
                    
                    if (response != nil && response.status.integerValue == 1) {
                        success(response);
                    } else {
                        DefaultResponse* errorResponse = [[DefaultResponse alloc] init:data];
                        failed(errorResponse, error);
                    }
                } else {
                    failed(nil, error);
                }
            }
        });
    }];
}

-(void)courseScorecardDetails:(NSString *)idCourse success:(void (^)(CourseScorecardDetailsResponse * _Nullable))success failed:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))failed {
    
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setValue:idCourse forKey:@"id_course"];
    
    NSData* parameters = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    [_networkClient executePublicAction:@"CourseScorecardDetails" parameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failed(nil, error);
            } else {
                if (data) {
                    CourseScorecardDetailsResponse* response = [[CourseScorecardDetailsResponse alloc] init:data];
                    
                    if (response != nil && response.status.integerValue == 1) {
                        success(response);
                    } else {
                        DefaultResponse* errorResponse = [[DefaultResponse alloc] init:data];
                        failed(errorResponse, error);
                    }
                } else {
                    failed(nil, error);
                }
            }
        });
    }];
}

-(NSURLSessionDataTask *)get:(NSURL *)url httpHeaders:(NSDictionary<NSString *,NSString *> *)httpHeaders completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    
    return [_networkClient get:url httpHeaders:httpHeaders completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(data, response, error);
        });
    }];
}




@end
