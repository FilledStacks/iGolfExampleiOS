//
//  VMultipartObject.h
//  VNetworkClient
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VMultipartObject : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSData* data;
@property (nonatomic, readonly) NSString* fileName;
@property (nonatomic, readonly) NSString*mimeType;

-(id)init:(NSString*)name data:(NSData*)data mimeType:(NSString*)mimeType;
-(id)init:(NSString*)name data:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType;

@end

NS_ASSUME_NONNULL_END
