//
//  Cart.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Cart.h"
#import <OpenGLES/ES3/gl.h>
#import <CoreLocation/CoreLocation.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface Cart () {
    TexturedPolygon* _polygon;
    Vector* _position;
    Vector* _unprojPosition;
    CLLocation* _location;
    ElevationMap* _grid;
    double _scaleFactor;
}

@end

@implementation Cart


- (CLLocation*)location {
    return _location;
}

- (void)setLocation:(CLLocation*)location {
    _location = location;
    _position = nil;
    _scaleFactor = 0.2;
    if (location != nil) {
        _position = [[Vector alloc] initWithX:[Layer transformLonFromDouble:location.coordinate.longitude] andY:[Layer transformLatFromDouble:location.coordinate.latitude]];
        _position.z = [_grid getZForPointX:-_position.x andY:-_position.y];
        _unprojPosition = [[Vector alloc] initWithX:-_position.x andY:-_position.y andZ:-_position.z];
    }
}

- (id)initWithTextureFilename:(NSString*)textureFilename andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer andElevationMap:(ElevationMap*)grid {
    self = [super init];
    
    self->_grid = grid;
    self->_polygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:textureFilename] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    
    return self;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    if (_position == nil) {
        return;
    }
    
    if (camera.navigationMode == NavigationModeFreeCam) {
        
        double distance = [VectorMath distanceWithVector1:_unprojPosition andVector2:camera.cameraPoint];

        _scaleFactor = 0.2 * distance / 3.0;
        
        _scaleFactor = fmin(_scaleFactor, 0.2);
        _scaleFactor = fmax(_scaleFactor, 0.1);
        
    } else if (camera.navigationMode == NavigationMode3DGreenView){
        _scaleFactor = 0.15;
    } else {
        _scaleFactor = 0.2;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);//
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:90], 1, 0, 0);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 1, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _scaleFactor, _scaleFactor, _scaleFactor);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_polygon renderWithEffect:effect];
}

@end
