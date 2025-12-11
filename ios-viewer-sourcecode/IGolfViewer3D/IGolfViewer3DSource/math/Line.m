//
//  Line.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Line.h"

@interface Line() {
    Vector* v1;
    Vector* v2;
}
@end

@implementation Line

- (id)initWithP1:(Vector *)p1 andP2:(Vector *)p2 {
    
    self = [super init];
    
    if (self != nil) {
        self->v1 = p1;
        self->v2 = p2;
    }
    
    return self;
}

- (Vector *)p1 {
    return v1;
}

- (Vector *)p2 {
    return v2;
}

@end
