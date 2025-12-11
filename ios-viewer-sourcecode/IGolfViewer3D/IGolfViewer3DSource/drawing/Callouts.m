//
//  Callouts.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <OpenGLES/ES3/gl.h>
#import "Callouts.h"
#import "../IGolfViewer3DPrivateImports.h"

#define CALLOUT_SCALE 0.045
#define LOCATION_SCALE 0.01
#define CURSOR_SCALE 0.025
#define DISTANCE_LABEL_SCALE 0.03


@interface Callouts () {
    float _twoLineBuffer[9];
    float _oneLineBuffer[6];
    
    GLuint _oneLineVertexBuffer;
    GLuint _oneLineColorBuffer;
    
    GLuint _twoLineVertexBuffer;
    GLuint _twoLineColorBuffer;
    
    GLuint _tempVertexBuffer;
    GLuint _tempColorBuffer;
    
    GLuint _tempPolygonVertexBuffer;
    GLuint _tempPolygonUVBuffer;
    
    int num_segments;
    
    TexturedPolygon* _endlocationPolygon;
    TexturedPolygon* _locationPolygon;
    TexturedPolygon* _cursorPolygon;
    
    BOOL _hasFocus;
    
    UIColor* _color100;
    UIColor* _color150;
    UIColor* _color200;
    UIColor* _color250;
    UIColor* _color300;
    
    TexturedPolygon* _distance100;
    TexturedPolygon* _distance150;
    TexturedPolygon* _distance200;
    TexturedPolygon* _distance250;
    TexturedPolygon* _distance300;
    
    UIImage* _calloutBg;
    
    NSDate* _lastDragDate;
    
    CLLocation* _dogLegMarkerLocation;
}

@end

@implementation Callouts

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
    _twoLineBuffer[0] = x;
    _twoLineBuffer[1] = y;
    _oneLineBuffer[0] = x;
    _oneLineBuffer[1] = y;
    _currentLocation = currentLocation;
    
    [GLHelper updateBuffer:_oneLineVertexBuffer andData:_oneLineBuffer andCount:6];
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
    
    if (!self.hasFocus) {
        [self resetPosition];
    }
    
}

- (void)setCentralPath:(PointListLayer *)centralPath andDogLegLocation:(CLLocation *)dogLegMarkerLocation {
    _centralPath = centralPath;
    _dogLegMarkerLocation = dogLegMarkerLocation;
    if (_centralPath == nil) {
        return;
    }
    
    Vector* start = _centralPath.pointList.firstObject.pointList.firstObject;
    
    double latitude = [Layer transformToLatWithDouble:start.y];
    double longitude = [Layer transformToLonWithDouble:start.x];
    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    _twoLineBuffer[0] = start.x;
    _twoLineBuffer[1] = start.y;
    _twoLineBuffer[2] = 0;
    _oneLineBuffer[0] = start.x;
    _oneLineBuffer[1] = start.y;
    _oneLineBuffer[2] = 0;
    
    Vector* end = _centralPath.pointList.firstObject.pointList.lastObject;
    Vector* middle = [[start addedWithVector:end] multipliedWithFactor:0.5];
    
    if (_dogLegMarkerLocation == nil) {
        _twoLineBuffer[3] = middle.x;
        _twoLineBuffer[4] = middle.y;
    } else {
        if([self shouldPlaceCursorAtDogLegWithLocX:start.x locY:start.y dogX:[Layer transformLonFromDouble:_dogLegMarkerLocation.coordinate.longitude] dogY:[Layer transformLatFromDouble:_dogLegMarkerLocation.coordinate.latitude] holeX:end.x holeY:end.y]) {
            double dogLegLatitude = [Layer transformLatFromDouble:_dogLegMarkerLocation.coordinate.latitude];
            double dogLegLongitude = [Layer transformLonFromDouble:_dogLegMarkerLocation.coordinate.longitude];
            _twoLineBuffer[3] = dogLegLongitude;
            _twoLineBuffer[4] = dogLegLatitude;
        } else {
            _twoLineBuffer[3] = middle.x;
            _twoLineBuffer[4] = middle.y;
        }
    }
    _twoLineBuffer[5] = 0;
    
    _twoLineBuffer[6] = end.x;
    _twoLineBuffer[7] = end.y;
    _twoLineBuffer[8] = 0;
    _oneLineBuffer[3] = end.x;
    _oneLineBuffer[4] = end.y;
    _oneLineBuffer[5] = 0;
    
    [GLHelper updateBuffer:_oneLineVertexBuffer andData:_oneLineBuffer andCount:6];
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
}

- (BOOL)shouldPlaceCursorAtDogLegWithLocX:(double)locX locY:(double)locY dogX:(double)dogX dogY:(double)dogY holeX:(double)holeX holeY:(double)holeY {
    double distanceFromDogLeg = fabs([self distanceBetweenPt1X:dogX andPt1Y:dogY andPt2X:holeX andPt2Y:holeY]);
    double distanceFromLocation = fabs([self distanceBetweenPt1X:locX andPt1Y:locY andPt2X:holeX andPt2Y:holeY]);
    return distanceFromDogLeg < distanceFromLocation;
}

- (double) distanceBetweenPt1X:(double)pt1X andPt1Y:(double) pt1Y andPt2X:(double) pt2X andPt2Y:(double)pt2Y {
    return sqrt(pow(pt1X - pt2X, 2) + pow(pt1Y - pt2Y, 2));
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
    
    if (self.calloutsDrawMode == CalloutsDrawModeTwoSegments) {
        retval = [[Vector alloc] initWithX:_twoLineBuffer[0] andY:_twoLineBuffer[1]];
    } else {
        retval = [[Vector alloc] initWithX:_oneLineBuffer[0] andY:_oneLineBuffer[1]];
    }
    
    return retval;
}

-(CLLocation*)endPointLocation {
    
    if (self.calloutsDrawMode == CalloutsDrawModeTwoSegments) {
        double currentLon = [Layer transformToLonWithDouble:_twoLineBuffer[6]];
        double currentLat = [Layer transformToLatWithDouble:_twoLineBuffer[7]];
        return [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLon];
    } else {
        double currentLon = [Layer transformToLonWithDouble:_twoLineBuffer[3]];
        double currentLat = [Layer transformToLatWithDouble:_twoLineBuffer[4]];
        return [[CLLocation alloc] initWithLatitude:currentLat longitude:currentLon];
    }
}

- (Vector*)endLocation {
    Vector* retval = nil;
    
    if (self.calloutsDrawMode == CalloutsDrawModeTwoSegments) {
        retval = [[Vector alloc] initWithX:_twoLineBuffer[6] andY:_twoLineBuffer[7]];
    } else {
        retval = [[Vector alloc] initWithX:_oneLineBuffer[3] andY:_oneLineBuffer[4]];
    }
    
    return retval;
}

- (id)initWithLocationTextureFilePath:(NSString*)locationTexture andEndLocationTexture:(NSString*) endLocationTexture andCursorTextureFilePath:(NSString*)cursorTexture andVertexbuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer{
    self = [super init];
    
    if (self) {
        
        self->_locationPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:locationTexture] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        if(endLocationTexture != nil) {
            self->_endlocationPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:endLocationTexture] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        }
        self->_cursorPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:cursorTexture] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        
        self->_color100 = [UIColor redColor];
        self->_color150 = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        self->_color200 = [UIColor colorWithRed:0.0f/255 green:210.0f/255 blue:255.0f/255 alpha:1];
        self->_color250 = [UIColor yellowColor];
        self->_color300 = [UIColor colorWithRed:89.0f/255 green:89.0f/255 blue:89.0f/255 alpha:1];
        
        _distance100 = [[TexturedPolygon alloc] initWithTexture:[self createTextureWithText:@"100" andTextColor:self->_color100] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        _distance150 = [[TexturedPolygon alloc] initWithTexture:[self createTextureWithText:@"150" andTextColor:self->_color150] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        _distance200 = [[TexturedPolygon alloc] initWithTexture:[self createTextureWithText:@"200" andTextColor:self->_color200] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        _distance250 = [[TexturedPolygon alloc] initWithTexture:[self createTextureWithText:@"250" andTextColor:self->_color250] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        _distance300 = [[TexturedPolygon alloc] initWithTexture:[self createTextureWithText:@"300" andTextColor:self->_color300] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        
        _calloutBg = [UIImage imageNamed:@"v2d_callout.png"];
        num_segments = 20;
        
        NSMutableArray *oneLineColorArray = [NSMutableArray new];
        NSMutableArray *twoLineColorArray = [NSMutableArray new];
        
        GLfloat r = (0);
        GLfloat g = (0);
        GLfloat b = (0);
        GLfloat a = 1;
        
        for (int i = 0; i < 2; i++) {
            [oneLineColorArray addObject:@(r)];
            [oneLineColorArray addObject:@(g)];
            [oneLineColorArray addObject:@(b)];
            [oneLineColorArray addObject:@(a)];
        }
        
        for (int i = 0; i < 3; i++) {
            [twoLineColorArray addObject:@(r)];
            [twoLineColorArray addObject:@(g)];
            [twoLineColorArray addObject:@(b)];
            [twoLineColorArray addObject:@(a)];
        }
        
        _oneLineVertexBuffer = [GLHelper getEmptyBuffer];
        _twoLineVertexBuffer = [GLHelper getEmptyBuffer];
        _oneLineColorBuffer = [GLHelper getBuffer:oneLineColorArray];
        _twoLineColorBuffer = [GLHelper getBuffer:twoLineColorArray];
        _tempVertexBuffer = [GLHelper getEmptyBuffer];
        _tempColorBuffer = [GLHelper getEmptyBuffer];
        _tempPolygonVertexBuffer = vertexBuffer;
        _tempPolygonUVBuffer = uvBuffer;
    }
    
    return self;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    if (camera.navigationMode != NavigationMode2DView && camera.navigationMode != NavigationMode2DGreenView) {
        return;
    }
    
    if (_centralPath == nil) {
        return;
    }
    
    if (self.calloutsDrawMode == CalloutsDrawModeOneSegment) {
        [self renderOneSegmentWithEffect:effect andCamera:camera];
    } else {
        [self renderTwoSegmentWithEffect:effect andCamera:camera];
    }
    
    
}

- (BOOL)onTouchDown:(Vector*)coordinate andCamera:(Camera*)camera {
    if (self.calloutsDrawMode != CalloutsDrawModeTwoSegments) {
        return NO;
    }
    
    double distance = [coordinate distanceWithVector:[[Vector alloc] initWithX:_twoLineBuffer[3] andY:_twoLineBuffer[4]]];
    if (distance < fabs(camera.z) * 0.03) {
        _hasFocus = true;
        
        _lastDragDate = [NSDate new];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)onTouchMove:(Vector*)coordinate {
    if (self.calloutsDrawMode != CalloutsDrawModeTwoSegments || self.hasFocus == NO) {
        return NO;
    }
    
    _twoLineBuffer[3] = coordinate.x;
    _twoLineBuffer[4] = coordinate.y;
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
    
    _lastDragDate = [NSDate new];
    
    return YES;
}

- (BOOL)onTouchUp:(Vector*)coordinate {
    if (self.calloutsDrawMode != CalloutsDrawModeTwoSegments || self.hasFocus == NO) {
        return NO;
    }
    
    _hasFocus = NO;
    
    // _twoLineBuffer[3] = coordinate.x;
    //_twoLineBuffer[4] = coordinate.y;
    //[GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
    
    return YES;
}

- (void)destroy {
    
    [_distance100 destroy];
    [_distance150 destroy];
    [_distance200 destroy];
    [_distance250 destroy];
    [_distance300 destroy];
    if(_endlocationPolygon != nil){
        [_endlocationPolygon destroy];
    }
    [_locationPolygon destroy];
    [_cursorPolygon destroy];
    
    [GLHelper deleteBuffer:_tempColorBuffer];
    [GLHelper deleteBuffer:_tempVertexBuffer];
    [GLHelper deleteBuffer:_oneLineColorBuffer];
    [GLHelper deleteBuffer:_twoLineColorBuffer];
    [GLHelper deleteBuffer:_oneLineVertexBuffer];
    [GLHelper deleteBuffer:_twoLineVertexBuffer];
}

- (void)resetPosition {
    
    if (![self canResetPinPosition]) {
        return;
    }
    
    Vector* start = [[Vector alloc] initWithX:_twoLineBuffer[0] andY:_twoLineBuffer[1]];
    Vector* end = [[Vector alloc] initWithX:_twoLineBuffer[6] andY:_twoLineBuffer[7]];
    Vector* middle = [[start addedWithVector:end] multipliedWithFactor:0.5];
    
    if (_dogLegMarkerLocation == nil) {
        _twoLineBuffer[3] = middle.x;
        _twoLineBuffer[4] = middle.y;
    } else {
        if([self shouldPlaceCursorAtDogLegWithLocX:start.x locY:start.y dogX:[Layer transformLonFromDouble:_dogLegMarkerLocation.coordinate.longitude] dogY:[Layer transformLatFromDouble:_dogLegMarkerLocation.coordinate.latitude] holeX:end.x holeY:end.y]) {
            double dogLegLatitude = [Layer transformLatFromDouble:_dogLegMarkerLocation.coordinate.latitude];
            double dogLegLongitude = [Layer transformLonFromDouble:_dogLegMarkerLocation.coordinate.longitude];
            _twoLineBuffer[3] = dogLegLongitude;
            _twoLineBuffer[4] = dogLegLatitude;
        } else {
            _twoLineBuffer[3] = middle.x;
            _twoLineBuffer[4] = middle.y;
        }
    }
    
    [GLHelper updateBuffer:_twoLineVertexBuffer andData:_twoLineBuffer andCount:9];
}

- (void)renderTwoSegmentWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
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
    
    CGFloat _locationScale = fabs(camera.z * LOCATION_SCALE);
    
    GLKMatrix4 modelViewMatrix1 = GLKMatrix4Identity;
    modelViewMatrix1 = GLKMatrix4Translate(modelViewMatrix1, 0, 0, camera.z);
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix1 = GLKMatrix4Translate(modelViewMatrix1, camera.x + _twoLineBuffer[6], camera.y + _twoLineBuffer[7], 0);
    modelViewMatrix1 = GLKMatrix4Scale(modelViewMatrix1, _locationScale, _locationScale, _locationScale);//
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    
    effect.transform.modelviewMatrix = modelViewMatrix1;
    [effect prepareToDraw];
    if(_endlocationPolygon != nil){
        [_endlocationPolygon renderWithEffect:effect];
    }
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Identity;
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0, camera.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, camera.x + _twoLineBuffer[0], camera.y + _twoLineBuffer[1], 0);
    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, _locationScale, _locationScale, _locationScale);//
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    
    effect.transform.modelviewMatrix = modelViewMatrix2;
    [effect prepareToDraw];
    
    [_locationPolygon renderWithEffect:effect];
    
    [self renderOverlayWithEffect:effect andCamera:camera];
    
    CGFloat _cursorScale = fabs(camera.z * CURSOR_SCALE);
    
    GLKMatrix4 modelViewMatrix3 = GLKMatrix4Identity;
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, 0, 0, camera.z);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);//
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);//
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, camera.x + _twoLineBuffer[3], camera.y + _twoLineBuffer[4], 0);//
    modelViewMatrix3 = GLKMatrix4Scale(modelViewMatrix3, _cursorScale, _cursorScale, _cursorScale);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    effect.transform.modelviewMatrix = modelViewMatrix3;
    [effect prepareToDraw];
    
    [_cursorPolygon renderWithEffect:effect];
    
    double dist1 = [DistanceCalculator distanceWithWorldX1:_twoLineBuffer[0] andWorldY1:_twoLineBuffer[1] andWorldX2:_twoLineBuffer[3] andWorldY2:_twoLineBuffer[4] andMeasurementSystem:self.measurementSystem];
    double dist2 = [DistanceCalculator distanceWithWorldX1:_twoLineBuffer[3] andWorldY1:_twoLineBuffer[4] andWorldX2:_twoLineBuffer[6] andWorldY2:_twoLineBuffer[7] andMeasurementSystem:self.measurementSystem];
    
    GLKTextureInfo* texture1 = [self createCalloutTextureWithText:[NSString stringWithFormat:@"%d", (int)round(dist1)]];
    GLKTextureInfo* texture2 = [self createCalloutTextureWithText:[NSString stringWithFormat:@"%d", (int)round(dist2)]];
    
    TexturedPolygon* polygon1 = [[TexturedPolygon alloc] initWithTexture:texture1 andVertexBuffer:_tempPolygonVertexBuffer andUVBuffer:_tempPolygonUVBuffer];
    TexturedPolygon* polygon2 = [[TexturedPolygon alloc] initWithTexture:texture2 andVertexBuffer:_tempPolygonVertexBuffer andUVBuffer:_tempPolygonUVBuffer];
    
    Vector* pt1 = [[Vector alloc] initWithX:_twoLineBuffer[0] andY:_twoLineBuffer[1]];
    Vector* pt2 = [[Vector alloc] initWithX:_twoLineBuffer[3] andY:_twoLineBuffer[4]];
    Vector* pt3 = [[Vector alloc] initWithX:_twoLineBuffer[6] andY:_twoLineBuffer[7]];
    
    Vector* pos1 = [self calculateCalloutDrawPositionWithVector1:pt1 andVector2:pt2 andCamera:camera];
    Vector* pos2 = [self calculateCalloutDrawPositionWithVector1:pt2 andVector2:pt3 andCamera:camera];
    
    CGFloat calloutScale = fabs(camera.z * CALLOUT_SCALE);
    
    if (pos1) {
        GLKMatrix4 modelViewMatrix4 = GLKMatrix4Identity;//
        modelViewMatrix4 = GLKMatrix4Translate(modelViewMatrix4, 0, 0, camera.z);//
        modelViewMatrix4 = GLKMatrix4Rotate(modelViewMatrix4, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);//
        modelViewMatrix4 = GLKMatrix4Rotate(modelViewMatrix4, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);//
        if (dist1 < fabs(camera.z) + 15) {
            
            
            /*
             if (_hasFocus) {
             shift *= 2;
             }*/
            CGFloat x = camera.x + _twoLineBuffer[3];
            CGFloat y = camera.y + _twoLineBuffer[4];
            CGFloat shift = fabs(camera.z * 0.07);
            
            x -= shift * sin([VectorMath deg2radWithDeg:camera.rotationAngle]);
            y -= shift * cos([VectorMath deg2radWithDeg:camera.rotationAngle]);
            
            modelViewMatrix4 = GLKMatrix4Translate(modelViewMatrix4, x, y, 0);
            
        } else {
            modelViewMatrix4 = GLKMatrix4Translate(modelViewMatrix4, camera.x + pos1.x, camera.y + pos1.y, 0);
        }
        
        modelViewMatrix4 = GLKMatrix4Scale(modelViewMatrix4, calloutScale, calloutScale, calloutScale);
        modelViewMatrix4 = GLKMatrix4Rotate(modelViewMatrix4, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
        
        effect.transform.modelviewMatrix = modelViewMatrix4;
        [effect prepareToDraw];
        
        [polygon1 renderWithEffect:effect];
        
        [polygon1 destroy];
    }
    
    
    if (pos2) {
        GLKMatrix4 modelViewMatrix5 = GLKMatrix4Identity;//
        modelViewMatrix5 = GLKMatrix4Translate(modelViewMatrix5, 0, 0, camera.z);
        modelViewMatrix5 = GLKMatrix4Rotate(modelViewMatrix5, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
        modelViewMatrix5 = GLKMatrix4Rotate(modelViewMatrix5, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
        
        if (dist2 < fabs(camera.z) + 15) {
            
            CGFloat shift = fabs(camera.z * 0.07);
            /*
             if (_hasFocus) {
             shift *= 2;
             }*/
            
            CGFloat x = camera.x + _twoLineBuffer[3];
            CGFloat y = camera.y + _twoLineBuffer[4];
            
            x += shift * sin([VectorMath deg2radWithDeg:camera.rotationAngle]);
            y += shift * cos([VectorMath deg2radWithDeg:camera.rotationAngle]);
            
            modelViewMatrix5 = GLKMatrix4Translate(modelViewMatrix5, x, y, 0);
            
        } else {
            modelViewMatrix5 = GLKMatrix4Translate(modelViewMatrix5, camera.x + pos2.x, camera.y + pos2.y, 0);
        }
        
        modelViewMatrix5 = GLKMatrix4Scale(modelViewMatrix5, calloutScale, calloutScale, calloutScale);
        modelViewMatrix5 = GLKMatrix4Rotate(modelViewMatrix5, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
        
        effect.transform.modelviewMatrix = modelViewMatrix5;
        [effect prepareToDraw];
        
        [polygon2 renderWithEffect:effect];
        
        [polygon2 destroy];
    }
    
}

- (void)renderOneSegmentWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    glLineWidth(2);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;//
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);//
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);//
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x, camera.y, 0);//
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    
    
    [GLHelper drawVertexBuffer:_oneLineVertexBuffer andColorBuffer:_oneLineColorBuffer andMode:GL_LINES andCount:2];
    
    CGFloat locationScale = fabs(camera.z * LOCATION_SCALE);
   
    
    GLKMatrix4 modelViewMatrix1 = GLKMatrix4Identity;
    modelViewMatrix1 = GLKMatrix4Translate(modelViewMatrix1, 0, 0, camera.z);
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix1 = GLKMatrix4Translate(modelViewMatrix1, camera.x + _oneLineBuffer[3], camera.y + _oneLineBuffer[4], 0);
    modelViewMatrix1 = GLKMatrix4Scale(modelViewMatrix1, locationScale, locationScale, locationScale);//
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    
    effect.transform.modelviewMatrix = modelViewMatrix1;
    [effect prepareToDraw];
    
    if(_endlocationPolygon != nil){
        [_endlocationPolygon renderWithEffect:effect];
    }
    
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Identity;//
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0, camera.z);//
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);//
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);//
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, camera.x + _oneLineBuffer[0], camera.y + _oneLineBuffer[1], 0);
    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, locationScale, locationScale, locationScale);//
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);//
    
    effect.transform.modelviewMatrix = modelViewMatrix2;
    [effect prepareToDraw];
    
    [_locationPolygon renderWithEffect:effect];
    
    [self renderOverlayWithEffect:effect andCamera:camera];
    
    double dist = [DistanceCalculator distanceWithWorldX1:_oneLineBuffer[0] andWorldY1:_oneLineBuffer[1] andWorldX2:_oneLineBuffer[3] andWorldY2:_oneLineBuffer[4] andMeasurementSystem:self.measurementSystem];
    GLKTextureInfo* texture = [self createCalloutTextureWithText:[NSString stringWithFormat:@"%d", (int)round(dist)]];
    
    TexturedPolygon* polygon = [[TexturedPolygon alloc] initWithTexture:texture andVertexBuffer:_tempPolygonVertexBuffer andUVBuffer:_tempPolygonUVBuffer];
    
    Vector* pt1 = [[Vector alloc] initWithX:_oneLineBuffer[0] andY:_oneLineBuffer[1]];
    Vector* pt2 = [[Vector alloc] initWithX:_oneLineBuffer[3] andY:_oneLineBuffer[4]];
    
    Vector* pos = [self calculateCalloutDrawPositionWithVector1:pt1 andVector2:pt2 andCamera:camera];
    
    CGFloat calloutScale = fabs(camera.z * CALLOUT_SCALE);
    
    if (pos) {
        GLKMatrix4 modelViewMatrix3 = GLKMatrix4Identity;//
        modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, 0, 0, camera.z);//
        modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);//
        modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);//
        modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, camera.x + pos.x, camera.y + pos.y, 0);//
        modelViewMatrix3 = GLKMatrix4Scale(modelViewMatrix3, calloutScale , calloutScale, calloutScale);
        modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
        effect.transform.modelviewMatrix = modelViewMatrix3;
        [effect prepareToDraw];
        
        [polygon renderWithEffect:effect];
        [polygon destroy];
    }
    
}

- (void)renderOverlayWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    if (self.showOverlay == NO) {
        return;
    }
    
    double xstart = self.calloutsDrawMode == CalloutsDrawModeTwoSegments ? _twoLineBuffer[0] : _oneLineBuffer[0];
    double ystart = self.calloutsDrawMode == CalloutsDrawModeTwoSegments ? _twoLineBuffer[1] : _oneLineBuffer[1];
    
    double xend = self.calloutsDrawMode == CalloutsDrawModeTwoSegments ? _twoLineBuffer[6] : _oneLineBuffer[3];
    double yend = self.calloutsDrawMode == CalloutsDrawModeTwoSegments ? _twoLineBuffer[7] : _oneLineBuffer[4];
    
    double distanceWorld = [VectorMath distanceWithVector1:[[Vector alloc] initWithX:xstart andY:ystart] andVector2:[[Vector alloc] initWithX:xend andY:yend]];
    
    double dist = [DistanceCalculator distanceWithWorldX1:xstart andWorldY1:ystart andWorldX2:xend andWorldY2:yend andMeasurementSystem:self.measurementSystem];
    double factor = distanceWorld / dist;
    
    if (dist > 100) {
        [self drawArcWithDistance:100 andColor:_color100 andCamera:camera andEffect:effect andFactor:factor andXPos:xstart andYPos:ystart andPolygon:_distance100];
    }
    
    if (dist > 150) {
        [self drawArcWithDistance:150 andColor:_color150 andCamera:camera andEffect:effect andFactor:factor andXPos:xstart andYPos:ystart andPolygon:_distance150];
    }
    
    if (dist > 200) {
        [self drawArcWithDistance:200 andColor:_color200 andCamera:camera andEffect:effect andFactor:factor andXPos:xstart andYPos:ystart andPolygon:_distance200];
    }
    
    if (dist > 250) {
        [self drawArcWithDistance:250 andColor:_color250 andCamera:camera andEffect:effect andFactor:factor andXPos:xstart andYPos:ystart andPolygon:_distance250];
    }
    
    if (dist > 300) {
        [self drawArcWithDistance:300 andColor:_color300 andCamera:camera andEffect:effect andFactor:factor andXPos:xstart andYPos:ystart andPolygon:_distance300];
    }
}



- (void)drawArcWithDistance:(float)distance andColor:(UIColor*)color andCamera:(Camera*)camera andEffect:(GLKBaseEffect*)effect andFactor:(double)factor andXPos:(double)xpos andYPos:(double)ypos andPolygon:(TexturedPolygon*)polygon {
    
    NSMutableArray *linesArray = [NSMutableArray new];
    NSMutableArray *colorArray = [NSMutableArray new];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix,camera.x + xpos, camera.y + ypos, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    glLineWidth(2);
    
    float fstart_angle = 60;
    float farc_angle = (90 - fstart_angle) * 2;
    float start_angle = [VectorMath deg2radWithDeg:fstart_angle];
    float arc_angle = [VectorMath deg2radWithDeg:farc_angle];
    float r = distance * factor;
    float step = arc_angle / (float)num_segments;
    
    CGPoint firstPoint;
    CGPoint lastPoint;
    
    for (int i = 0 ; i < num_segments ; i++) {
        
        float x = cosf(start_angle + step*(float)i);
        float y = sinf(start_angle + step*(float)i);
        
        x *= r;
        y *= r;
        
        [linesArray addObject:@(x)];
        [linesArray addObject:@(y)];
        [linesArray addObject:@(0)];
        
        if (i == 0) {
            firstPoint = CGPointMake(x, y);
        } else if (i == num_segments - 1) {
            lastPoint = CGPointMake(x, y);
        }
    }
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = components[3];
    
    for(int i = 0 ; i < num_segments ; i++) {
        [colorArray addObject:@(red)];
        [colorArray addObject:@(green)];
        [colorArray addObject:@(blue)];
        [colorArray addObject:@(alpha)];
    }
    
    [GLHelper updateBuffer:_tempColorBuffer andData:colorArray];
    [GLHelper updateBuffer:_tempVertexBuffer andData:linesArray];
    
    [GLHelper drawVertexBuffer:_tempVertexBuffer andColorBuffer:_tempColorBuffer andMode:GL_LINE_STRIP andCount:num_segments];
    
    CGFloat _distanceScale = fabs(camera.z * DISTANCE_LABEL_SCALE);
    CGFloat shift = fabs(camera.z * 0.01);
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Identity;
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0, camera.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2,camera.x + xpos, camera.y + ypos, 0);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-fstart_angle/2 + 2 - 0.005 * distance], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, r + shift, 0);
    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, _distanceScale, _distanceScale, _distanceScale);
    
    effect.transform.modelviewMatrix = modelViewMatrix2;
    [effect prepareToDraw];
    
    [polygon renderWithEffect:effect];
    
    GLKMatrix4 modelViewMatrix3 = GLKMatrix4Identity;
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, 0, 0, camera.z);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3,camera.x + xpos, camera.y + ypos, 0);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix3 = GLKMatrix4Rotate(modelViewMatrix3, [VectorMath deg2radWithDeg:fstart_angle/2 - 5 + 0.005 * distance], 0, 0, 1);
    modelViewMatrix3 = GLKMatrix4Translate(modelViewMatrix3, 0, r + shift, 0);
    modelViewMatrix3 = GLKMatrix4Scale(modelViewMatrix3, _distanceScale, _distanceScale, _distanceScale);
    
    effect.transform.modelviewMatrix = modelViewMatrix3;
    [effect prepareToDraw];
    
    [polygon renderWithEffect:effect];
}



- (GLKTextureInfo*)createTextureWithText:(NSString*)text andTextColor:(UIColor*)textColor {
    int textSize = 40;
    int width = 128;
    int height = 128;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
    
    UIFont* font = [self getFontWithName:@"Source Sans Pro Bold" andSize:textSize];
    if (font == nil) {
        font = [self getFontWithName:@"Source Sans Pro Bold" andSize:textSize];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:textSize];
    }
    CGSize size = [text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    CGPoint drawPoint = CGPointMake((width - size.width)/2, (height - size.height)/2-10);
    
    [text drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                font, NSFontAttributeName,
                                                textColor, NSForegroundColorAttributeName, nil]];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
    return labelTexture;
}

- (UIFont*) getFontWithName:(NSString*) name andSize:(CGFloat)fontSize {
//    NSString *fontPath = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    UIFont* font = [UIFont fontWithName:name size:fontSize];
    return font;
}

- (GLKTextureInfo*)createCalloutTextureWithText:(NSString*)text {
    
    UIColor* textColor = [UIColor blackColor];
    int textSize = 40;
    int width = 128;
    int height = 128;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
    
    [_calloutBg drawInRect:CGRectMake(0, 0, width, height)];
    
    UIFont* font = [self getFontWithName:@"Source Sans Pro Bold" andSize:textSize];
    if (font == nil) {
        font = [self getFontWithName:@"Source Sans Pro Bold" andSize:textSize];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:textSize];
    }
    
    CGSize size = [text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    CGPoint drawPoint = CGPointMake((width - size.width)/2, (height - size.height)/2);
    
    [text drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                font, NSFontAttributeName,
                                                textColor, NSForegroundColorAttributeName, nil]];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
    
    return labelTexture;
}

- (Vector*)calculateCalloutDrawPositionWithVector1:(Vector*)vector1 andVector2:(Vector*)vector2 andCamera:(Camera*)camera {
    
    NSArray<Vector*>* unprojectViewport = [camera unprojectViewport];
    
    if (unprojectViewport == nil) {
        return nil;
    }
    
    NSMutableArray<Vector*>* corners = [NSMutableArray arrayWithArray:unprojectViewport];
    
    [corners addObject:corners.firstObject];
    
    BOOL v1inside = [VectorMath isVector:vector1 insidePolygon:corners];
    BOOL v2inside = [VectorMath isVector:vector2 insidePolygon:corners];
    
    if (!v1inside && !v2inside) {
        Vector* intersection1;
        Vector* intersection2;
        for (int i = 0 ; i < corners.count-1 ; i++) {
            Vector* intersection = [VectorMath intersectionWithVectorLine1V1:vector1 andLine1V2:vector2 andLine2V1:corners[i] andLine2V2:corners[i+1]];
            if (intersection != nil) {
                if (intersection1 == nil) {
                    intersection1 = intersection;
                } else if (intersection2 == nil) {
                    intersection2 = intersection;
                    break;
                }
            }
        }
        
        if (intersection2 == nil) {
            return nil;
        }
        
        return [[intersection1 addedWithVector:intersection2] multipliedWithFactor:0.5];
    }
    
    if (v1inside && v2inside) {
        return [[vector1 addedWithVector:vector2] multipliedWithFactor:0.5];
    }
    
    [corners addObject:[corners objectAtIndex:0]];
    
    Vector* visiblePoint = v1inside ? vector1 : vector2;
    Vector* invisiblePoint = v2inside ? vector1 : vector2;
    Vector* intersection = nil;
    
    for (int i = 0 ; i < corners.count-1 ; i++) {
        intersection = [VectorMath intersectionWithVectorLine1V1:visiblePoint andLine1V2:invisiblePoint andLine2V1:corners[i] andLine2V2:corners[i+1]];
        if (intersection != nil) {
            break;
        }
    }
    
    if (intersection == nil) {
        return nil;
    }
    
    return [[intersection addedWithVector:visiblePoint] multipliedWithFactor:0.5];
}

- (BOOL)canResetPinPosition {
    
    BOOL retval = true;
    
    if (_lastDragDate) {
        retval = fabs([_lastDragDate timeIntervalSinceNow]) >= 15.0;
    }
    
    return retval;
}



@end
