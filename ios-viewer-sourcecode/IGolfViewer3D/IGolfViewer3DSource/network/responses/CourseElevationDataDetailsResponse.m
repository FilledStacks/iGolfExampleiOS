//
//  CourseElevationDataDetailsResponse.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseElevationDataDetailsResponse.h"

@interface CourseElevationDataDetailsResponse() {
    NSString* _jsonFullUrl;
}

@end

@implementation CourseElevationDataDetailsResponse

-(instancetype)init:(NSData *)data {
    self = [super init:data];
    
    if (self) {
        
        NSError* error;
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            return nil;
        }
        
        self->_jsonFullUrl = [dict valueForKey:@"jsonFullUrl"];
    }
    
    return self;
}

- (NSString *)jsonFullUrl {
    return _jsonFullUrl;
}

@end
