//
//  V3DPolyLine.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "V3DPolyline.h"
#import "../../IGolfViewer3DPrivateImports.h"

@interface V3DPolyline() {
    
    NSArray<CLLocation*>*   _locations;
    UIColor*                _color;
    double                  _width;
    BOOL                    _interpolate;
    V3DPolylineInternal*    _internal;
}

@end

@implementation V3DPolyline

-(id)initWithLocations:(NSArray<CLLocation*>*)locations color:(UIColor *)color width:(double)width interpolate:(BOOL)interpolate {
    
    self = [super init];
    
    if (self != nil) {
        
        NSAssert(locations.count > 1, @"iGolf Viewer 3D: V3DPolyline should contain at least 2 locations.");
        
        self->_locations = locations;
        self->_width = width;
        self->_color = color;
        self->_interpolate = interpolate;
        self->_internal = [[V3DPolylineInternal alloc] initWithLine:self];
    }
    
    return self;
}

-(NSArray<CLLocation *> *)locations {
    return _locations;
}

-(double)width {
    return _width;
}

-(UIColor *)color {
    return _color;
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
