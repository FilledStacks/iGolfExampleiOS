//
//  VMultipartObject.m
//  VNetworkClient
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "VMultipartObject.h"

@interface VMultipartObject() {
    NSString* _name;
    NSData* _data;
    NSString* _fileName;
    NSString* _mimeType;
}

@end

@implementation VMultipartObject

@synthesize name = _name;
@synthesize data = _data;
@synthesize fileName = _fileName;
@synthesize mimeType = _mimeType;

- (id)init:(NSString *)name data:(NSData *)data mimeType:(NSString *)mimeType {
    
    self = [super init];
    
    if (self) {
        self->_name = name;
        self->_data = data;
        self->_mimeType = mimeType;
    }
    
    return self;
}

- (id)init:(NSString *)name data:(NSData *)data fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    self = [super init];
    
    if (self) {
        self->_name = name;
        self->_data = data;
        self->_fileName = fileName;
        self->_mimeType = mimeType;
    }
    
    return self;
}

@end
