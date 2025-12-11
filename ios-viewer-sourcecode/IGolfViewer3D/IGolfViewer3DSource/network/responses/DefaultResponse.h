//
//  DefaultResponse.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DefaultResponse : NSObject

@property (nonatomic, readonly) NSNumber* status;
@property (nonatomic, readonly) NSString* errorMessage;
@property (nonatomic, readonly) NSDictionary* dict;

- (nullable instancetype)init:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
