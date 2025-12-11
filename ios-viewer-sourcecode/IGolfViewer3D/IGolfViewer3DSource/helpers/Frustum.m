//
//  Frustrum.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <GLKit/GLKit.h>
#import "Frustum.h"


@interface Frustum() {
    
    float frustum[6][4];
    
}

@end

@implementation Frustum

-(void)updateFrustrumWithModelviewMatrix:(GLKMatrix4)modelviewMatrix andProjectionMatrix:(GLKMatrix4)projectionMatrix {
    
    float clip[16];
    float t;
    
    clip[0] = modelviewMatrix.m[0] * projectionMatrix.m[0] + modelviewMatrix.m[1] * projectionMatrix.m[4] + modelviewMatrix.m[2] * projectionMatrix.m[8] + modelviewMatrix.m[3] * projectionMatrix.m[12];
    clip[1] = modelviewMatrix.m[0] * projectionMatrix.m[1] + modelviewMatrix.m[1] * projectionMatrix.m[5] + modelviewMatrix.m[2] * projectionMatrix.m[9] + modelviewMatrix.m[3] * projectionMatrix.m[13];
    clip[2] = modelviewMatrix.m[0] * projectionMatrix.m[2] + modelviewMatrix.m[1] * projectionMatrix.m[6] + modelviewMatrix.m[2] * projectionMatrix.m[10] + modelviewMatrix.m[3] * projectionMatrix.m[14];
    clip[3] = modelviewMatrix.m[0] * projectionMatrix.m[3] + modelviewMatrix.m[1] * projectionMatrix.m[7] + modelviewMatrix.m[2] * projectionMatrix.m[11] + modelviewMatrix.m[3] * projectionMatrix.m[15];
    clip[4] = modelviewMatrix.m[4] * projectionMatrix.m[0] + modelviewMatrix.m[5] * projectionMatrix.m[4] + modelviewMatrix.m[6] * projectionMatrix.m[8] + modelviewMatrix.m[7] * projectionMatrix.m[12];
    clip[5] = modelviewMatrix.m[4] * projectionMatrix.m[1] + modelviewMatrix.m[5] * projectionMatrix.m[5] + modelviewMatrix.m[6] * projectionMatrix.m[9] + modelviewMatrix.m[7] * projectionMatrix.m[13];
    clip[6] = modelviewMatrix.m[4] * projectionMatrix.m[2] + modelviewMatrix.m[5] * projectionMatrix.m[6] + modelviewMatrix.m[6] * projectionMatrix.m[10] + modelviewMatrix.m[7] * projectionMatrix.m[14];
    clip[7] = modelviewMatrix.m[4] * projectionMatrix.m[3] + modelviewMatrix.m[5] * projectionMatrix.m[7] + modelviewMatrix.m[6] * projectionMatrix.m[11] + modelviewMatrix.m[7] * projectionMatrix.m[15];
    clip[8] = modelviewMatrix.m[8] * projectionMatrix.m[0] + modelviewMatrix.m[9] * projectionMatrix.m[4] + modelviewMatrix.m[10] * projectionMatrix.m[8] + modelviewMatrix.m[11] * projectionMatrix.m[12];
    clip[9] = modelviewMatrix.m[8] * projectionMatrix.m[1] + modelviewMatrix.m[9] * projectionMatrix.m[5] + modelviewMatrix.m[10] * projectionMatrix.m[9] + modelviewMatrix.m[11] * projectionMatrix.m[13];
    clip[10] = modelviewMatrix.m[8] * projectionMatrix.m[2] + modelviewMatrix.m[9] * projectionMatrix.m[6] + modelviewMatrix.m[10] * projectionMatrix.m[10] + modelviewMatrix.m[11] * projectionMatrix.m[14];
    clip[11] = modelviewMatrix.m[8] * projectionMatrix.m[3] + modelviewMatrix.m[9] * projectionMatrix.m[7] + modelviewMatrix.m[10] * projectionMatrix.m[11] + modelviewMatrix.m[11] * projectionMatrix.m[15];
    clip[12] = modelviewMatrix.m[12] * projectionMatrix.m[0] + modelviewMatrix.m[13] * projectionMatrix.m[4] + modelviewMatrix.m[14] * projectionMatrix.m[8] + modelviewMatrix.m[15] * projectionMatrix.m[12];
    clip[13] = modelviewMatrix.m[12] * projectionMatrix.m[1] + modelviewMatrix.m[13] * projectionMatrix.m[5] + modelviewMatrix.m[14] * projectionMatrix.m[9] + modelviewMatrix.m[15] * projectionMatrix.m[13];
    clip[14] = modelviewMatrix.m[12] * projectionMatrix.m[2] + modelviewMatrix.m[13] * projectionMatrix.m[6] + modelviewMatrix.m[14] * projectionMatrix.m[10] + modelviewMatrix.m[15] * projectionMatrix.m[14];
    clip[15] = modelviewMatrix.m[12] * projectionMatrix.m[3] + modelviewMatrix.m[13] * projectionMatrix.m[7] + modelviewMatrix.m[14] * projectionMatrix.m[11] + modelviewMatrix.m[15] * projectionMatrix.m[15];
    
    /* Extract the numbers for the RIGHT plane */
    frustum[0][0] = clip[3] - clip[0];
    frustum[0][1] = clip[7] - clip[4];
    frustum[0][2] = clip[11] - clip[8];
    frustum[0][3] = clip[15] - clip[12];
    
    /* Normalize the result */
    t = (float) sqrt(frustum[0][0] * frustum[0][0] + frustum[0][1] * frustum[0][1] + frustum[0][2] * frustum[0][2]);
    frustum[0][0] /= t;
    frustum[0][1] /= t;
    frustum[0][2] /= t;
    frustum[0][3] /= t;
    
    /* Extract the numbers for the LEFT plane */
    frustum[1][0] = clip[3] + clip[0];
    frustum[1][1] = clip[7] + clip[4];
    frustum[1][2] = clip[11] + clip[8];
    frustum[1][3] = clip[15] + clip[12];
    
    /* Normalize the result */
    t = (float) sqrt(frustum[1][0] * frustum[1][0] + frustum[1][1] * frustum[1][1] + frustum[1][2] * frustum[1][2]);
    frustum[1][0] /= t;
    frustum[1][1] /= t;
    frustum[1][2] /= t;
    frustum[1][3] /= t;
    
    /* Extract the BOTTOM plane */
    frustum[2][0] = clip[3] + clip[1];
    frustum[2][1] = clip[7] + clip[5];
    frustum[2][2] = clip[11] + clip[9];
    frustum[2][3] = clip[15] + clip[13];
    
    /* Normalize the result */
    t = (float) sqrt(frustum[2][0] * frustum[2][0] + frustum[2][1] * frustum[2][1] + frustum[2][2] * frustum[2][2]);
    frustum[2][0] /= t;
    frustum[2][1] /= t;
    frustum[2][2] /= t;
    frustum[2][3] /= t;
    
    /* Extract the TOP plane */
    frustum[3][0] = clip[3] - clip[1];
    frustum[3][1] = clip[7] - clip[5];
    frustum[3][2] = clip[11] - clip[9];
    frustum[3][3] = clip[15] - clip[13];
    
    /* Normalize the result */
    t = (float) sqrt(frustum[3][0] * frustum[3][0] + frustum[3][1] * frustum[3][1] + frustum[3][2] * frustum[3][2]);
    frustum[3][0] /= t;
    frustum[3][1] /= t;
    frustum[3][2] /= t;
    frustum[3][3] /= t;
    
    /* Extract the FAR plane */
    frustum[4][0] = clip[3] - clip[2];
    frustum[4][1] = clip[7] - clip[6];
    frustum[4][2] = clip[11] - clip[10];
    frustum[4][3] = clip[15] - clip[14];
    /* Normalize the result */
    
    t = (float) sqrt(frustum[4][0] * frustum[4][0] + frustum[4][1] * frustum[4][1] + frustum[4][2] * frustum[4][2]);
    frustum[4][0] /= t;
    frustum[4][1] /= t;
    frustum[4][2] /= t;
    frustum[4][3] /= t;
    
    /* Extract the NEAR plane */
    frustum[5][0] = clip[3] + clip[2];
    frustum[5][1] = clip[7] + clip[6];
    frustum[5][2] = clip[11] + clip[10];
    frustum[5][3] = clip[15] + clip[14];
    
    /* Normalize the result */
    t = (float) sqrt(frustum[5][0] * frustum[5][0] + frustum[5][1] * frustum[5][1] + frustum[5][2] * frustum[5][2]);
    frustum[5][0] /= t;
    frustum[5][1] /= t;
    frustum[5][2] /= t;
    frustum[5][3] /= t;
}


-(BOOL)isPointVisibleWithX:(double)x andY:(double)y andZ:(double)z {
    
    for (int p = 0; p < 6; p++)
        if (frustum[p][0] * x + frustum[p][1] * y + frustum[p][2] * z + frustum[p][3] <= 0)
            return false;
    return true;
}

-(BOOL)isVectorVisible:(Vector*)v {
    
    return [self isPointVisibleWithX:v.x andY:v.y andZ:v.z];
}

-(BOOL)isCubeVisibleWithX:(double)x y:(double)y z:(double)z xSize:(double)xSize ySize:(double)ySize  zSize:(double)zSize {

    double xHalfSize = xSize / 2;
    double yHalfSize = ySize / 2;
    double zHalfSize = zSize / 2;
    
    for (int p = 0; p < 6; p++) {
        if (frustum[p][0] * (x - xHalfSize) + frustum[p][1] * (y - yHalfSize) + frustum[p][2] * (z - zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x + xHalfSize) + frustum[p][1] * (y - yHalfSize) + frustum[p][2] * (z - zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x - xHalfSize) + frustum[p][1] * (y + yHalfSize) + frustum[p][2] * (z - zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x + xHalfSize) + frustum[p][1] * (y + yHalfSize) + frustum[p][2] * (z - zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x - xHalfSize) + frustum[p][1] * (y - yHalfSize) + frustum[p][2] * (z + zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x + xHalfSize) + frustum[p][1] * (y - yHalfSize) + frustum[p][2] * (z + zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x - xHalfSize) + frustum[p][1] * (y + yHalfSize) + frustum[p][2] * (z + zHalfSize) + frustum[p][3] > 0)
            continue;
        if (frustum[p][0] * (x + xHalfSize) + frustum[p][1] * (y + yHalfSize) + frustum[p][2] * (z + zHalfSize) + frustum[p][3] > 0)
            continue;
        return false;
    }
    return true;
}

-(BOOL)isSphereVisibleWithX:(double)x andY:(double)y andZ:(double)z andR:(double)r {
    
    for (int p = 0; p < 6; p++) {
        if (frustum[p][0] * x + frustum[p][1] * y + frustum[p][2] * z + frustum[p][3] <= -r) {
            return false;
        }
    }
    
    return true;
}

- (BOOL)isVectorListVisible:(NSArray<Vector*>*)vectorList {
    
    for (Vector* v in vectorList) {
        if ([self isVectorVisible:v]) {
            return true;
        }
    }
    
    return false;
}

-(BOOL)isVertexListVisible:(NSArray*)vertexList {
    
    int p = 0;
    
    for (int f = 0; f < 6; f++) {
        for (p = 0; p < vertexList.count; p = p + 3) {
            if (frustum[f][0] * [[vertexList objectAtIndex:p] doubleValue] + frustum[f][1] * [[vertexList objectAtIndex:p + 1] doubleValue] + frustum[f][2] * [[vertexList objectAtIndex:p + 2] doubleValue] + frustum[f][3] > 0)
                break;
        }
        if (p + 3 >= vertexList.count)
            return false;
    }
    
    return true;
}

@end
