//
//  V3DPolygon.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DPolygon.h"
#import <UIKit/UIKit.h>
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DPolygon() {
    
    NSArray<CLLocation*>* _locations;
    UIColor* _fillColor;
    UIColor* _borderColor;
    double _borderWidth;
    BOOL _interpolate;
    V3DPolygonInternal* _internal;
}

@end

@implementation V3DPolygon

- (id)initWithLocations:(NSArray<CLLocation*>*)locations fillColor:(UIColor*)fillColor borderColor:(UIColor*)borderColor borderWidth:(double)borderWidth interpolate:(BOOL)interpolate {
    
    self = [super init];
    
    if (self != nil) {
        
        NSAssert(locations.count > 2, @"iGolf Viewer 3D: V3DPolygon should contain at least 3 locations.");
        
        self->_locations   = locations;
        self->_borderWidth = borderWidth;
        self->_borderColor = borderColor;
        self->_fillColor   = fillColor;
        self->_interpolate = interpolate;
        self->_internal    = [[V3DPolygonInternal alloc] initWithPolygon:self];
    }
    
    return self;
}

-(NSArray<CLLocation*>*)locations {
    return _locations;
}

-(UIColor*)fillColor {
    return _fillColor;
}

-(UIColor*)borderColor {
    return _borderColor;
}

-(double)borderWidth {
    return _borderWidth;
}

-(BOOL)interpolate {
    return _interpolate;
}

-(CGRect)boundingBox {
    return _internal.boundingBox;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect {
    [_internal renderWithEffect:effect];
}

@end
