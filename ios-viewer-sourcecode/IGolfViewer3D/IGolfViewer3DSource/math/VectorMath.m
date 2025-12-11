//
//  VectorMath.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "VectorMath.h"
#import "Vector.h"
#import <math.h>
#import "Line.h"

@implementation VectorMath

+(NSMutableArray<Vector*>*)makeOffset:(double)offset forVectorList:(NSArray<Vector*>*)vectorList {
    NSMutableArray<Vector*>*retval = [NSMutableArray new];
    
    int n = (int)vectorList.count;
    
    double mi;
    double mi1;
    double li;
    double li1;
    double ri;
    double ri1;
    double si;
    double si1;
    double Xi1;
    double Yi1;
    
    for (int i = 0; i < vectorList.count; i++) {
        mi  = ([vectorList objectAtIndex:((i+1)%n)].y - [vectorList objectAtIndex:i].y)/([vectorList objectAtIndex:((i+1)%n)].x - [vectorList objectAtIndex:i].x);
        mi1 = ([vectorList objectAtIndex:((i+2)%n)].y - [vectorList objectAtIndex:((i+1)%n)].y)/([vectorList objectAtIndex:((i+2)%n)].x - [vectorList objectAtIndex:((i+1)%n)].x);
        li  = sqrt(([vectorList objectAtIndex:((i+1)%n)].x - [vectorList objectAtIndex:i].x)*([vectorList objectAtIndex:((i+1)%n)].x - [vectorList objectAtIndex:i].x)+([vectorList objectAtIndex:((i+1)%n)].y - [vectorList objectAtIndex:i].y)*([vectorList objectAtIndex:((i+1)%n)].y - [vectorList objectAtIndex:i].y));
        li1 = sqrt(([vectorList objectAtIndex:((i+2)%n)].x - [vectorList objectAtIndex:((i+1)%n)].x)*([vectorList objectAtIndex:((i+2)%n)].x - [vectorList objectAtIndex:((i+1)%n)].x)+([vectorList objectAtIndex:((i+2)%n)].y - [vectorList objectAtIndex:((i+1)%n)].y)*([vectorList objectAtIndex:((i+2)%n)].y - [vectorList objectAtIndex:((i+1)%n)].y));
        ri  = [vectorList objectAtIndex:i].x + offset * ([vectorList objectAtIndex:((i+1)%n)].y - [vectorList objectAtIndex:i].y)/li;
        ri1 = [vectorList objectAtIndex:((i+1)%n)].x + offset*([vectorList objectAtIndex:((i+2)%n)].y - [vectorList objectAtIndex:((i+1)%n)].y)/li1;
        si  = [vectorList objectAtIndex:i].y - offset*([vectorList objectAtIndex:((i+1)%n)].x - [vectorList objectAtIndex:i].x)/li;
        si1 = [vectorList objectAtIndex:((i+1)%n)].y - offset*([vectorList objectAtIndex:((i+2)%n)].x - [vectorList objectAtIndex:((i+1)%n)].x)/li1;
        Xi1 = (mi1*ri1-mi*ri+si-si1)/(mi1-mi);
        Yi1 = (mi*mi1*(ri1-ri)+mi1*si-mi*si1)/(mi1-mi);
        
        
        if ([vectorList objectAtIndex:((i+1)%n)].x - [vectorList objectAtIndex:((i)%n)].x == 0) {
            Xi1 = [vectorList objectAtIndex:((i+1)%n)].x + offset*([vectorList objectAtIndex:((i+1)%n)].y - [vectorList objectAtIndex:(i%n)].y) / fabs([vectorList objectAtIndex:((i+1)%n)].y - [vectorList objectAtIndex:(i%n)].y);
            Yi1 = mi1*Xi1 - mi1*ri1 + si1;
        }
        
        if ([vectorList objectAtIndex:((i+2)%n)].x - vectorList[((i+1)%n)].x == 0) {
            Xi1 = [vectorList objectAtIndex:((i+2)%n)].x + offset*([vectorList objectAtIndex:((i+2)%n)].y - [vectorList objectAtIndex:((i+1)%n)].y) / fabs([vectorList objectAtIndex:((i+2)%n)].y - [vectorList objectAtIndex:((i+1)%n)].y);
            Yi1 = mi*Xi1 - mi*ri + si;
        }
        
        [retval addObject:[[Vector alloc] initWithX:Xi1 andY:Yi1]];
        
    }
    
    return retval;
}

+(NSMutableArray<Vector *> *)normalizedVectorList:(NSArray<Vector *> *)vectorList {
    NSMutableArray<Vector*>* retval = [NSMutableArray new];
    
    for (int i = 0; i < vectorList.count; i++) {
        Vector* a = [vectorList objectAtIndex:i];
        Vector* b = i == (int)vectorList.count - 1 ? vectorList.firstObject : [vectorList objectAtIndex:i+1];
        
        Vector* output = [VectorMath multipliedWithVector:[VectorMath addedWithVector1:a andVector2:b] andFactor:0.5];//[[Vector alloc] initWithX:(a.x + b.x) / 2 andY:(a.y + b.y) / 2];
        
        [retval addObject: output];
    }
    
    return retval;
}

+ (NSMutableArray<Vector*>*)vectorList:(NSArray<Vector*>*)vectorList byRemovingVectorList:(NSArray<Vector*>*)removingList {
    NSMutableArray<Vector*>* retval = [NSMutableArray new];
    
    for (Vector* controlVector in vectorList) {
        
        BOOL check = true;
        
        for (Vector* v in removingList) {
            if ([controlVector isEqualToVector:v]) {
                check = false;
                break;
            }
        }
        
        if (check) {
            [retval addObject:controlVector];
        }
    }
    
    return retval;
}

+ (NSMutableArray<Vector*>*)closedVectorList:(NSArray<Vector*>*)vectorList {
    NSMutableArray<Vector*>* retval = [vectorList mutableCopy];
    
    if (![retval.firstObject isEqualToVector:retval.lastObject]) {
        [retval addObject:retval.firstObject];
    }
    
    return retval;
}

+ (NSMutableArray<Vector*>*)unclosedVectorList:(NSArray<Vector*>*)vectorList {
    NSMutableArray<Vector*>* retval = [vectorList mutableCopy];
    
    if ([retval.firstObject isEqualToVector:retval.lastObject]) {
        [retval removeLastObject];
    }
    
    return retval;
}

+ (NSMutableArray<Vector*>*)filterDuplicatesInVectorList:(NSArray<Vector*>*)vectorList {
    
    NSMutableArray<Vector*>* retval = [NSMutableArray new];
    
    for (Vector* v in vectorList) {
        if (retval.count > 0) {
            if ([v isEqualToVector:retval.lastObject]) {
                continue;
            }
        }

        [retval addObject:[[Vector alloc] initWithX:v.x andY:v.y]];
    }
    
    return retval;
}

+ (NSMutableArray<Vector*>*)vectorList:(NSArray<Vector*>*)vectorList withOrder:(VectorOrder)order {
    
    if ([VectorMath getVectorOrderWithVectorArray:vectorList] != order) {
        return [[[[vectorList mutableCopy] reverseObjectEnumerator] allObjects] mutableCopy];
    } else {
        return [vectorList mutableCopy];
    }
}



+ (VectorOrder)getVectorOrderWithVectorArray:(NSArray<Vector*>*)array {
    double sum = 0;
    for (int i = 0 ; i < array.count ; i++) {
        Vector* v1 = array[i];
        Vector* v2 = array[(i+1) % array.count];
        sum += (v2.x - v1.x) * (v2.y + v1.y);
    }

    return sum > 0 ? VectorOrderCW : VectorOrderCCW;
}

+ (double)angleWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 andVector3:(Vector*)pt3 {
    Vector* v1 = [[Vector alloc] initWithX:pt1.x - pt2.x andY:pt1.y - pt2.y];
    Vector* v2 = [[Vector alloc] initWithX:pt3.x - pt2.x andY:pt3.y - pt2.y];
    double cos = (v1.x * v2.x + v1.y * v2.y) / (sqrt(v1.x * v1.x + v1.y * v1.y) * sqrt(v2.x * v2.x + v2.y * v2.y));
    cos = MAX(cos, -1);
    cos = MIN(cos, 1);
    return acos(cos);
}

+ (double)angle2WithVector1:(Vector*)previous andVector2:(Vector*)center andVector3:(Vector*)current {
    
    
    double result = atan2(previous.y - center.y, previous.x - center.x) -
    atan2(current.y - center.y, current.x - center.x);
    return result;
    //return (atan2( current.y - center.y , current.x - center.x) - atan2( previous.y - center.y , previous.x- center.x));
}


+ (Vector*)substractedWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    return [[Vector alloc] initWithX:pt1.x - pt2.x andY:pt1.y - pt2.y];
}

+(Vector*)crossWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    Vector* retval = [[Vector alloc] init];
    retval.x = pt1.y * pt2.z - pt1.z * pt2.y;
    retval.y = pt1.z * pt2.x - pt1.x * pt2.z;
    retval.z = pt1.x * pt2.y - pt1.y * pt2.x;
    return retval;
}

+ (Vector*)substracted3WithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    return [[Vector alloc] initWithX:pt1.x - pt2.x andY:pt1.y - pt2.y andZ:pt1.z - pt2.z];
}

+ (Vector*)addedWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    return [[Vector alloc] initWithX:pt1.x + pt2.x andY:pt1.y + pt2.y];
}

+ (Vector*)normalizedWithVector:(Vector*)pt {
    double inv_len = 1.0 / [VectorMath distanceWithVector:pt];
    return [[Vector alloc] initWithX:pt.x * inv_len andY:pt.y * inv_len];
}

+(Vector*)getTriangleNormalV1:(Vector*)a andV2:(Vector*)b andV3:(Vector*)c {
    Vector* v1 = [[Vector alloc] init];
    Vector* v2 = [[Vector alloc] init];
    Vector* n = [[Vector alloc] init];
    v1.x = a.x - b.x;
    v1.y = a.y - b.y;
    v1.z = a.z - b.z;
    
    v2.x = b.x - c.x;
    v2.y = b.y - c.y;
    v2.z = b.z - c.z;
    
    double wrki = sqrt((v1.y*v2.z - v1.z * v2.y) * (v1.y*v2.z - v1.z * v2.y) + (v1.z * v2.x - v1.x * v2.z) * (v1.z * v2.x - v1.x * v2.z) + (v1.x * v2.y - v1.y * v2.x) * (v1.x * v2.y - v1.y * v2.x));
    
    n.x = (v1.y * v2.z - v1.z * v2.y) / wrki;
    n.y = (v1.z * v2.x - v1.x * v2.z) / wrki;
    n.z = (v1.x * v2.y - v1.y * v2.x) / wrki;
    
    return n;
}

+(Vector*)getTriangleNormalWithV1:(Vector*)a andV2:(Vector*)b andV3:(Vector*)c {
    Vector* v1 = [[Vector alloc] init];
    Vector* v2 = [[Vector alloc] init];
    Vector* n = [[Vector alloc] init];
    v1.x = a.x - b.x;
    v1.y = a.y - b.y;
    v1.z = a.z - b.z;
    
    v2.x = b.x - c.x;
    v2.y = b.y - c.y;
    v2.z = b.z - c.z;
    
    double wrki = sqrt((v1.y*v2.z - v1.z * v2.y) * (v1.y*v2.z - v1.z * v2.y) + (v1.z * v2.x - v1.x * v2.z) * (v1.z * v2.x - v1.x * v2.z) + (v1.x * v2.y - v1.y * v2.x) * (v1.x * v2.y - v1.y * v2.x));
    
    n.x = (v1.y * v2.z - v1.z * v2.y) / wrki;
    n.y = (v1.z * v2.x - v1.x * v2.z) / wrki;
    n.z = (v1.x * v2.y - v1.y * v2.x) / wrki;
    
    return n;
}

+(Vector*)getNormalWithVector1:(Vector*)v1 andVector2:(Vector*)v2 andVector3:(Vector*)v3; {
    Vector* edge1 = [VectorMath substracted3WithVector1:v2 andVector2:v1];
    Vector* edge2 = [VectorMath substracted3WithVector1:v3 andVector2:v1];
    Vector* cross = [VectorMath crossWithVector1:edge1 andVector2:edge2];
    return  [VectorMath normalizedWithVector3:cross];
}

+ (Vector*)normalizedWithVector3:(Vector*)pt {
    double inv_len = 1.0 / [VectorMath distanceWithVector:pt];
    return [[Vector alloc] initWithX:pt.x * inv_len andY:pt.y * inv_len andZ:pt.z * inv_len];
}

+ (Vector*)multipliedWithVector:(Vector*)pt andFactor:(double)factor {
    return [[Vector alloc] initWithX:pt.x * factor andY:pt.y * factor];
}

+ (Vector*)rotatedWithVector:(Vector*)pt andAngle:(double)angle {
    double sinus = sin(angle);
    double cosinus = cos(angle);
    double newX = -(pt.y) * sinus + (pt.x) * cosinus;
    double newY = (pt.y) * cosinus + (pt.x) * sinus;
    return [[Vector alloc] initWithX:newX andY:newY];
}

+ (double)distanceWithVector:(Vector*)vector {
    return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

+ (double)distanceWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    return sqrt(pow(pt1.x - pt2.x, 2) + pow(pt1.y - pt2.y, 2));
}

+ (double)distanceWithVector3D1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    return sqrt(pow(pt1.x - pt2.x, 2) + pow(pt1.y - pt2.y, 2) + pow(pt1.z - pt2.z, 2));
}

+ (double)distance3DWithVector1:(Vector*)pt1 andVector2:(Vector*)pt2 {
    return sqrt(pow(pt1.x - pt2.x, 2) + pow(pt1.y - pt2.y, 2) + pow(pt1.y - pt2.y, 2));
}

+ (double)distanceWithVectorArray:(NSArray<Vector*>*)vectors {
    double retval = 0.0;

    if (vectors.count > 1) {
        for (int i = 0 ; i < vectors.count-1 ; i++) {
            retval += [VectorMath distanceWithVector1:vectors[i] andVector2:vectors[i+1]];
        }
    }
    
    return retval;
}

+ (double)deg2radWithDeg:(double)deg {
    return deg * M_PI / 180.0;
}

+ (double)rad2degWithRad:(double)rad {
    return rad / M_PI * 180;
}

+ (BOOL)isVector:(Vector*)vector insidePolygon:(NSArray<Vector*>*)polygon {
    BOOL c = NO;
    for (unsigned long i = 0, j = polygon.count-1; i < polygon.count; j = i++) {
        if ( ((polygon[i].y>vector.y) != (polygon[j].y>vector.y)) &&
            (vector.x < (polygon[j].x-polygon[i].x) * (vector.y-polygon[i].y) / (polygon[j].y-polygon[i].y) + polygon[i].x) )
            c = !c;
    }
    return c;
}

+ (Vector*)intersectionWithLineA:(Line*)lineA andLineB:(Line*)lineB {
    
    Vector* p1 = lineA.p1;
    Vector* p2 = lineA.p2;
    Vector* p3 = lineB.p1;
    Vector* p4 = lineB.p2;
    
    double d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    
    if (d == 0) {
        //parallel lines
        return nil;
    }
    
    double u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    
    Vector* intersection = [Vector new];
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    return intersection;
}

+ (Vector*)internalIntersectionWithLineA:(Line*)lineA andLineB:(Line*)lineB {
    
    Vector* p1 = lineA.p1;
    Vector* p2 = lineA.p2;
    Vector* p3 = lineB.p1;
    Vector* p4 = lineB.p2;
    
    double d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0) {
        //NSLog(@"PARALEL LINES");
        return nil;
    }
    // parallel lines
    double u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    double v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
    
    if (u < 0.0 || u > 1.0) {
        return nil; // intersection point not between p1 and p2
    }
    
    if (v < 0.0 || v > 1.0) {
        return nil; // intersection point not between p3 and p4
    }
    
    Vector* intersection = [Vector new];
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    if ([intersection isEqualToVector:p1] || [intersection isEqualToVector:p2] || [intersection isEqualToVector:p3] || [intersection isEqualToVector:p4]) {
        return nil;
    }
    
    return intersection;
}

+ (Vector*)externalIntersectionWithLineA:(Line*)lineA andLineB:(Line*)lineB {
    
    Vector* p1 = lineA.p1;
    Vector* p2 = lineA.p2;
    Vector* p3 = lineB.p1;
    Vector* p4 = lineB.p2;
    
    double d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0) {
        //NSLog(@"PARALEL LINES");
        return nil;
    }
    // parallel lines
    double u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    double v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
    
    if (v < 0.0 || v > 1.0) {
        return nil; // intersection point not between p3 and p4
    }
    
    Vector* intersection = [Vector new];
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    if ([intersection isEqualToVector:p1] || [intersection isEqualToVector:p2] || [intersection isEqualToVector:p3] || [intersection isEqualToVector:p4]) {
        return nil;
    }
    
    return intersection;
}

+ (Vector*)intersectionWithVectorLine1V1:(Vector*)p1 andLine1V2:(Vector*)p2 andLine2V1:(Vector*)p3 andLine2V2:(Vector*)p4 {
    
    double d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x);
    if (d == 0) {
        return nil;
    }
         // parallel lines
    double u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d;
    double v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d;
    if (u < 0.0 || u > 1.0) {
        return nil; // intersection point not between p1 and p2
    }
    
    if (v < 0.0 || v > 1.0) {
        return nil; // intersection point not between p3 and p4
    }
    
    Vector* intersection = [Vector new];
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    return intersection;
}

+ (Vector*)calculateProjectionPointWithPoint:(Vector*)point andLinePoint1:(Vector*)linePoint1 andLinePoint2:(Vector*)linePoint2 {
    Vector* retval = nil;
    double lengthSquared = [VectorMath lengthSquaredWithVector1:linePoint1 andVector2:linePoint2];
    Vector* p = [[Vector alloc] initWithVector:point];
    
    if (lengthSquared == 0) {
        return linePoint1;
    }

    double projectionFactor = [VectorMath dotProductWitnPoint1:p andPoint2:linePoint1 andPoint3:linePoint2] / lengthSquared;
    if (projectionFactor >= 0 && projectionFactor <= 1) {
        retval = [[[linePoint2 substractedWithVector:linePoint1] multipliedWithFactor:projectionFactor] addedWithVector:linePoint1];
    }

    return retval;
}

+ (double)lengthSquaredWithVector1:(Vector*)vector1 andVector2:(Vector*)vector2 {
    return pow(vector2.x - vector1.x, 2) + pow(vector2.y - vector1.y, 2);
}

+ (double)dotProductWitnPoint1:(Vector*)pt1 andPoint2:(Vector*)pt2 andPoint3:(Vector*)pt3 {
    Vector* v1 = [[Vector alloc] initWithX:pt1.x - pt2.x andY:pt1.y - pt2.y];
    Vector* v2 = [[Vector alloc] initWithX:pt3.x - pt2.x andY:pt3.y - pt2.y];

    return v1.x * v2.x + v1.y * v2.y;
}

+ (NSMutableArray<Vector*>*)intersectionPointsWithVectorList:(NSArray<Vector*>*)vectorList {
    
    NSMutableArray<Line*>* lines = [NSMutableArray new];
    NSArray<Vector*>* unclosed = [VectorMath unclosedVectorList:vectorList];
    NSMutableArray<Vector*>* retval = [NSMutableArray new];
    
    for (int i = 0; i < unclosed.count; i ++) {
        Vector* prev = (i == 0) ? unclosed.lastObject : [unclosed objectAtIndex: i - 1];
        Vector* current = [unclosed objectAtIndex:i];
        
        [lines addObject:[[Line alloc]initWithP1:prev andP2:current]];
    }

    for (int i = 0; i < lines.count - 1; i++) {
        
        Line* current = [lines objectAtIndex:i];

        for (int k = i + 1; k < lines.count; k++) {
            
            Line* line = [lines objectAtIndex:k];
            
            Vector* intersectionPoint = [VectorMath internalIntersectionWithLineA:current andLineB:line];
            
            if (intersectionPoint != nil) {
                [retval addObject:intersectionPoint];
            }
        }
    }
   
    return retval;
}

+ (NSArray<Vector*>*)polygonizeVectorList:(NSArray<Vector*>*)vectorList {
    
    
//    public static Comparator<Vector> byAngleComparator(Vector center) {
//        final double centerX = center.x;
//        final double centerY = center.y;
//        return new Comparator<Vector>() {
//            @Override
//            public int compare(Vector p0, Vector p1) {
//                double angle0 = angleToX(
//                                         centerX, centerY, p0.x, p0.y);
//                double angle1 = angleToX(
//                                         centerX, centerY, p1.x, p1.y);
//                return Double.compare(angle0, angle1);
//            }
//        };
//    }
    
    Vector* centroid = [VectorMath calculateCenteroidWithVectorArray:vectorList];
    
    NSMutableArray<Vector*>* retval = vectorList.mutableCopy;
    
    double centerX = centroid.x;
    double centerY = centroid.y;
    
    [retval sortUsingComparator:^NSComparisonResult(Vector* pt0, Vector* pt1) {
        
        double angle0 = [VectorMath angleToXWithX0:centerX andY0:centerY andX1:pt0.x andY1:pt0.y];
        double angle1 = [VectorMath angleToXWithX0:centerX andY0:centerY andX1:pt1.x andY1:pt1.y];
        
        return angle0 > angle1;
    }];
    
    return retval;
}

+ (double)angleToXWithX0:(double)x0 andY0:(double)y0 andX1:(double)x1 andY1:(double)y1 {
    double dx = x1 - x0;
    double dy = y1 - y0;
    return atan2(dy, dx);
}


+ (Vector*)calculateCenteroidWithVectorArray:(NSArray<Vector*>*)vectorArray {

    Vector* retval = [Vector new];

    for (Vector* vector in vectorArray) {
        retval = [retval addedWithVector:vector];
    }

    retval = [retval multipliedWithFactor:1.0 / vectorArray.count];

    return retval;
}

+ (Vector*)calculateZpositionForPointWithX:(double)x andY:(double)y andBasePoint:(Vector*)A andUpPoint:(Vector*)B andRightPoint:(Vector*)C {
    
    Vector* U = [[Vector alloc] initWithX:x andY:y];
    double p1 = A.x * B.y * C.z;
    double p2 = A.x * B.z * C.y;
    double p3 = A.x * B.z * U.y;
    double p4 = A.x * C.z * U.y;
    double p5 = A.y * B.x * C.z;
    double p6 = A.y * B.z * C.x;
    double p7 = A.y * B.z * U.x;
    double p8 = A.y * C.z * U.x;
    double p9 = A.z * B.x * C.y;
    double p10 = A.z * B.x * U.y;
    double p11 = A.z * B.y * C.x;
    double p12 = A.z * B.y * U.x;
    double p13 = A.z * C.x * U.y;
    double p14 = A.z * C.y * U.x;
    double p15 = B.x * C.z * U.y;
    double p16 = B.y * C.z * U.x;
    double p17 = B.z * C.x * U.y;
    double p18 = B.z * C.y * U.x;
    
    double d1 = A.x * B.y;
    double d2 = A.x * C.y;
    double d3 = A.y * B.x;
    double d4 = A.y * C.x;
    double d5 = B.x * C.y;
    double d6 = B.y * C.x;
    
    double p = p1 - p2 + p3 - p4 - p5 + p6 - p7 + p8 + p9 - p10 - p11 + p12 + p13 - p14 + p15 - p16 - p17 + p18;
    double d = d1 - d2 - d3 + d4 + d5 - d6;
    
    U.z = p/d;
    
    return U;
}

+ (NSArray<Vector*>*) findLeftAndRightSides:(Vector*) lineStart andLineEnd:(Vector*) lineEnd andRectangleCorners: (NSArray<Vector*>*) rectangleCorners {
    Vector* lineVector = [[Vector alloc] initWithX:lineEnd.x - lineStart.x andY:lineEnd.y - lineStart.y];
    double smallestAngle = FLT_MAX;
    NSInteger leftSideIndex = -1;
    NSInteger rightSideIndex = -1;
    for (int i = 0; i < rectangleCorners.count; i++) {
        Vector* rectEdge = [[Vector alloc]
                             initWithX:
                         rectangleCorners[(i + 1) % rectangleCorners.count].x - rectangleCorners[i].x 
                            andY:
                         rectangleCorners[(i + 1) % rectangleCorners.count].y - rectangleCorners[i].y
                 ];
        double angle = [VectorMath angleBetweenVectors:lineVector and:rectEdge];

        if (angle < smallestAngle) {
            smallestAngle = angle;
            leftSideIndex = i;
            rightSideIndex = (i + 1) % rectangleCorners.count;
        }
    }
    Vector* leftSideStart = rectangleCorners[leftSideIndex];
    Vector* leftSideEnd = rectangleCorners[(leftSideIndex + 1) % rectangleCorners.count];
    Vector* rightSideStart = rectangleCorners[rightSideIndex];
    Vector* rightSideEnd = rectangleCorners[(rightSideIndex + 1) % rectangleCorners.count];
    NSMutableArray<Vector*>* retVal = [NSMutableArray new];
    
    [retVal addObject:leftSideStart];
    [retVal addObject:leftSideEnd];
    [retVal addObject:rightSideStart];
    [retVal addObject:rightSideEnd];
    return rectangleCorners;
}

+ (double) angleBetweenTwoLines: (Vector*) line1Start and:(Vector*) line1End and:(Vector*) line2Start and:(Vector*) line2End {
        double angle1 = atan2(line1End.y - line1Start.y, line1Start.x - line1End.x);
        double angle2 = atan2(line2End.y - line2Start.y, line2Start.x - line2End.x);
        double calculatedAngle = [VectorMath rad2degWithRad:(angle1 - angle2)];
        return calculatedAngle;
}

+ (Vector*) rotatedAroundPoint:(Vector*) point andPivot:(Vector*) pivot andAngleDegrees:(double) angle {
        float angleRadians = [VectorMath deg2radWithDeg: angle];

        float cosTheta = cos(angleRadians);
        float sinTheta = sin(angleRadians);

        double x = point.x;
        double y = point.y;
        double x0 = pivot.x;
        double y0 = pivot.y;

        double x2 = x0+(x-x0)*cosTheta+(y-y0)*sinTheta;
        double y2 = y0-(x-x0)*sinTheta+(y-y0)*cosTheta;
    
        return [[Vector alloc] initWithX: x2 andY:y2];
    }

+ (double) angleBetweenVectors:(Vector*) v1 and:(Vector*) v2 {
    double dot = [VectorMath dotProduct:v1 and:v2];
    double mag1 = [VectorMath magnitude: v1];
    double mag2 = [VectorMath magnitude:v2];
    return acos(dot / (mag1 * mag2));
}

+ (double) dotProduct: (Vector*) pt1 and: (Vector*) pt2 {
    return pt1.x * pt2.x + pt1.y * pt2.y + pt1.z * pt2.z;
}

+ (double) magnitude:(Vector*) v {
    return sqrt(v.x * v.x + v.y * v.y);
}



@end
