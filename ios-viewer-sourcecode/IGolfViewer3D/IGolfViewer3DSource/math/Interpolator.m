//
//  Interpolator.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Interpolator.h"
#import "CatmullRomType.h"
#import "Vector.h"


@implementation Interpolator

/**
 * This method will calculate the Catmull-Rom interpolation curve, returning
 * it as a list of Coord coordinate objects.  This method in particular
 * adds the first and last control points which are not visible, but required
 * for calculating the spline.
 *
 * @param coordinates      The list of original straight line points to calculate
 *                         an interpolation from.
 * @param pointsPerSegment The integer number of equally spaced points to
 *                         return along each curve.  The actual distance between each
 *                         point will depend on the spacing between the control points.
 * @param curveType        Chordal (stiff), Uniform(floppy), or Centripetal(medium)
 * @return The list of interpolated coordinates.
 * @throws Exception if
 *                   pointsPerSegment is less than 2.
 */

+ (NSArray<Vector*>*)interpolateWithCoordinateArray:(NSArray<Vector*>*)coordinates andPointsPerSegment:(int)pointsPerSegment andCurveType:(CatmullRomType)curveType {

    NSMutableArray<Vector*>* vertices = [NSMutableArray new];

    for (Vector* c in coordinates) {
        [vertices addObject:[c copy]];
    }

    if (pointsPerSegment < 2) {
        return nil;
    }

    if (vertices.count < 3) {
        return vertices;
    }

    BOOL isClosed = [vertices.firstObject isEqualToVector:vertices.lastObject];

    if (isClosed) {
        Vector* p2 = [[Vector alloc] initWithVector:vertices[1]];
        Vector* pn1 = [[Vector alloc] initWithVector:vertices[vertices.count-2]];
        
        [vertices insertObject:pn1 atIndex:0];
        [vertices addObject:p2];
    } else {

        double dx = vertices[1].x - vertices[0].x;
        double dy = vertices[1].y - vertices[0].y;
        
        double x1 = vertices[0].x - dx;
        double y1 = vertices[0].y - dy;

        Vector* start = [[Vector alloc] initWithX:x1 andY:y1];
        
        unsigned long n = vertices.count - 1;
        dx = vertices[n].x - vertices[n - 1].x;
        dy = vertices[n].y - vertices[n - 1].y;
        
        double xn = vertices[n].x + dx;
        double yn = vertices[n].y + dy;

        Vector* end = [[Vector alloc] initWithX:xn andY:yn];
        
        [vertices insertObject:start atIndex:0];

        [vertices addObject:end];
    }

    NSMutableArray<Vector*>* result = [NSMutableArray new];
    // When looping, remember that each cycle requires 4 points, starting
    // with i and ending with i+3.  So we don't loop through all the points.

    for (int i = 0 ; i < vertices.count - 3 ; i++) {
        // Actually calculate the Catmull-Rom curve for one segment.

        NSMutableArray<Vector*>* points = [self interpolateWithPointArray:vertices andIndex:i andPointsPerSegment:pointsPerSegment andCurveType:curveType];
        // Since the middle points are added twice, once for each bordering
        // segment, we only added the 0 index result point for the first
        // segment.  Otherwise we will have duplicate points.

        if (result.count > 0) {
            [points removeObjectAtIndex:0];
        }
        
        // Add the coordinates for the segment to the result list.
        
        [result addObjectsFromArray:points];
    }

    return result;
}

/**
 * Given a list of control points, this will create a list of pointsPerSegment
 * points spaced uniformly along the resulting Catmull-Rom curve.
 *
 * @param points           The list of control points, leading and ending with a
 *                         coordinate that is only used for controling the spline and is not visualized.
 * @param index            The index of control point p0, where p0, p1, p2, and p3 are
 *                         used in order to create a curve between p1 and p2.
 * @param pointsPerSegment The total number of uniformly spaced interpolated
 *                         points to calculate for each segment. The larger this number, the
 *                         smoother the resulting curve.
 * @param curveType        Clarifies whether the curve should use uniform, chordal
 *                         or centripetal curve types. Uniform can produce loops, chordal can
 *                         produce large distortions from the original lines, and centripetal is an
 *                         optimal balance without spaces.
 * @return the list of coordinates that define the CatmullRom curve
 * between the points defined by index+1 and index+2.
 */
//private class func interpolate(points: [Vector], index: Int, pointsPerSegment: Int, curveType: CatmullRomType) -> [Vector] {
+ (NSMutableArray<Vector*>*)interpolateWithPointArray:(NSArray<Vector*>*)points andIndex:(int)index andPointsPerSegment:(int)pointsPerSegment andCurveType:(CatmullRomType)curveType {

    NSMutableArray<Vector*>* result = [NSMutableArray new];

    double x[4] = {0};
    double y[4] = {0};

    double time[4] = {0};

    for (int i = 0 ; i < 4 ; i++) {

        x[i] = points[index + i].x;

        y[i] = points[index + i].y;

        time[i] = i;
    }
  

    double tstart = 1.0;

    double tend = 2.0;

    if (curveType != CatmullRomTypeUniform) {

        double total = 0.0;
        
        for (int i = 1 ; i < 4 ; i++) {
            double dx = x[i] - x[i - 1];
            double dy = y[i] - y[i - 1];

            if (curveType == CatmullRomTypeCentripetal) {
                total += pow(dx * dx + dy * dy, 0.25);
            } else {
                total += pow(dx * dx + dy * dy, 0.5);
            }
            
            time[i] = total;
        }

        tstart = time[1];
        tend = time[2];
    }

    int segments = pointsPerSegment - 1;

    [result addObject:points[index + 1]];

    for (int i = 1 ; i < segments ; i++) {

        double xi = [Interpolator interpolateWithPointArray:x andTimeArray:time andT:tstart + ((double)i * (tend - tstart)) / (double)segments];
        double yi = [Interpolator interpolateWithPointArray:y andTimeArray:time andT:tstart + ((double)i * (tend - tstart)) / (double)segments];

        [result addObject:[[Vector alloc] initWithX:xi andY:yi]];
    }

    [result addObject:points[index+2]];

    return result;
}

/**
 * Unlike the other implementation here, which uses the default "uniform"
 * treatment of t, this computation is used to calculate the same values but
 * introduces the ability to "parameterize" the t values used in the
 * calculation. This is based on Figure 3 from
 * http://www.cemyuksel.com/research/catmullrom_param/catmullrom.pdf
 *
 * @param p    An array of double values of length 4, where interpolation
 *             occurs from p1 to p2.
 * @param time An array of time measures of length 4, corresponding to each
 *             p value.
 * @param t    the actual interpolation ratio from 0 to 1 representing the
 *             position between p1 and p2 to interpolate the value.
 * return
 */

+ (double)interpolateWithPointArray:(double[])p andTimeArray:(double[])time andT:(double)t {
    double L01 = p[0] * (time[1] - t) / (time[1] - time[0]) + p[1] * (t - time[0]) / (time[1] - time[0]);
    double L12 = p[1] * (time[2] - t) / (time[2] - time[1]) + p[2] * (t - time[1]) / (time[2] - time[1]);
    double L23 = p[2] * (time[3] - t) / (time[3] - time[2]) + p[3] * (t - time[2]) / (time[3] - time[2]);
    double L012 = L01 * (time[2] - t) / (time[2] - time[0]) + L12 * (t - time[0]) / (time[2] - time[0]);
    double L123 = L12 * (time[3] - t) / (time[3] - time[1]) + L23 * (t - time[1]) / (time[3] - time[1]);
    double C12 = L012 * (time[2] - t) / (time[2] - time[1]) + L123 * (t - time[1]) / (time[2] - time[1]);

    return C12;
}

@end
