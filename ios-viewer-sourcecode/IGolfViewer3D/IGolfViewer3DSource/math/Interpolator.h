//
//  Interpolator.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "CatmullRomType.h"

@class Vector;

@interface Interpolator : NSObject

+ (NSArray<Vector*>*)interpolateWithCoordinateArray:(NSArray<Vector*>*)coordinates andPointsPerSegment:(int)pointsPerSegment andCurveType:(CatmullRomType)curveType;

@end
