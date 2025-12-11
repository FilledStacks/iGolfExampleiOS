//
//  Vertex.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Vertex.h"
#import "../math/Vector.h"

@interface Vertex() {
    Vector* _vector;
    Vector* _normalVector;
}

@end

@implementation Vertex

-(id)initWithX:(double)x Y:(double)y Z:(double)z {
    self = [super init];
    
    if (self) {
        self->_vector = [[Vector alloc] initWithX:x andY:y andZ:z];
    }
    
    return self;
}

- (Vector *)vector {
    return _vector;
}

-(Vector *)normalVector {
    return _normalVector;
}

-(void)setNormalVector:(Vector *)normalVector {
    _normalVector = normalVector;
}

@end
