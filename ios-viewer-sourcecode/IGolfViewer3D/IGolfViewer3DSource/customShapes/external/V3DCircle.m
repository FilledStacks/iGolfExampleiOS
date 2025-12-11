//
//  V3DPoint.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DCircle.h"
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DCircle() {
    
    CLLocation* _location;
    UIColor*    _fillColor;
    UIColor*    _borderColor;
    double      _borderWidth;
    double      _radius;
    
    V3DCircleInternal* _internal;
}

@end

@implementation V3DCircle

-(id)initWithLocation:(CLLocation *)location radius:(double)radius fillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(double)borderWidth {
    
    self = [super init];
    
    if (self != nil) {
        self->_location    = location;
        self->_fillColor   = fillColor;
        self->_borderColor = borderColor;
        self->_borderWidth = borderWidth;
        self->_radius      = radius;
        self->_internal    = [[V3DCircleInternal alloc] initWithPoint:self];
    }
    
    return self;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect {
    [_internal renderWithEffect:effect];
}

-(CLLocation *)location {
    return _location;
}

-(UIColor *)fillColor {
    return _fillColor;
}

- (UIColor *)borderColor {
    return _borderColor;
}

-(double)borderWidth {
    return _borderWidth;
}

- (double)radius {
    return _radius;
}

-(CGRect)boundingBox {
    return _internal.boundingBox;
}

@end
