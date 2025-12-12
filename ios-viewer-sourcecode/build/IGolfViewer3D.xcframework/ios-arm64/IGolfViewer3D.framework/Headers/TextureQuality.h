//
//  TextureQuality.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

#ifndef TextureQuality_h
#define TextureQuality_h

typedef NS_ENUM(NSUInteger, TextureQuality) {
    TextureQualityHigh = 2048,
    TextureQualityMediumHigh = 1536,
    TextureQualityMediumLow = 1024,
    TextureQualityLow = 512,
    TextureQualityNone = 0
};

#endif
