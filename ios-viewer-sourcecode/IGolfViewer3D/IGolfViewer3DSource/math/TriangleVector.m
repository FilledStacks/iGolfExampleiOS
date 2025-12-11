//
//  TriangleVector.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "TriangleVector.h"

static const int __triangle_vector_X = 0;
static const int __triangle_vector_Y = 1;
static const int __triangle_vector_Z = 2;


@implementation TriangleVector

+ (float)dotWithU:(float*)u andV:(float*)v {
    int X = __triangle_vector_X;
    int Y = __triangle_vector_Y;
    int Z = __triangle_vector_Z;
    return ((u[X] * v[X]) + (u[Y] * v[Y]) + (u[Z] * v[Z]));
}

+ (void)minusWithU:(float*)u andV:(float*)v andOut:(float*)outVector {
    int X = __triangle_vector_X;
    int Y = __triangle_vector_Y;
    int Z = __triangle_vector_Z;
    outVector[X] = u[X] - v[X];
    outVector[Y] = u[Y] - v[Y];
    outVector[Z] = u[Z] - v[Z];
}

+ (void)additionWithU:(float*)u andV:(float*)v andOut:(float*)outVector {
    int X = __triangle_vector_X;
    int Y = __triangle_vector_Y;
    int Z = __triangle_vector_Z;

    outVector[X] = u[X] + v[X];
    outVector[Y] = u[Y] + v[Y];
    outVector[Z] = u[Z] + v[Z];
}

+ (void)scalarProductWithR:(float)r andU:(float*)u andOut:(float*)outVector {
    int X = __triangle_vector_X;
    int Y = __triangle_vector_Y;
    int Z = __triangle_vector_Z;

    outVector[X] = u[X] * r;
    outVector[Y] = u[Y] * r;
    outVector[Z] = u[Z] * r;
}

+ (void)crossProductWithU:(float*)u andV:(float*)v andOut:(float*)outVector {
    int X = __triangle_vector_X;
    int Y = __triangle_vector_Y;
    int Z = __triangle_vector_Z;

    outVector[X] = (u[Y] * v[Z]) - (u[Z] * v[Y]);
    outVector[Y] = (u[Z] * v[X]) - (u[X] * v[Z]);
    outVector[Z] = (u[X] * v[Y]) - (u[Y] * v[X]);
}

+ (float)lengthWithU:(float*)u {
    int X = __triangle_vector_X;
    int Y = __triangle_vector_Y;
    int Z = __triangle_vector_Z;
    
    return fabs(sqrt((u[X] * u[X]) + (u[Y] * u[Y]) + (u[Z] * u[Z])));
}

@end
