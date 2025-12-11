//
//  VNetworkClient.m
//  VNetworkClient
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "VNetworkClient.h"
#import "VGTMBase64/VGTMBase64.h"
#import "VUtils.h"
#import "VMultipartObject.h"
#import <UIKit/UIKit.h>

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@class Endpoint;

@interface VNetworkClient() {
    VEndpoint* _iGolfEndpoint;
    NSDateFormatter* _dateFormatter;
    BOOL _isDebugLogEnabled;
}

@end

@implementation VNetworkClient


-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.locale           = [[NSLocale alloc] initWithLocaleIdentifier :@"en_US"];
        formatter.dateFormat       = @"yyMMddHHmmssZZZZ";
        
        self->_isDebugLogEnabled   = false;
        self->_dateFormatter       = formatter;
    }
    
    return self;
}

-(id)init:(VEndpoint*)endpoint {
    
    self = [self init];
    
    if (self) {
        self->_iGolfEndpoint = endpoint;
    }
    
    return self;
}

- (void)setEndpoint:(VEndpoint*)endpoint {
    
    _iGolfEndpoint = endpoint;
}

- (BOOL)isDebugLogEnabled {
    
    return _isDebugLogEnabled;
}

- (void)setIsDebugLogEnabled:(BOOL)isDebugLogEnabled {
    
    _isDebugLogEnabled = isDebugLogEnabled;
}

- (NSURLSessionDataTask*)sendRequest:(NSURLRequest*)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    if (self.isDebugLogEnabled) {
        
        [self log:[NSString stringWithFormat:@"HTTP Method: %@", request.HTTPMethod]];
        [self log:[NSString stringWithFormat:@"URL: %@", request.URL.absoluteString]];
        [self log:[NSString stringWithFormat:@"HTTP Headers: %@", request.allHTTPHeaderFields]];
        [self log:[NSString stringWithFormat:@"Body JSON: %@", [VUtils prettyPrintedJsonStringWithData:request.HTTPBody]]];
    }
    
    __weak VNetworkClient* weakSelf = self;
    
    NSURLSessionDataTask* task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            if (weakSelf.isDebugLogEnabled) {
                
                [weakSelf log:[NSString stringWithFormat:@"Response URL: %@", request.URL.absoluteString]];
                [weakSelf log:[NSString stringWithFormat:@"Response JSON: %@", [VUtils prettyPrintedJsonStringWithData:data]]];
                
                if (error != nil) {
                    [weakSelf log:error.localizedDescription];
                }
            }
            
            completionHandler(data,response,error);
        });
    }];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask*)get:(NSURL*)url httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0];
    
    NSString* httpMethod = @"GET";
    
    [request setHTTPMethod:httpMethod];
    
    for (NSString* key in httpHeaders.allKeys) {
        [request setValue:[httpHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    
    return [self sendRequest:request completionHandler:completionHandler];
}

- (NSURLSessionDataTask*)post:(NSURL*)url httpBody:(nullable NSData*)httpBody httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0];
    
    NSString* httpMethod = @"POST";
    
    [request setHTTPMethod:httpMethod];
    [request setHTTPBody:httpBody];
    
    for (NSString* key in httpHeaders.allKeys) {
        [request setValue:[httpHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    
    return [self sendRequest:request completionHandler:completionHandler];
}

- (NSURLSessionDataTask*)postMultipart:(NSURL*)url multipartObjects:(NSArray<VMultipartObject*>*)multipartObjects httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    NSString* boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    
    NSMutableData* httpBody = [NSMutableData data];
    
    for (VMultipartObject* object in multipartObjects) {
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (object.fileName != nil) {
            [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", object.name, object.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", object.mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", object.name] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [httpBody appendData:object.data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary<NSString*, NSString*>* headers = [NSMutableDictionary new];
    
    [headers addEntriesFromDictionary:httpHeaders];
    [headers setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[httpBody length]] forKey:@"Content-Length"];
    [headers setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forKey:@"Content-Type"];
    
    
    return [self post:url httpBody:httpBody httpHeaders:headers completionHandler:completionHandler];
}

- (NSURLSessionDataTask*)postAction:(NSString*)action url:(NSURL*)url httpBody:(nullable NSData*)httpBody httpHeaders:(nullable NSDictionary<NSString*, NSString*>*)httpHeaders completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    
    [self log:[NSString stringWithFormat:@"Action: %@", action]];
    
    __weak VNetworkClient* weakSelf = self;
    
    return [self post:url httpBody:httpBody httpHeaders:httpHeaders completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (weakSelf.isDebugLogEnabled) {
            [weakSelf log:[NSString stringWithFormat:@"Response %@", action]];
        }
        completionHandler(data,response,error);
    }];
}

- (NSURLSessionDataTask*)postMultipartAction:(nonnull NSString*)action url:(NSURL*)url multipartObjects:(NSArray<VMultipartObject*>*)multipartObjects completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    NSMutableDictionary<NSString*, NSString*>* httpHeaders = [NSMutableDictionary new];
    
    [self log:[NSString stringWithFormat:@"Action: %@", action]];
    
    __weak VNetworkClient* weakSelf = self;
    
    return [self postMultipart:url multipartObjects:multipartObjects httpHeaders:httpHeaders completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (weakSelf.isDebugLogEnabled) {
            [weakSelf log:[NSString stringWithFormat:@"Response %@:", action]];
        }
        
        completionHandler(data,response,error);
    }];
}

- (NSURLSessionDataTask*)executePublicAction:(nonnull NSString*)action parameters:(nullable NSData*)parameters completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    if (_iGolfEndpoint == nil) {
        
        [self forceLog: @"Unable to execute action. Endpoint is not set."];
        return nil;
    }
    
    NSString* stringUrlPart1 = action;
    
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.applicationAPIKey];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.apiVersion];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.signatureVersion];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.signatureMethod];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    
    NSString* stringUrlPart2 = [self timeStamp].copy;
    
    stringUrlPart2 = [stringUrlPart2 stringByAppendingString:@"/"];
    stringUrlPart2 = [stringUrlPart2 stringByAppendingString:_iGolfEndpoint.responseFormat];
    
    NSString* signature = [self makeSignatureWithUrl1:stringUrlPart1 url2:stringUrlPart2 secret:_iGolfEndpoint.applicationSecretKey];
    
    NSURL* url = [[NSURL alloc] initWithString:_iGolfEndpoint.host];
    
    url = [url URLByAppendingPathComponent:stringUrlPart1];
    url = [url URLByAppendingPathComponent:signature];
    url = [url URLByAppendingPathComponent:stringUrlPart2];
    
    NSData* httpBody = parameters != nil ? parameters : [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary<NSString*, NSString*>* httpHeaders = [NSMutableDictionary new];
    
    [httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
    [httpHeaders setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[httpBody length]] forKey:@"Content-Length"];
    
    return [self postAction:action url:url httpBody:httpBody httpHeaders:httpHeaders completionHandler:completionHandler];
}

- (NSURLSessionDataTask*)executePublicMultipartAction:(nonnull NSString*)action multipartObjects:(NSArray<VMultipartObject*>*)multipartObjects completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    if (_iGolfEndpoint == nil) {
        [self forceLog: @"Unable to execute action. Endpoint is not set."];
        return nil;
    }
    
    NSString* stringUrlPart1 = action;
    
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.applicationAPIKey];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.apiVersion];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.signatureVersion];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:_iGolfEndpoint.signatureMethod];
    stringUrlPart1 = [stringUrlPart1 stringByAppendingString:@"/"];
    
    NSString* stringUrlPart2 = [self timeStamp].copy;
    
    stringUrlPart2 = [stringUrlPart2 stringByAppendingString:@"/"];
    stringUrlPart2 = [stringUrlPart2 stringByAppendingString:_iGolfEndpoint.responseFormat];
    
    NSString* signature = [self makeSignatureWithUrl1:stringUrlPart1 url2:stringUrlPart2 secret:_iGolfEndpoint.applicationSecretKey];
    
    NSURL* url = [[NSURL alloc] initWithString:_iGolfEndpoint.host];
    
    url = [url URLByAppendingPathComponent:stringUrlPart1];
    url = [url URLByAppendingPathComponent:signature];
    url = [url URLByAppendingPathComponent:stringUrlPart2];
    
    return [self postMultipartAction:action url:url multipartObjects:multipartObjects completionHandler:completionHandler];
}

- (NSString*)timeStamp {
    return [_dateFormatter stringFromDate:[[NSDate alloc] init]];
}

- (NSString*)makeSignatureWithUrl1:(NSString*)url1 url2:(NSString*)url2 secret:(NSString*)secret {
    return [VGTMBase64 stringByWebSafeEncodingData:[VUtils hmacSHA256FromString:[url1 stringByAppendingString:url2] key:secret] padded:false];
}

+ (NSString*)makeSignature:(NSString*)stringToSign secret:(NSString*)secret padded:(BOOL)padded {
    return [VGTMBase64 stringByWebSafeEncodingData:[VUtils hmacSHA256FromString:stringToSign key:secret] padded:false];
}

- (void)forceLog:(NSString *)log {
    NSLog(@"[VNetworkClient] %@", log);
}

- (void)log:(NSString *)log  {
    
    if (self.isDebugLogEnabled) {
        [self forceLog:log];
    }
}

@end
