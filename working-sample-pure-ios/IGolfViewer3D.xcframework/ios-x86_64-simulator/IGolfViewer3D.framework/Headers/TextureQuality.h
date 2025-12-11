//
//  TextureQuality.h
//  iGolfViewer3D
//
//  Created by Dmitry Klenov on 02.12.17.
//  Copyright © 2017 Yevhen Paschenko. All rights reserved.
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
