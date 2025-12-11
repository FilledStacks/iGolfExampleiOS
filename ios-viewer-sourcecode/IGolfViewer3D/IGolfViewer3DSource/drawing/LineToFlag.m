//
//  Callouts.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <OpenGLES/ES3/gl.h>
#import "LineToFlag.h"
#import <Foundation/Foundation.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface LineToFlag () {
    ElevationMap* _grid;
    float _twoLineBuffer[9];
    double _markerScale;
    
    GLuint _twoLineVertexBuffer;
    GLuint _twoLineColorBuffer;
    
    GLuint _tempVertexBuffer;
    GLuint _tempColorBuffer;
    
    GLuint _tempPolygonVertexBuffer;
    GLuint _tempPolygonUVBuffer;
    
    UIColor* _lineColor;
    
    double _initialDiffX;
    double _initialDiffY;
    
    TexturedPolygon* _locationPolygon;
    BOOL _hasFocus;
    
    
    NSDate* _lastDragDate;
}

@end

@implementation LineToFlag

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    
    if (currentLocation == nil) {
        return;
    }
    
    double currentLon = [Layer transformToLonWithDouble:_twoLineBuffer[0]];
    double currentLat = [Layer transformToLatWithDouble:_twoLineBuffer[1]];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLon];
    double distance = [location distanceFromLocation:currentLocation];
    
    if (distance > 999 || distance < 0) {
        return;
    }
    
    double x = [Layer transformLonFromDouble:currentLocation.coordinate.longitude];
    double y = [Layer transformLatFromDouble:currentLocation.coordinate.latitude];
    double z = [_grid getZPositionForLocation:currentLocation];
    _twoLineBuffer[0] = x;
    _twoLineBuffer[1] = y;
    _twoLineBuffer[2] = z;
    _currentLocation = currentLocation;
    
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
    
    if (!self.hasFocus) {
        [self resetPosition];
    }
    
}

- (void)setCentralPath:(PointListLayer *)centralPath {
    _centralPath = centralPath;
    _markerScale = 0.5;
    
    if (_centralPath == nil) {
        return;
    }
    
    Vector* start = _centralPath.pointList.firstObject.pointList.firstObject;
    
    double latitude = [Layer transformToLatWithDouble:start.y];
    double longitude = [Layer transformToLonWithDouble:start.x];
    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocation* startLocation = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:start.y] longitude:[Layer transformToLonWithDouble:start.x]];
    double startZ = [_grid getZPositionForLocation:startLocation];

    
    _twoLineBuffer[0] = start.x;
    _twoLineBuffer[1] = start.y;
    _twoLineBuffer[2] = startZ;
    
    Vector* end = _centralPath.pointList.firstObject.pointList.lastObject;
    Vector* middle = [[start addedWithVector:end] multipliedWithFactor:0.5];
    CLLocation* middleLocation = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:middle.y] longitude:[Layer transformToLonWithDouble:middle.x]];
    CLLocation* endLocation = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:end.y] longitude:[Layer transformToLonWithDouble:end.x]];
    
    
    _twoLineBuffer[3] = middle.x;
    _twoLineBuffer[4] = middle.y;
    _twoLineBuffer[5] = [_grid getZPositionForLocation:middleLocation];
    
    _twoLineBuffer[6] = end.x;
    _twoLineBuffer[7] = end.y;
    _twoLineBuffer[8] = [_grid getZPositionForLocation:endLocation];
    
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
}

- (BOOL)hasFocus {
    return _hasFocus;
}

- (CLLocation*)startPointLocation {
    double currentLon = [Layer transformToLonWithDouble:_twoLineBuffer[0]];
    double currentLat = [Layer transformToLatWithDouble:_twoLineBuffer[1]];
    return [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLon];
}

- (Vector*)startLocation {
    Vector* retval = nil;
    
    retval = [[Vector alloc] initWithX:_twoLineBuffer[0] andY:_twoLineBuffer[1]];
    
    return retval;
}

-(CLLocation*)endPointLocation {
    
    double currentLon = [Layer transformToLonWithDouble:_twoLineBuffer[6]];
    double currentLat = [Layer transformToLatWithDouble:_twoLineBuffer[7]];
    return [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLon];
}

- (Vector*)endLocation {
    Vector* retval = nil;
    
    retval = [[Vector alloc] initWithX:_twoLineBuffer[6] andY:_twoLineBuffer[7]];
    
    return retval;
}

- (id)initWithLocationTextureFilePath:(NSString*)locationTexture andElevationGrid:(ElevationMap *)grid andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer {
    self = [super init];
    self->_grid = grid;
    if (self) {
        
        self->_locationPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:locationTexture] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        
        self->_lineColor = [UIColor redColor];
        
    
        NSMutableArray *twoLineColorArray = [NSMutableArray new];
        
        
        const CGFloat *components = CGColorGetComponents(_lineColor.CGColor);
        
        
        
        for (int i = 0; i < 3; i++) {
            [twoLineColorArray addObject:@(components[0])];
            [twoLineColorArray addObject:@(components[1])];
            [twoLineColorArray addObject:@(components[2])];
            [twoLineColorArray addObject:@(components[3])];
        }
        
        _twoLineVertexBuffer = [GLHelper getEmptyBuffer];
        _twoLineColorBuffer = [GLHelper getBuffer:twoLineColorArray];
        _tempVertexBuffer = [GLHelper getEmptyBuffer];
        _tempColorBuffer = [GLHelper getEmptyBuffer];
        _tempPolygonVertexBuffer = vertexBuffer;
        _tempPolygonUVBuffer = uvBuffer;
    }
    
    return self;
}

- (BOOL)onTouchDown:(CGPoint)point andCamera:(Camera *)camera {
    
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _twoLineBuffer[3], camera.y + _twoLineBuffer[4], _twoLineBuffer[5]);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:90], 1, 0, 0);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 1, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _markerScale, _markerScale , _markerScale);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    
    Ray* ray = [[Ray alloc] initForLineFlagWith:point.x andTouchY:point.y andCamera:camera andMatrix:(GLKMatrix4) modelViewMatrix];
    
    GLKVector4 surface[] = {
        GLKVector4Make(-1, 1, 0, 0), // top left
        GLKVector4Make(-1, -1, 0, 0), // bottom left
        GLKVector4Make(1, -1, 0, 0), // bottom right
        GLKVector4Make(-1, 1, 0, 0), // top left
        GLKVector4Make(1, -1, 0, 0), // bottom right
        GLKVector4Make(1, 1, 0, 0) // top right
    };
    
    GLKVector4 resultVector;
    GLKVector4 inputVector;
    
    for (int i = 0 ; i < 6 ; i++) {
        inputVector = surface[i];
        inputVector.w = 1;
        
        resultVector = GLKMatrix4MultiplyVector4(modelViewMatrix, inputVector);
        surface[i].x = resultVector.x / resultVector.w;
        surface[i].y = resultVector.y / resultVector.w;
        surface[i].z = resultVector.z / resultVector.w;
    }
    
    Triangle* surfaceTriangle[] = {
        [[Triangle alloc] initWithV0:&surface[0].x andV1:&surface[1].x andV2:&surface[2].x],
        [[Triangle alloc] initWithV0:&surface[3].x andV1:&surface[4].x andV2:&surface[5].x]
    };
    
    float intersectionPoint[] = {0, 0, 0, 1};
    
    for (int i = 0 ; i < 2 ; i++) {
        int result = [Triangle intersectWithRay:ray andTriangle:surfaceTriangle[i] andI:intersectionPoint];
        if (result == 1) {
            _hasFocus = true;
            
            _lastDragDate = [NSDate new];
            
            Vector* unprojected = [camera unprojectWithTouchPoint:point];
            _initialDiffX = unprojected.x - _twoLineBuffer[3];
            _initialDiffY = unprojected.y - _twoLineBuffer[4];
            
            return YES;
        }
    }
    return NO;
}

- (BOOL)onTouchMove:(Vector*)coordinate {
    if (self.hasFocus == NO) {
        return NO;
    }
    
    CLLocation* startLocation = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:coordinate.y] longitude:[Layer transformToLonWithDouble:coordinate.x]];
    double z = [_grid getZPositionForLocation:startLocation];
    
    _twoLineBuffer[3] = coordinate.x - _initialDiffX;
    _twoLineBuffer[4] = coordinate.y - _initialDiffY;
    _twoLineBuffer[5] = z;
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
    
    _lastDragDate = [NSDate new];
    
    return YES;
}

- (BOOL)onTouchUp:(Vector*)coordinate {
    _initialDiffX  = 0;
    _initialDiffY  = 0;
    if (self.hasFocus == NO) {
        return NO;
    }
    
    _hasFocus = NO;
   
    // _twoLineBuffer[3] = coordinate.x;
    //_twoLineBuffer[4] = coordinate.y;
    //[GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
    
    return YES;
}

- (void)destroy {

    
    [_locationPolygon destroy];
    
    [GLHelper deleteBuffer:_tempColorBuffer];
    [GLHelper deleteBuffer:_tempVertexBuffer];
    [GLHelper deleteBuffer:_twoLineColorBuffer];
    [GLHelper deleteBuffer:_twoLineVertexBuffer];
}

- (void)resetPosition {
    
    if (![self canResetPinPosition]) {
        return;
    }
    
    Vector* start = [[Vector alloc] initWithX:_twoLineBuffer[0] andY:_twoLineBuffer[1]];
    Vector* end = [[Vector alloc] initWithX:_twoLineBuffer[6] andY:_twoLineBuffer[7]];
    Vector* middle = [[start addedWithVector:end] multipliedWithFactor:0.5];
    
    
    double currentLon = [Layer transformToLonWithDouble:middle.x];
    double currentLat = [Layer transformToLatWithDouble:middle.y];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLon];
    double z = [_grid getZPositionForLocation:location];
    
    _twoLineBuffer[3] = middle.x;
    _twoLineBuffer[4] = middle.y;
    _twoLineBuffer[5] = z;
    
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
}

- (void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    if (camera.navigationMode == NavigationMode2DView && camera.navigationMode == NavigationMode2DGreenView) {
        return;
    }
    
    if (_centralPath == nil) {
        return;
    }
    glLineWidth(6);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x, camera.y, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    effect.texture2d0.enabled = false;
    [effect prepareToDraw];
    
    [GLHelper drawVertexBuffer:_twoLineVertexBuffer andColorBuffer:_twoLineColorBuffer andMode:GL_LINE_STRIP andCount:3];
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Identity;
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0, camera.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, camera.x + _twoLineBuffer[3], camera.y + _twoLineBuffer[4], _twoLineBuffer[5]);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:90], 1, 0, 0);//
    
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 1, 0);
    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, _markerScale, _markerScale , _markerScale);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 1, 0);
    
    effect.transform.modelviewMatrix = modelViewMatrix2;
    [effect prepareToDraw];
    
    [_locationPolygon renderWithEffect:effect];
    
}


- (BOOL)canResetPinPosition {
    
    BOOL retval = true;
    
    if (_lastDragDate) {
        retval = fabs([_lastDragDate timeIntervalSinceNow]) >= 15.0;
    }
    
    return retval;
}



@end
