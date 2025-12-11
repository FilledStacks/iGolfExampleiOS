//
//  VUtils.m
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "VUtils.h"

@implementation VUtils

+ (NSData*)hmacSHA256FromString:(NSString*)string key:(NSString*)key {
    
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256,
           [key cStringUsingEncoding:NSUTF8StringEncoding],
           [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
           [string cStringUsingEncoding:NSUTF8StringEncoding],
           [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
           result);
    
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

+ (nullable NSString*)prettyPrintedJsonStringWithData:(nullable NSData*)data {
    
    if (data == nil) {
        return @"nil";
    }
    
    NSError* error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    if (error != nil) {
        
        return @"Unable to create JSON String";
    }
    
    if (jsonObject == nil) {
        return @"Unable to create JSON String";
    }
    
    NSData* prettyPrintedData = [NSJSONSerialization dataWithJSONObject: jsonObject
                                                                options:NSJSONWritingPrettyPrinted
                                                                  error:&error];
    
    if (error != nil) {
        return @"Unable to create JSON String";
    }
    
    if (prettyPrintedData == nil) {
        return @"Unable to create JSON String";
    }
    
    NSString* jsonString = [[NSString alloc] initWithData:prettyPrintedData
                                                 encoding:NSUTF8StringEncoding];
    
    if (error != nil) {
        return @"Unable to create JSON String";
    }
    
    if (jsonString == nil) {
        return @"Unable to create JSON String";
    }
    
    return jsonString;
}

+ (NSString *)hexColorWithUIColor:(UIColor *)color {
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
