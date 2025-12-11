//
//  PolygonOffsetter.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "PolygonOffsetter.h"
#import "../IGolfViewer3DPrivateImports.h"

@implementation PolygonOffsetter

+ (NSArray<Vector*>*)extendPolygonWithPointList:(NSArray<Vector*>*)pointList andExtend:(double)extend {

    NSMutableArray<Vector*>* pointListExtended = [NSMutableArray new];
    

    for (int i = 0 ; i < pointList.count - 1 ; i++) {

        Vector* pt0 = [PolygonOffsetter getPointWithPointList:pointList andIndex:i-1];

        Vector* pt1 = [PolygonOffsetter getPointWithPointList:pointList andIndex:i];

        Vector* pt2 = [PolygonOffsetter getPointWithPointList:pointList andIndex:i+1];

        double a1 = [VectorMath angleWithVector1:pt0 andVector2:pt1 andVector3:pt2];

        Vector* newPoint = [[[[[pt2 substractedWithVector:pt1] normalized] multipliedWithFactor:extend] rotatedWithAngle:-a1/2+M_PI] addedWithVector:pt1];

        [pointListExtended addObject:newPoint];
    }

    [pointListExtended addObject:pointListExtended[0]];

    return pointListExtended;
}


+ (Vector*)getPointWithPointList:(NSArray*)pointList andIndex:(int)index {

    Vector* retval;


    if (index < 0) {
        retval = pointList[pointList.count + index - 1];
    } else {
        retval = pointList[index];
    }
    
    return retval;
}

@end
