//
//  VEndpoint.h
//  VNetworkClient
//
//  Created by Dmitry Klenov on 15/11/2018.
//  Copyright © 2018 L1 Technologies. All rights reserved.
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
@property (nonatomic, readonly, nullable) NSString* courseFeedbackUrl;

-(VEndpoint*)    init:(NSString*)host
   applicationAPIKey:(NSString*)applicationAPIKey
applicationSecretKey:(NSString*)applicationSecretKey
          apiVersion:(NSString*)apiVersion
    signatureVersion:(NSString*)signatureVersion
     signatureMethod:(NSString*)signatureMethod
      responseFormat:(NSString*)responseFormat
   courseFeedbackUrl:(NSString*)courseFeedbackUrl;

-(VEndpoint*)    init:(NSString*)host
   applicationAPIKey:(NSString*)applicationAPIKey
applicationSecretKey:(NSString*)applicationSecretKey
          apiVersion:(NSString*)apiVersion
    signatureVersion:(NSString*)signatureVersion
     signatureMethod:(NSString*)signatureMethod
      responseFormat:(NSString*)responseFormat;

@end

NS_ASSUME_NONNULL_END
