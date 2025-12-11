//
//  DistanceMarker.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "DistanceMarker.h"
#import <OpenGLES/ES3/gl.h>
#import <CoreLocation/CoreLocation.h>
#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>

#import "../IGolfViewer3DPrivateImports.h"

@interface DistanceMarker () {
    ElevationMap* _grid;
    
    TexturedPolygon* _labelPolygon;
    TexturedPolygon* _calloutPolygon;
    TexturedPolygon* _groundMarkerPolygon;
    TexturedPolygon* _texture2DPolygon;
    
    Vector* _position;
    Vector* _originalPosition;
    
    CLLocation* _originalLocation;
    CLLocation* _currentLocation;
    
    double _markerScale;
    double _fontScale;
    int _markerType;
    
    int _distance;
    double _zPosition;
    
    BOOL _hasGroundMarker;
}


#define TEXTURE_2D_SCALE 0.08

@property (nonatomic, readonly) double DefaultScale;

@end

@implementation DistanceMarker

- (double)DefaultScale {
    return 10 * METERS_IN_POINT;
}

- (double)OveralScale {
    return 10 * METERS_IN_POINT;
}

- (double)zPosition {
    return _zPosition;
}

-(Vector *)markerPosition {
    return _position;
}

- (Vector *)markerOriginalPosition{
    return _originalPosition;
}

- (CLLocation*)currentLocation {
    return _currentLocation;
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    double d = currentLocation == nil ? 999 : [self distanceFrom:self.location to:currentLocation] + 0.5;
    
    if (d != _distance) {
        _distance = d;
        
        [self updateLabel];
    }
    
    _currentLocation = currentLocation;
    
    double posX = [Layer transformLonFromDouble:self.location.coordinate.longitude];
    double posY = [Layer transformLatFromDouble:self.location.coordinate.latitude];
    double posZ = [_grid getZPositionForLocation:self.location];
    
    _position = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
}


- (void) restoreOriginalLocation {
    [self updateMarkerLocation:_originalLocation];
}

- (void)updateMarkerLocation:(CLLocation *)location {
    
    self.location = location;
    
    double posX = [Layer transformLonFromDouble:location.coordinate.longitude];
    double posY = [Layer transformLatFromDouble:location.coordinate.latitude];
    double posZ = [_grid getZPositionForLocation:location];
    
    _position = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
}

- (void)setMeasurementSystem:(MeasurementSystem)measurementSystem {
    if (measurementSystem != _measurementSystem) {
        _measurementSystem = measurementSystem;
        [self updateLabel];
    }
}

-(id)initWithGroundTextureFilename:(NSString *)groundTextureFilename andCalloutTextureFileName:(NSString*)calloutTextureFileName andtexture2DFileName:(NSString*) texture2DFileName andLocation:(CLLocation *)location andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer andElevationGrid:(ElevationMap *)grid andMarkerType: (int) type {
    self = [super init];
    self-> _markerType = type;
    self->_hasGroundMarker = false;
    self->_labelPolygon = [[TexturedPolygon alloc] initWithTexture:nil andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    self->_markerScale = self.DefaultScale;
    self->_fontScale = self.DefaultScale;
    self->_distance = 999;
    self->_visible = true;
    self.location = location;
    
    if (groundTextureFilename != nil) {
        self->_groundMarkerPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:groundTextureFilename]andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
        self->_hasGroundMarker = true;
    }
    
    if (texture2DFileName != nil) {
        self->_texture2DPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:texture2DFileName]andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    }
     
    if (calloutTextureFileName != nil) {
        self->_calloutPolygon = [[TexturedPolygon alloc] initWithTexture:[GLKTextureInfo loadFromCacheWithFilePath:calloutTextureFileName]andVertexBuffer:vertexBuffer andUVBuffer:uvBuffer];
    }
    
    self->_grid = grid;
    [self updateLabel];
    
    _originalLocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    double posX = [Layer transformLonFromDouble:self.location.coordinate.longitude];
    double posY = [Layer transformLatFromDouble:self.location.coordinate.latitude];
    double posZ = [_grid getZPositionForLocation:self.location];
    
    _position = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
    _originalPosition = [[Vector alloc] initWithX:posX andY:posY andZ:posZ];
    
    
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
    
    switch (_markerType) {
        case 1:
            //hazards
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.175 * _markerScale, 0.175 * _markerScale, 0.175 * _markerScale);
            break;
        case 2:
            //tap distance
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.175 * _markerScale, 0.175 * _markerScale, 0.175 * _markerScale);
            break;
        default:
            //front back
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.115 * _markerScale, 0.115f * _markerScale, 0.115f * _markerScale);
            break;
    }
    
    
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_groundMarkerPolygon renderWithEffect:effect];
}

-(void)render2DTextureWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    if (_texture2DPolygon == nil) {
        return;
    }
    
    CGFloat scale = MAX(4 * METERS_IN_POINT, fabs(camera.z * TEXTURE_2D_SCALE));
    scale *= 0.95;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.13 * scale, 0.13 * scale, 0.13 * scale);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    effect.transform.modelviewMatrix = modelViewMatrix;
    [effect prepareToDraw];
    
    [_texture2DPolygon renderWithEffect:effect];
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
    
    if (camera.navigationMode == NavigationMode2DGreenView || camera.navigationMode == NavigationMode2DView) {
        [self render2DWithEffect:effect andCamera:camera];
        return;
    }
    
    if(camera.navigationMode == NavigationMode2DGreenView || camera.navigationMode == NavigationMode2DView){
        return;
    }
    
    if (_visible == NO) {
        return;
    }
    
    if (_calloutPolygon != nil) {
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, camera.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, camera.x + _position.x, camera.y + _position.y, _position.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:camera.viewAngle], 1, 0, 0);
        switch (_markerType) {
            case 1:
                //hazards
                modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.15 * _fontScale, 0.22 / 3 * _fontScale , 1 * _fontScale);
                break;
            case 2:
                //tap distance
                modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.2 * _fontScale, 0.2 / 3 * _fontScale , 1 * _fontScale);
                break;
            default:
                //front back
                modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.15 * _fontScale, 0.15 / 3 * _fontScale , 1 * _fontScale);
                break;
        }
        
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 1, 0);
        effect.transform.modelviewMatrix = modelViewMatrix;
        [effect prepareToDraw];
        
        [_calloutPolygon renderWithEffect:effect];
    }
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4Identity;
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 0, camera.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, camera.x + _position.x, camera.y + _position.y, _position.z);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:-camera.rotationAngle], 0, 0, 1);
    modelViewMatrix2 = GLKMatrix4Rotate(modelViewMatrix2, [VectorMath deg2radWithDeg:camera.viewAngle], 1, 0, 0);
    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, 0.2 * _fontScale, 0.2 * _fontScale, 0.2 * _fontScale);
    
    switch (_markerType) {
        case 1:
            //hazards
            modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 1.25, 0);
            break;
        case 2:
            //tap distance
            modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 1.25, 0);
            break;
        default:
            //front back
            modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0, 1, 0);
            break;
    }
    effect.transform.modelviewMatrix = modelViewMatrix2;
    [effect prepareToDraw];

    [_labelPolygon renderWithEffect:effect];
}

-(void)render2DWithEffect:(GLKBaseEffect *)effect andCamera:(Camera *)camera {
    
    [self render2DTextureWithEffect:effect andCamera:camera];
}


- (void)destroy {
    if (_labelPolygon.texture != nil) {
        [_labelPolygon.texture releaseTexture];
    }
}

- (UIFont*) getFontWithName:(NSString*) name andSize:(CGFloat)fontSize {
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    UIFont* font = [UIFont fontWithName:fontPath size:fontSize];
    return font;
}

- (void)updateLabel {
    int width = 128;
    int height = 128;

    //GLuint glError = glGetError();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, [UIScreen mainScreen].scale);

    NSString* string = [NSString stringWithFormat:@"%i", _distance];
    
    UIFont* font = [self getFontWithName:@"BEBASNEUE" andSize:60];
    
    UIFont* font2 = [self getFontWithName:@"Source Sans Pro Bold" andSize:60];
    if (font == nil) {
        if (font2 == nil) {
            font = [self getFontWithName:@"BEBASNEUE" andSize:80];
        }
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:60];
    }
    
    UIColor* shadowColor = [UIColor colorWithRed:0
                    green:0
                     blue:0
                    alpha:0.5];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = shadowColor;
        shadow.shadowBlurRadius = 20;
        shadow.shadowOffset = CGSizeMake(0.0, 2.0);
    
    CGSize size = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    CGPoint drawPoint = CGPointMake((width - size.width)/2, (height - size.height)/2);
    [string drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  font, NSFontAttributeName,
                                                  shadow, NSShadowAttributeName,
                                                  [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [string drawAtPoint:drawPoint withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  font, NSFontAttributeName,
                                                  shadow, NSShadowAttributeName,
                                                  [UIColor whiteColor], NSForegroundColorAttributeName, nil]];

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    GLKTextureInfo* labelTexture = [GLKTextureLoader textureWithCGImage:[image CGImage] options:nil error:nil];
    
    if (_labelPolygon.texture != nil) {
        [_labelPolygon.texture releaseTexture];
    }

    _labelPolygon.texture = labelTexture;
}

- (int)distanceFrom:(CLLocation*)location1 to:(CLLocation*)location2 {
    
    double d = [DistanceCalculator distanceWithLocation1:location1 andLocation2:location2 andMEasurementSystem:self.measurementSystem];
    
    d = round(d);
    d = MIN(999.0, d);

    
    return d;
}

@end
