//
//  CourseGPSDetailsResponse.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseGPSDetailsResponse.h"

@interface CourseGPSDetailsResponse() {
    NSArray* _gpsList;
}

@end

@implementation CourseGPSDetailsResponse

-(instancetype)init:(NSData *)data {
   
    self = [super init:data];
    
    if (self) {
        
        NSError* error;
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            return nil;
        }
        
        self->_gpsList = [dict valueForKey:@"GPSList"];
    }
    
    return self;
}

-(NSArray *)gpsList {
    return _gpsList;
}

@end
