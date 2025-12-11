//
//  Triangle.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Triangle.h"
#import "Ray.h"
#import "TriangleVector.h"

#define SMALL_NUM 0.0000000000000000001f // anything that avoids division overflow

@interface Triangle () {
    float V0[3];
    float V1[3];
    float V2[3];
}

@end

@implementation Triangle

- (id)initWithV0:(float*)v0 andV1:(float*)v1 andV2:(float*)v2 {
    self = [super init];
    
    if (self) {
        memcpy(V0, v0, sizeof(V0));
        memcpy(V1, v1, sizeof(V1));
        memcpy(V2, v2, sizeof(V2));
    }
    
    return self;
}

// intersectRayAndTriangle(): intersect a ray with a 3D triangle
//    Input:  a ray R, and a triangle T
//    Output: *I = intersection point (when it exists)
//    Return: -1 = triangle is degenerate (a segment or point)
//             0 = disjoint (no intersect)
//             1 = intersect in unique point I1
//             2 = are in the same plane

+ (int)intersectWithRay:(Ray*)R andTriangle:(Triangle*)T andI:(float*)Ival {


    float u[3], v[3], n[3];
    float dir[3], w0[3], w[3];
    float r, a, b;

    [TriangleVector minusWithU:T->V1 andV:T->V0 andOut:u];
    [TriangleVector minusWithU:T->V2 andV:T->V0 andOut:v];
    [TriangleVector crossProductWithU:u andV:v andOut:n];

    if (n[0] == 0 && n[1] == 0 && n[2] == 0) {
        return -1;
    }

    [TriangleVector minusWithU:R->P1 andV:R->P0 andOut:dir];
    [TriangleVector minusWithU:R->P0 andV:T->V0 andOut:w0];

    a = -[TriangleVector dotWithU:n andV:w0];
    b = [TriangleVector dotWithU:n andV:dir];

    if (fabs(b) < SMALL_NUM) {
        if (a == 0) {
            return 2;
        } else {
            return 0;
        }
    }
    
    r = a / b;

    if (r < 0.0f) {
        return 0;
    }

    float tempI[3];
    float tempScalar[3];
    [TriangleVector scalarProductWithR:r andU:dir andOut:tempScalar];
    [TriangleVector additionWithU:R->P0 andV:tempScalar andOut:tempI];

    memcpy(Ival, tempI, sizeof(tempI));

    float uu, uv, vv, wu, wv, D;

    uu = [TriangleVector dotWithU:u andV:u];
    uv =[TriangleVector dotWithU:u andV:v];
    vv = [TriangleVector dotWithU:v andV:v];

    [TriangleVector minusWithU:Ival andV:T->V0 andOut:w];

    wu = [TriangleVector dotWithU:w andV:u];
    wv = [TriangleVector dotWithU:w andV:v];
    D = (uv * uv) - (uu * vv);


    float s, t;
    s = ((uv * wv) - (vv * wu)) / D;

    if (s < 0.0f || s > 1.0f) {

        return 0;
    }
    

    t = (uv * wu - uu * wv) / D;

    if (t < 0.0f || (s + t) > 1.0f)
        return 0;
    
    return 1;
}

@end
