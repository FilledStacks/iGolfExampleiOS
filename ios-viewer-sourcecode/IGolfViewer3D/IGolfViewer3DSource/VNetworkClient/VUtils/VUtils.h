//
//  VUtils.h
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VUtils : NSObject

+ (NSData*)hmacSHA256FromString:(NSString*)string key:(NSString*)key;
+ (nullable NSString*)prettyPrintedJsonStringWithData:(nullable NSData*)data;
+ (NSString*)hexColorWithUIColor:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
