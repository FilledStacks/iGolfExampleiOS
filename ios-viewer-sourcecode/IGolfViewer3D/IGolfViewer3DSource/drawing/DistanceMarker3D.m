//
//  DistanceMarker3D.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "DistanceMarker3D.h"
#import <OpenGLES/ES3/gl.h>
#import <CoreLocation/CoreLocation.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface DistanceMarker3D() {
    
    ElevationMap* _grid;
    
    
    TexturedPolygon* _layupHeaderPolygon;
    TexturedPolygon* _headerLabelsPolygon;
    TexturedPolygon* _layupDistancePolygon;
    TexturedPolygon* _centerDistancePolygon;
    
    TexturedPolygon* _calloutPolygon;
    TexturedPolygon* _groundMarkerPolygon;
    
    Vector* _position;
    
    CLLocation* _currentLocation;
    CLLocation* _centerLocation;
    
    double _markerScale;
    double _fontScale;
    
    //int _distance;
    
    double _layupDistance;
    double _greenDistance;
    
    double _zPosition;
    
    BOOL _hasGroundMarker;
}

@end

@implementation DistanceMarker3D

- (double)DefaultScale {
    return 10 * METERS_IN_POINT;
}

- (double)OveralScale {
    return 28 * METERS_IN_POINT;
}

- (double)zPosition {
    return _zPosition;
}

-(Vector *)markerPosition {
    return _position;
}

- (CLLocation*)currentLocation {
    return _currentLocation;
}

- (void)setCenterLocation:(CLLocation *)centerLocation andCurrentLocation:(CLLocation *)currentLocation {
    
    double l = currentLocation == nil ? 999 : [self distanceFrom:self.location to:currentLocation] + 0.5;
    double g = [self distanceFrom:self.location to:centerLocation] + 0.5;
    
    if (l != _layupDistance) {
        _layupDistance = l;
        [self updateLayupDistanceLabel];
    }
    
    if (g != _greenDistance) {
        _greenDistance = g;
        [self updateGreenDistanceLabel];
    }
    
    _currentLocation = currentLocation;
    _centerLocation = centerLocation;
    
    double posX = [Layer transformLonFromDouble:self.location.coordinate.longitude];
    double posY = [Layer transformLatFromDouble:self.location.coordinate.latitude];
    double posZ = [_grid getZPositionForLocation:self.location];
    
    _position = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
}

- (UIFont*) getFontWithName:(NSString*) name andSize:(CGFloat)fontSize {
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    UIFont* font = [UIFont fontWithName:fontPath size:fontSize];
    return font;
}

- (void)updateLayupDistanceLabel {
    
    int width = 128;
    int height = 128;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
    
    NSString* string = [NSString stringWithFormat:@"%u", (int) _layupDistance];
    
    UIFont* font = [self getFontWithName:@"BEBASNEUE" andSize:37];
    if (font == nil) {
        font = [self getFontWithName:@"Source Sans Pro Bold" andSize:37];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:30];
    }
    
    CGSize size = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    
    
    CGPoint drawPoint = CGPointMake(((width / 4) - size.width / 2), 15);
    
    
    [string drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  font, NSFontAttributeName,
                                                  [UIColor blackColor], NSForegroundColorAttributeName, nil]];
    
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
    
    
    
    if (_layupDistancePolygon.texture != nil) {
        [_layupDistancePolygon.texture releaseTexture];
    }
    
    _layupDistancePolygon.texture = labelTexture;
    
}

- (void)updateGreenDistanceLabel {
    
    int width = 128;
    int height = 128;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
    
    NSString* string = [NSString stringWithFormat:@"%u", (int) _greenDistance];
    
    UIFont* font = [self getFontWithName:@"BEBASNEUE" andSize:37];
    if (font == nil) {
        font = [self getFontWithName:@"Source Sans Pro Bold" andSize:37];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:30];
    }
    
    CGSize size = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
  
    
    CGPoint drawPoint = CGPointMake((((width / 4) * 3) - size.width / 2), 15);
   
    
    [string drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            font, NSFontAttributeName,
                                                            [UIColor blackColor], NSForegroundColorAttributeName, nil]];
    
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
    
    
    
    if (_centerDistancePolygon.texture != nil) {
        [_centerDistancePolygon.texture releaseTexture];
    }
    
    _centerDistancePolygon.texture = labelTexture;
}

//- (void)setCurrentLocation:(CLLocation *)currentLocation {
//    double d = currentLocation == nil ? 999 : [self distanceFrom:self.location to:currentLocation] + 0.5;
//
//    if (d != _distance) {
//        _distance = d;
//
//        [self updateLabel];
//    }
//
//    _currentLocation = currentLocation;
//
//    double posX = [Layer transformLonFromDouble:self.location.coordinate.longitude];
//    double posY = [Layer transformLatFromDouble:self.location.coordinate.latitude];
//    double posZ = [_grid getZPositionForLocation:self.location];
//
//    _position = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
//}

- (void)setMeasurementSystem:(MeasurementSystem)measurementSystem {
    if (measurementSystem != _measurementSystem) {
        _measurementSystem = measurementSystem;
        [self updateLayupDistanceLabel];
        [self updateGreenDistanceLabel];
//        [self updateLabel];
    }
}


- (void)createHeaders {
    
    int width = 128;
    int height = 128;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
    
    NSString* layupString = @"LAYUP";
    NSString* centerString = @"CENTER";
    
    UIFont* font = [self getFontWithName:@"BEBASNEUE" andSize:15];
    if (font == nil) {
        font = [self getFontWithName:@"Source Sans Pro Bold" andSize:15];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:10];
    }
    
    CGSize sizeLayup = [layupString sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    CGSize sizeCenter = [centerString sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    
    CGPoint drawPointLayup = CGPointMake(((width / 4) - sizeLayup.width / 2), 5);
    CGPoint drawPointCenter = CGPointMake(((width / 4) * 3) - (sizeCenter.width / 2) , 5);
    
    
//    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height));
//    [[[UIColor redColor] colorWithAlphaComponent:0.3] setFill];
//    UIRectFill(CGRectMake(0, 0, width, height));
    
    [layupString drawAtPoint:drawPointLayup withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            font, NSFontAttributeName,
                                                            [UIColor blackColor], NSForegroundColorAttributeName, nil]];
    [centerString drawAtPoint:drawPointCenter withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              font, NSFontAttributeName,
                                                              [UIColor blackColor], NSForegroundColorAttributeName, nil]];
    
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
    
    if (_headerLabelsPolygon.texture != nil) {
        [_headerLabelsPolygon.texture releaseTexture];
    }
    
    _headerLabelsPolygon.texture = labelTexture;
}

-(id)initWithGroundTextureFilename:(NSString *)groundTextureFilename andLocation:(CLLocation *)location andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer andElevationGrid:(ElevationMap *)grid {
    self = [super init];
    self->_hasGroundMarker = false;
    self->_headerLabelsPolygon = [[TexturedPolygon alloc] initWithTexture:nil andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_centerDistancePolygon = [[TexturedPolygon alloc] initWithTexture:nil andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_layupDistancePolygon = [[TexturedPolygon alloc] initWithTexture:nil andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_markerScale = self.DefaultScale;
    self->_fontScale = self.DefaultScale;
    self->_layupDistance = 999.0;
    self->_greenDistance = 999.0;
//    self->_distance = 999;
    self->_visible = true;
    self.location = location;
    if (groundTextureFilename != nil) {
        _groundMarkerPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:groundTextureFilename]andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        self->_hasGroundMarker = true;
    }
    
    self->_calloutPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_distance_marker_background" ofType:@"png"]] andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_grid = grid;
//    [self updateLabel];
    [self createHeaders];
    [self updateLayupDistanceLabel];
    [self updateGreenDistanceLabel];
    
    double posX = [Layer transformLonFromDouble:self.location.coordinate.longitude];
    double posY = [Layer transformLatFromDouble:self.location.coordinate.latitude];
    double posZ = [_grid getZPositionForLocation:self.location];
    
    _position = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
    
    return self;
}

-(BOOL)hasGroundMarker {
    return _hasGroundMarker;
}

- (void)calculateMatricesWithCamera:(Camera*)camera {
    
    GLKMatrix4 modelView = GLKMatrix4Identity;
    modelView = GLKMatrix4Translate(modelView, 0, 0, camera.z);
    modelView = GLKMatrix4Rotate(modelView, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelView = GLKMatrix4Rotate(modelView, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelView = GLKMatrix4Translate(modelView, camera.x + _position.x, camera.y + _position.y, _position.z);
    
    GLKVector4 vertex = GLKMatrix4MultiplyVector4(modelView, GLKVector4Make(0, 0, 0, 1));
    _zPosition = vertex.z / vertex.w;
    
    GLKMatrix4 modelViewProjection = GLKMatrix4Multiply(camera.projectionMatrix, modelView);
    
    vertex = GLKMatrix4MultiplyVector4(modelViewProjection, GLKVector4Make(0, 0, 0, 1));
    _projectedPosition = [[Vector alloc] initWithX:vertex.x/vertex.w andY:vertex.y/vertex.w];
}

-(void)renderGroundMarkerForPosition:(Vector *)position andEffect:(GLKBaseEffect*)effect {
    if (_groundMarkerPolygon == nil) {
        return;
    }
    
    if (_visible == NO) {
        return;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, position.z);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, position.x + _position.x, position.y + _position.y, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.175 * _markerScale, 0.175 * _markerScale, 0.175 * _markerScale);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_groundMarkerPolygon renderWithEffect:effect];
    
}

-(void)renderGroundMarkerWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    if (_groundMarkerPolygon == nil) {
        return;
    }
    
    if (_visible == NO) {
        return;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.175 * _markerScale, 0.175 * _markerScale, 0.175 * _markerScale);
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_groundMarkerPolygon renderWithEffect:effect];
}

-(void)scaleByPositionWithAdditionalScale:(double)scale {
    _fontScale = (1.0 - (_zPosition + 3.5) / 7) * scale;
    _markerScale = _fontScale;
}
-(void)setScale:(double)scale {
    _fontScale = scale;
    _markerScale = scale;
}

-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    if (_visible == NO) {
        return;
    }
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.6 * 0.5 * _fontScale, 0.38 * 0.5 * _fontScale , 0.6 * 0.5 * _fontScale);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_calloutPolygon renderWithEffect:effect];
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Identity;
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0, camera.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, camera.x + _position.x, camera.y + _position.y, _position.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, 0.3 * _fontScale, 0.3 * _fontScale, 0.3 * _fontScale);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0.26, 0);
    effect.transform.modelviewMatrix = modelViewMatrix2;
    [effect prepareToDraw];

    [_headerLabelsPolygon renderWithEffect:effect];
    [_centerDistancePolygon renderWithEffect:effect];
    [_layupDistancePolygon renderWithEffect:effect];
}


- (void)destroy {
    
    if (_layupDistancePolygon.texture != nil) {
        [_layupDistancePolygon.texture releaseTexture];
    }
    
    if (_centerDistancePolygon.texture != nil) {
        [_centerDistancePolygon.texture releaseTexture];
    }
    
    if (_headerLabelsPolygon.texture != nil) {
        [_headerLabelsPolygon.texture releaseTexture];
    }
}

//- (void)updateLabel {
//
//    int width = 128;
//    int height = 128;
//
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);
//
//    NSString* string = [NSString stringWithFormat:@"%i", _distance];
//
//    UIFont* font = [UIFont fontWithName:@"BebasNeue" size:100];
//    if (font == nil) {
//        font = [UIFont fontWithName:@"LeagueGothic" size:100];
//    }
//    if (font == nil) {
//        font = [UIFont systemFontOfSize:60];
//    }
//    CGSize size = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
//    CGPoint drawPoint = CGPointMake((width - size.width)/2, (height - size.height)/2);
//    [string drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                  font, NSFontAttributeName,
//                                                  @(2), NSStrokeWidthAttributeName,
//                                                  [UIColor blackColor], NSStrokeColorAttributeName,
//                                                  [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
//    [string drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                  font, NSFontAttributeName,
//                                                  [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
//
//    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
//
//    if (_labelPolygon.texture != nil) {
//        [_labelPolygon.texture releaseTexture];
//    }
//
//    _labelPolygon.texture = labelTexture;
//}

- (int)distanceFrom:(CLLocation*)location1 to:(CLLocation*)location2 {
    
    double d = [DistanceCalculator distanceWithLocation1:location1 andLocation2:location2 andMEasurementSystem:self.measurementSystem];
    
    d = round(d);
    d = MIN(999.0, d);
    
    
    return d;
}

@end
