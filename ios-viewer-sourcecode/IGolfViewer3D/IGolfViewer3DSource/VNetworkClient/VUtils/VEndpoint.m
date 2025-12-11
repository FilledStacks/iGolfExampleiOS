//
//  VEndpoint.m
//  VNetworkClient
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "VEndpoint.h"

@interface VEndpoint() {
    
    NSString* _host;
    NSString* _applicationAPIKey;
    NSString* _applicationSecretKey;
    NSString* _apiVersion;
    NSString* _signatureVersion;
    NSString* _signatureMethod;
    NSString* _responseFormat;
}

@end

@implementation VEndpoint

@synthesize host                 = _host;
@synthesize applicationAPIKey    = _applicationAPIKey;
@synthesize applicationSecretKey = _applicationSecretKey;
@synthesize apiVersion           = _apiVersion;
@synthesize signatureVersion     = _signatureVersion;
@synthesize signatureMethod      = _signatureMethod;
@synthesize responseFormat       = _responseFormat;

-(id)           init:(NSString *)host
   applicationAPIKey:(NSString *)applicationAPIKey
applicationSecretKey:(NSString *)applicationSecretKey
          apiVersion:(NSString *)apiVersion
    signatureVersion:(NSString *)signatureVersion
     signatureMethod:(NSString *)signatureMethod
      responseFormat:(NSString *)responseFormat {
    
    self = [super init];
    
    if (self) {
        self->_host                 = host;
        self->_applicationAPIKey    = applicationAPIKey;
        self->_applicationSecretKey = applicationSecretKey;
        self->_apiVersion           = apiVersion;
        self->_signatureVersion     = signatureVersion;
        self->_signatureMethod      = signatureMethod;
        self->_responseFormat       = responseFormat;
    }
    
    return self;
}

@end
