//
//  CourseGPSVectorDetailsResponse.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseGPSVectorDetailsResponse.h"

@interface CourseGPSVectorDetailsResponse() {
    
    NSDictionary* _vectorGPSObject;
}

@end

@implementation CourseGPSVectorDetailsResponse

-(instancetype)init:(NSData *)data {
    
    self = [super init:data];
    
    if (self) {
        
        NSError* error;
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            return nil;
        }
        
        self->_vectorGPSObject = [dict valueForKey:@"vectorGPSObject"];
    }
    
    return self;
}

-(NSDictionary *)vectorGPSObject {
    
    return _vectorGPSObject;
}

@end
