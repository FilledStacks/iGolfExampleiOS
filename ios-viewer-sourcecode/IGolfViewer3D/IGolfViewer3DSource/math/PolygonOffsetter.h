//
//  PolygonOffsetter.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@class Vector;

@interface PolygonOffsetter : NSObject

+ (NSArray<Vector*>*)extendPolygonWithPointList:(NSArray<Vector*>*)pointList andExtend:(double)extend;

@end
