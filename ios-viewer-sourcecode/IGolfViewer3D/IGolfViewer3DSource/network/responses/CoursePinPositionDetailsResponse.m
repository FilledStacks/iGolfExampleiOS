//
//  CoursePinPositionDetailsResponse.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CoursePinPositionDetailsResponse.h"

@interface CoursePinPositionDetailsResponse() {
    NSArray* _holes;
}

@end

@implementation CoursePinPositionDetailsResponse

-(instancetype)init:(NSData *)data {
    self = [super init:data];
    
    if (self) {
        
        NSError* error;
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            return nil;
        }
        
        self->_holes = [dict valueForKey:@"holes"];
    }
    
    return self;
}

- (NSArray *)holes {
    return _holes;
}

@end
