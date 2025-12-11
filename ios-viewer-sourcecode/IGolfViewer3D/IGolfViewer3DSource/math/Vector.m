//
//  Vector.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Vector.h"
#import "VectorMath.h"

@implementation Vector

-(NSString *)string {
    return [NSString stringWithFormat:@"X: %f, Y: %f, Z: %f", self.x, self.y, self.z];
}

- (BOOL)isEqualToVector:(Vector*)vector {
    return self.x == vector.x && self.y == vector.y;
}

- (id)copyWithZone:(NSZone*)zone {
    Vector* vector = [[[self class] allocWithZone:zone] init];
    vector.x = self.x;
    vector.y = self.y;
    return vector;
}

- (id)initWithX:(double)x andY:(double)y {
    self = [super init];

    if (self) {
        self.x = x;
        self.y = y;
        self.z = 0;
    }

    return self;
}

- (id)initWithX:(double)x andY:(double)y andZ:(double)z{
    self = [super init];
    
    if (self) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    
    return self;
}

- (id)initWithVector:(Vector*)vector {
    self = [super init];
    
    if (self) {
        self.x = vector.x;
        self.y = vector.y;
    }
    
    return self;
}

- (Vector*)substractedWithVector:(Vector*)vector {
    return [VectorMath substractedWithVector1:self andVector2:vector];
}

- (Vector*)addedWithVector:(Vector*)vector {
    return [VectorMath addedWithVector1:self andVector2:vector];
}

- (Vector*)normalized {
    return [VectorMath normalizedWithVector:self];
}

- (Vector*)multipliedWithFactor:(double)factor {
    return [VectorMath multipliedWithVector:self andFactor:factor];
}

- (Vector*)rotatedWithAngle:(double)angle {
    return [VectorMath rotatedWithVector:self andAngle:angle];
}

- (double)distanceWithVector:(Vector*)vector {
    return [VectorMath distanceWithVector1:self andVector2:vector];
}

- (BOOL)isInsideRect:(CGRect)rect {
    return CGRectContainsPoint(rect, CGPointMake(_x, _y));
}

@end
