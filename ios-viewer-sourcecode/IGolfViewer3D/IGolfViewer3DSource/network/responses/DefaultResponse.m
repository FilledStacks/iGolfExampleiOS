//
//  DefaultResponse.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "DefaultResponse.h"

@interface DefaultResponse() {
    NSNumber* _status;
    NSString* _errorMessage;
    NSDictionary* _dict;
}

@end

@implementation DefaultResponse

- (nullable instancetype)init:(NSData *)data {
    self = [super init];
    
    if (self) {
        
        NSError* error;
        
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            return nil;
        }
        
        self->_status = [response objectForKey:@"Status"];
        self->_errorMessage = [response objectForKey:@"ErrorMessage"];
        self->_dict = response;
    }
    
    return self;
}

-(NSNumber *)status {
    return _status;
}

-(NSString *)errorMessage {
    return _errorMessage;
}

-(NSDictionary *)dict {
    return _dict;
}

@end
