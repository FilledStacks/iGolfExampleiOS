//
//  VectorMath.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "VectorOrder.h"
#import "Line.h"

@class Vector;

@interface VectorMath : NSObject
+ (NSMutableArray<Vector*>*)intersectionPointsWithVectorList:(NSArray<Vector*>*)vectorList;
+ (NSArray<Vector*>*)polygonizeVectorList:(NSArray<Vector*>*)vectorList;
+ (Vector*)intersectionWithLineA:(Line*)lineA andLineB:(Line*)lineB;
+(NSMutableArray<Vector*>*)makeOffset:(double)offset forVectorList:(NSArray<Vector*>*)vectorList;
+ (NSMutableArray<Vector*>*)normalizedVectorList:(NSArray<Vector*>*)vectorList;
+ (NSMutableArray<Vector*>*)vectorList:(NSArray<Vector*>*)vectorList byRemovingVectorList:(NSArray<Vector*>*)removingList;
+ (NSMutableArray<Vector*>*)closedVectorList:(NSArray<Vector*>*)vectorList;
+ (NSMutableArray<Vector*>*)unclosedVectorList:(NSArray<Vector*>*)vectorList;
+ (NSMutableArray<Vector*>*)filterDuplicatesInVectorList:(NSArray<Vector*>*)vectorList;
+ (NSMutableArray<Vector*>*)vectorList:(NSArray<Vector*>*)vectorList withOrder:(VectorOrder)order;
+ (VectorOrder)getVectorOrderWithVectorArray:(NSArray<Vector*>*)array;
+ (double)angleWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 andVector3:(Vector*)pt3;
+ (double)angle2WithVector1:(Vector*)previous andVector2:(Vector*)center andVector3:(Vector*)current;
+ (Vector*)substractedWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2;
+ (Vector*)substracted3WithVector1:(Vector*)pt1 andVector2:(Vector*)pt2;
+ (Vector*)addedWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2;
+ (Vector*)normalizedWithVector:(Vector*)vector;
+ (Vector*)getNormalWithVector1:(Vector*)v1 andVector2:(Vector*)v2 andVector3:(Vector*)v3;
+ (Vector*)getTriangleNormalWithV1:(Vector*)a andV2:(Vector*)b andV3:(Vector*)c;
+ (Vector*)crossWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2;
+ (Vector*)normalizedWithVector3:(Vector*)pt;
+ (Vector*)multipliedWithVector:(Vector*)pt1 andFactor:(double)factor;
+ (Vector*)rotatedWithVector:(Vector*)pt andAngle:(double)angle;
+ (double)distanceWithVector:(Vector*)vector;
+ (double)distanceWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2;
+ (double)distanceWithVectorArray:(NSArray<Vector*>*)vectors;
+ (double)deg2radWithDeg:(double)deg;
+ (double)rad2degWithRad:(double)rad;
+ (BOOL)isVector:(Vector*)vector insidePolygon:(NSArray<Vector*>*)polygon;
+ (Vector*)intersectionWithVectorLine1V1:(Vector*)p1 andLine1V2:(Vector*)p2 andLine2V1:(Vector*)p3 andLine2V2:(Vector*)p4;
+ (Vector*)calculateProjectionPointWithPoint:(Vector*)point andLinePoint1:(Vector*)linePoint1 andLinePoint2:(Vector*)linePoint2;
+ (Vector*)calculateCenteroidWithVectorArray:(NSArray<Vector*>*)vectorArray;
+ (double)distance3DWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2;
+ (Vector*)calculateZpositionForPointWithX:(double)x andY:(double)y andBasePoint:(Vector*)A andUpPoint:(Vector*)B andRightPoint:(Vector*)C;
+ (Vector*)internalIntersectionWithLineA:(Line*)lineA andLineB:(Line*)lineB;
+ (Vector*)externalIntersectionWithLineA:(Line*)lineA andLineB:(Line*)lineB;
+ (NSArray<Vector*>*) findLeftAndRightSides:(Vector*) lineStart andLineEnd:(Vector*) lineEnd andRectangleCorners: (NSArray<Vector*>*) rectangleCorners;
+ (Vector*) rotatedAroundPoint:(Vector*) point andPivot:(Vector*) pivot andAngleDegrees:(double) angle;
+ (double) angleBetweenVectors:(Vector*) v1 and:(Vector*) v2;
+ (double) angleBetweenTwoLines: (Vector*) line1Start and:(Vector*) line1End and:(Vector*) line2Start and:(Vector*) line2End;
+ (double) dotProduct: (Vector*) pt1 and: (Vector*) pt2;
+ (double) magnitude:(Vector*) v;
@end
