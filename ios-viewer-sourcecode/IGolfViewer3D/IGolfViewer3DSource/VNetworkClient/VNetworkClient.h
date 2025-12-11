//
//  VNetworkClient.h
//  VNetworkClient
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "VEndpoint.h"
#import "VMultipartObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface VNetworkClient : NSObject

@property(nonatomic, assign) BOOL isDebugLogEnabled;

- (id)init:(VEndpoint*)endpoint;

- (void)setEndpoint:(VEndpoint*)endpoint;

- (NSURLSessionDataTask*)sendRequest:(NSURLRequest*)request
  completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask*)get:(NSURL*)url
                 httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders
           completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask*)post:(NSURL*)url
                     httpBody:(nullable NSData*)httpBody
                  httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders
            completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask*)executePublicAction:(nonnull NSString*)action
                                  parameters:(nullable NSData*)parameters
                           completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask*)executePublicMultipartAction:(nonnull NSString*)action
                                     multipartObjects:(NSArray<VMultipartObject*>*)multipartObjects
                                    completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandle;

- (NSURLSessionDataTask*)executePrivateAction:(nonnull NSString*)action
                                   parameters:(nullable NSData*)parameters
                            completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask*)executePrivateMultipartAction:(nonnull NSString*)action
                                      multipartObjects:(NSArray<VMultipartObject*>*)multipartObjects
                                     completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

+ (NSString*)makeSignature:(NSString*)stringToSign secret:(NSString*)secret padded:(BOOL)padded;


@end

NS_ASSUME_NONNULL_END
