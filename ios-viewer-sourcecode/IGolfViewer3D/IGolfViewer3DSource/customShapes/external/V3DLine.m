//
//  V3DLine.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DLine.h"
#import "../internal/V3DLineInternal.h"

@interface V3DLine() {
    
    V3DLineInternal*    _internal;
    
    CLLocation*         _startLocation;
    CLLocation*         _endLocation;
    UIColor*            _color;
    double              _width;
    
}

@end

@implementation V3DLine

-(id)initWithStartLocation:(CLLocation *)startLocation endLocation:(CLLocation *)endLocation color:(UIColor *)color width:(double)width {
    
    self = [super init];
    
    if (self != nil) {
        self->_startLocation = startLocation;
        self->_endLocation = endLocation;
        self->_width = width;
        self->_color = color;
        self->_internal = [[V3DLineInternal alloc] initWithLine:self];
    }
    
    return self;
}

-(CLLocation *)startLocation {
    return _startLocation;
}

-(CLLocation *)endLocation {
    return _endLocation;
}

-(double)width {
    return _width;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect {
    [_internal renderWithEffect:effect];
}

-(CGRect)boundingBox {
    return _internal.boundingBox;
}


@end
