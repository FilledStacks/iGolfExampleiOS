//
//  VEndpoint.h
//  VNetworkClient
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEndpoint : NSObject

@property (nonatomic, readonly) NSString* host;
@property (nonatomic, readonly) NSString* applicationAPIKey;
@property (nonatomic, readonly) NSString* applicationSecretKey;
@property (nonatomic, readonly) NSString* apiVersion;
@property (nonatomic, readonly) NSString* signatureVersion;
@property (nonatomic, readonly) NSString* signatureMethod;
@property (nonatomic, readonly) NSString* responseFormat;

-(VEndpoint*)    init:(NSString*)host
   applicationAPIKey:(NSString*)applicationAPIKey
applicationSecretKey:(NSString*)applicationSecretKey
          apiVersion:(NSString*)apiVersion
    signatureVersion:(NSString*)signatureVersion
     signatureMethod:(NSString*)signatureMethod
       responseFormat:(NSString*)responseFormat;

-(VEndpoint*)    init:(NSString*)host
   applicationAPIKey:(NSString*)applicationAPIKey
applicationSecretKey:(NSString*)applicationSecretKey
          apiVersion:(NSString*)apiVersion
    signatureVersion:(NSString*)signatureVersion
     signatureMethod:(NSString*)signatureMethod
      responseFormat:(NSString*)responseFormat;

@end

NS_ASSUME_NONNULL_END
