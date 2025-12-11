//
//  Camera.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Camera.h"
#import "NavigationMode.h"
#import <OpenGLES/ES3/gl.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface Camera () {
    
    double _x;
    double _y;
    double _z;
    double _xGesturePan;
    double _yGesturePan;
    
    double _gestureRotation;
    double _gestureZoom;
    double _rotationAngle;
    double _cameraViewShift;
    double _overalHoleZposition;
    double _extraZstartTitling;
    double _diffExtraZ;
    BOOL _enteredFairway;
    BOOL _isAutozoomActive;
    BOOL _is3DEnabled;
    float _viewportXOffset;
    
    CGPoint _gesturePan;
    CGRect _viewport;
    
    
    NavigationMode _navigationMode;
    FlyoverController* _flyoverController;
    ElevationMap* _grid;
    FlyoverParameters* _flyoverParameters;
    Frustum* _frustum;
    
    NSMutableArray* _zNormalizer;
    NSDictionary<NSNumber*, ParViewConfig*>* _parZoomLevels;
    
    double _diffuseColor;
    double _specularColor;
    double _ambientColor;
    NSString* _protectionCode;
    CLLocation* _location;
}

@property (nonatomic, readonly) double FreeCamZPos;
@property (nonatomic, readonly) double FlyoverZPos;
@property (nonatomic, readonly) double MaxZ2D;
@property (nonatomic, readonly) double MinZ2D;

@end

@implementation Camera

@synthesize delegate;

+ (NSString*)NavigationModeChangedNotification {
    return @"NavigationModeChangedNotification";
}

+ (NSString*)FlyoverFinishedNotification {
    return @"FlyoverFinishedNotification";
}

+(NSString *)CameraRequiresDrawNotification {
    return @"CameraRequiresDrawNotification";
}

+ (NSString*)NavigationModeKey {
    return @"NavigationModeKey";
}

-(Frustum *)frustum {
    return _frustum;
}

- (double)FreeCamZPos {
    return -4.0;
}

-(void)setAutoZoomActive:(BOOL)isActive {
    _isAutozoomActive = isActive;
}

-(BOOL)isAutozoomActive {
    return _isAutozoomActive;
}

- (void)setOverallHoleViewAngle:(double)overallHoleViewAngle {
    _overallHoleViewAngle = overallHoleViewAngle;
    
    if (_navigationMode == NavigationModeOverallHole) {
        _viewAngle = _overallHoleViewAngle;
    }
    
    [self prepareFlyoverParameters];
}

-(void)setFlyoverViewAngle:(double)flyoverViewAngle {
    _flyoverViewAngle = flyoverViewAngle;
    
    [self prepareFlyoverParameters];
}

- (void)setFreeCamViewAngle:(double)freeCamViewAngle {
    _freeCamViewAngle = freeCamViewAngle;
}

- (void)setGreenViewViewAngle:(double)greenViewViewAngle {
    _greenViewViewAngle = greenViewViewAngle;
}

- (double)FlyoverZPos {
    return -3;
}

- (double)MaxZ2D {
    return -50;
}

- (double)MinZ2D {
    return -5;
}

+(double)autoZoomPeriod {
    return 15;
}

-(void)setViewport:(CGRect)viewport{
    _viewport = viewport;
}

-(CGRect)getViewport {
    return _viewport;
}

- (BOOL)currentLocationVisible {
    Vector* projected = [self projectWithVector:_callouts.startLocation];
    
    const double threshold = 0.9;
    return fabs(projected.x) < threshold && fabs(projected.y) < threshold;
}

- (double)x {
    return _x + _xGesturePan;
}

- (void)setX:(double)x {
    
    _x = x;
}

- (double)y {
    return _y + _yGesturePan;
}

- (void)setY:(double)y {
    _y = y;
}

- (double)z {
    double retval = _z + _gestureZoom;
    if (self.navigationMode == NavigationMode2DView) {
        retval = MIN(self.MinZ2D, retval);
        retval = MAX(self.MaxZ2D, retval);
    }
    return retval;
}

- (void)setZ:(double)z {
    _z = z;
}

- (double)rotationAngle {
    return _rotationAngle + _gestureRotation;
}

- (void)setRotationAngle:(double)rotationAngle {
    _rotationAngle = rotationAngle;
}

- (CGPoint)gesturePan {
    return _gesturePan;
}

- (void)requestRedrawingTiles {
    
    [_grid clean];
    
    double averageViewShift = [self getAverageViewShiftAtCurrentPoint];
    Vector* position = [[Vector alloc] initWithX:_x + _xGesturePan - cos([VectorMath deg2radWithDeg:(90 + _rotationAngle + _gestureRotation)]) * averageViewShift
                                            andY:_y + _yGesturePan + sin([VectorMath deg2radWithDeg:(90 + _rotationAngle + _gestureRotation)]) * averageViewShift
                        ];
    
    [_grid setCurrentTileWithPosition:position andCamera:self];
}

- (void)setGesturePan:(CGPoint)gesturePan {
    
    if (_navigationMode == NavigationModeFlyover && _grid != nil) {
        return;
    }
    
    if (_navigationMode != NavigationMode2DView && _navigationMode != NavigationMode2DGreenView  && _grid != nil)  {
        
        _gesturePan = gesturePan;
        
        Vector* direction = [VectorMath rotatedWithVector:[[Vector alloc] initWithX:_gesturePan.x andY:_gesturePan.y] andAngle:[VectorMath deg2radWithDeg:_rotationAngle]];
        
        double zFactor = (_z ) / self.FreeCamZPos;
        
        _xGesturePan = direction.x / 100 * fabs(zFactor);
        _yGesturePan = -direction.y / 100 * fabs(zFactor);
        
        if (_navigationMode != NavigationMode2DView && _grid != nil) {
            
            Vector* cameraPoint = [self getCameraProjectionPoint];
            
            double cameraProjectionPointAlt = [_grid getZForPointX:cameraPoint.x andY:cameraPoint.y];
            double textureAlt = -(cameraProjectionPointAlt / cos([VectorMath deg2radWithDeg:_viewAngle])) - 2.0;
            switch (_navigationMode) {
                case NavigationModeFlyover:
                    _z = [self normalizeZ:MIN(self.FlyoverZPos - (cameraProjectionPointAlt / cos([VectorMath deg2radWithDeg:_viewAngle])), _flyoverParameters.defaultZoom)];
                    break;
                case NavigationModeFlyoverPause:
                    _z = [self normalizeZ:MIN(self.FlyoverZPos - (cameraProjectionPointAlt / cos([VectorMath deg2radWithDeg:_viewAngle])), _flyoverParameters.defaultZoom)];
                    break;
                case NavigationModeOverallHole:
                    _z = [self normalizeZ:MIN(textureAlt, _overalHoleZposition - _flyoverParameters.holeAltitude)];
                    break;
                case NavigationModeFreeCam:
                    _z = [self normalizeZ:MIN(textureAlt, _overalHoleZposition)];
                    break;
                default:
                    break;
            }
        }
        
    } else {
        _gesturePan = gesturePan;
        
        Vector* direction = [VectorMath rotatedWithVector:[[Vector alloc] initWithX:_gesturePan.x andY:_gesturePan.y] andAngle:[VectorMath deg2radWithDeg:_rotationAngle]];
        
        double zFactor = _z / self.FreeCamZPos;
        
        _xGesturePan = direction.x / 200 * zFactor;
        _yGesturePan = -direction.y / 200 * zFactor;
    }
    
    
}

- (void)endPan {
    _x += _xGesturePan;
    _y += _yGesturePan;
    
    _xGesturePan = 0;
    _yGesturePan = 0;
    
    _gesturePan = CGPointZero;
    
    _lastZoomDate = [NSDate new];
}

- (double)gestureRotation {
    
    return _gestureRotation;
}

- (void)endRotation {
    _rotationAngle += _gestureRotation;
    _gestureRotation = 0;
    
    _lastZoomDate = [NSDate new];
}

- (void)setGestureRotation:(double)gestureRotation {
    
    
    if (_navigationMode != NavigationMode2DView && _grid != nil) {
        
        _gestureRotation = gestureRotation;
        
        Vector* cameraPoint = [self getCameraProjectionPoint];
        double cameraProjectionPointAlt = [_grid getZForPointX:cameraPoint.x andY:cameraPoint.y];
        double textureAlt = -(cameraProjectionPointAlt / cos([VectorMath deg2radWithDeg:_viewAngle])) - 2.0;
        
        switch (_navigationMode) {
            case NavigationModeFlyover:
                _z = [self normalizeZ:MIN(self.FlyoverZPos - (cameraProjectionPointAlt / cos([VectorMath deg2radWithDeg:_viewAngle])), _flyoverParameters.defaultZoom)];
                break;
            case NavigationModeFlyoverPause:
                _z = [self normalizeZ:MIN(self.FlyoverZPos - (cameraProjectionPointAlt / cos([VectorMath deg2radWithDeg:_viewAngle])), _flyoverParameters.defaultZoom)];
                break;
            case NavigationModeOverallHole:
                _z = [self normalizeZ:MIN(textureAlt, _overalHoleZposition - _flyoverParameters.holeAltitude)];
                break;
            case NavigationModeFreeCam:
                _z = [self normalizeZ:MIN(textureAlt, _overalHoleZposition)];
                break;
            default:
                break;
        }
    } else {
        _gestureRotation = gestureRotation;
    }
}

- (void)setGestureZoom:(double)gestureZoom {
    
    if (self.navigationMode == NavigationMode2DView) {
        if (gestureZoom > 1) {
            _gestureZoom = 15 * fabs(gestureZoom - 1);
        } else {
            _gestureZoom = -45 * fabs(1 - gestureZoom);
        }
    }
}

- (void)endZoom {
    
    _z += _gestureZoom;
    
    if (_navigationMode == NavigationMode2DView || _navigationMode == NavigationMode2DGreenView) {
        _z = MIN(self.MinZ2D, _z);
        _z = MAX(self.MaxZ2D, _z);
    }
    
    _gestureZoom = 0;
}

-(NSDate *)getLastZoomDate {
    return _lastZoomDate;
}

- (void)setNavigationMode:(NavigationMode)navigationMode {
    
    if (navigationMode != NavigationMode2DView && navigationMode != NavigationMode2DGreenView && !_is3DEnabled) {
        [NSException raise:@"[CourseRenderView]" format:@"STANDARD VERSION LIMITATION - NavigationMode2DView only is available."];
        return;
    }
    
    [self restartZNormalizer];
    switch (navigationMode) {
        case NavigationMode2DView:
            [self apply2DView];
            _flyoverController = nil;
            _navigationMode = navigationMode;
            [_grid clean];
            break;
        case NavigationMode2DGreenView:
            [self apply2DGreenView];
            _flyoverController = nil;
            _navigationMode = navigationMode;
            [_grid clean];
            break;
        case NavigationMode3DGreenView:
            _flyoverController = nil;
            [self apply3DGreenView];
            _navigationMode = navigationMode;
            break;
        case NavigationModeOverallHole:
            _flyoverController = nil;
            [self applyOverallHole];
            _navigationMode = navigationMode;
            break;
        case NavigationModeFlyoverPause:
            if (_navigationMode != NavigationModeFlyover) {
                return;
            }
            if (_flyoverController != nil) {
                [_flyoverController pause];
                _navigationMode = navigationMode;
            }
            break;
        case NavigationModeFlyover:
            if (_flyoverController != nil) {
                [_flyoverController resume];
            } else {
                _flyoverController = [FlyoverController new];
                [_flyoverController setCleaner:[[CentralPathCleaner alloc]initWithGreenView:_greenLayer]];
                
                _flyoverController.centralPath = _centralPath;
                _flyoverController.defaultViewAngle = self.flyoverViewAngle;
                _viewAngle = self.flyoverViewAngle;
                
                _flyoverController.defaultZoom = _flyoverParameters.defaultZoom;
                _flyoverController.endZoom = _flyoverParameters.endZoom;
                
                [_flyoverController start];
            }
            
            _navigationMode = navigationMode;
            break;
        case NavigationModeFreeCam:
            if (_flyoverController != nil) {
                _flyoverController = nil;
            }
            
            [self apply3DFreeCamMode];
            _navigationMode = navigationMode;
            break;;
        default: break;
    }
    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraDidChangeNavigationMode:")])
        [delegate cameraDidChangeNavigationMode:navigationMode];
    
}

- (NavigationMode)navigationMode {
    return _navigationMode;
}

- (BOOL) isFlyover{
    return _navigationMode == NavigationModeFlyover || _navigationMode == NavigationModeFlyoverPause;
}


-(void)updateFrustum {
    [_frustum updateFrustrumWithModelviewMatrix:self.modelViewMatrix andProjectionMatrix:self.projectionMatrix];
}

- (GLKMatrix4)modelViewMatrix {
    
    GLKMatrix4 retval = GLKMatrix4Identity;
    retval = GLKMatrix4Translate(retval, 0, 0, self.z);
    retval = GLKMatrix4Rotate(retval, [VectorMath deg2radWithDeg:-self.viewAngle], 1, 0, 0);
    retval = GLKMatrix4Rotate(retval, [VectorMath deg2radWithDeg:self.rotationAngle], 0, 0, 1);
    retval = GLKMatrix4Translate(retval, self.x, self.y, 0);
    
    
    
    return retval;
}

- (GLKMatrix4)intersectionUnprojectionMatrix {
    
    GLKMatrix4 retval = GLKMatrix4Identity;
    retval = GLKMatrix4Translate(retval, -self.x, -self.y, 0);
    retval = GLKMatrix4Rotate(retval, [VectorMath deg2radWithDeg:-self.rotationAngle], 0, 0, 1);
    retval = GLKMatrix4Rotate(retval, [VectorMath deg2radWithDeg:self.viewAngle], 1, 0, 0);
    retval = GLKMatrix4Translate(retval, 0, 0, -self.z);
    
    return retval;
}

- (void)updateViewportAndProjectionMatrix:(UIView *)view andRenderWidthPercent:(float)renderViewWidthPercent {
    self->_projectionMatrix = [self makeProjectionMatrixWithView: view andRenderViewWidthPercent:renderViewWidthPercent];
    float size = view.frame.size.width * renderViewWidthPercent;
    self -> _viewportXOffset =view.frame.size.width-size;
    self->_viewport = CGRectMake(_viewportXOffset, 0, size, view.frame.size.height);
    if(_frustum == nil){
        self->_frustum = [Frustum new];
    }
    [self updateFrustum];
}

- (id)initWithView:(UIView *)view andAutoZoomActive:(BOOL)isActive andElevationMap:(ElevationMap*)grid andFinalPosition:(Vector*)position andRotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged{
//    self = [super init];
    _rotateHoleOnLocationChanged = rotateHoleOnLocationChanged;
    if (self) {
        self->_is3DEnabled = true;
//        self->_projectionMatrix = [self makeProjectionMatrixWithView: view];
//        self->_viewport = view.frame;
        ParViewConfig* config;
        NSMutableDictionary<NSNumber*, ParViewConfig*>* parZoomLevels = [NSMutableDictionary new];
        
        config = [ParViewConfig new];
        config.zoomFairway = -5;
        config.advanceFairway = 2.2;
        config.zoomTeeBox = -5;
        config.advanceFairway = 2.2;
        [parZoomLevels setObject:config forKey:@(0)];
        
        config = [ParViewConfig new];
        config.zoomFairway = -3;
        config.advanceFairway = 0;
        config.zoomTeeBox = -4;
        config.advanceFairway = 0.2;
        [parZoomLevels setObject:config forKey:@(3)];
        
        config = [ParViewConfig new];
        config.zoomFairway = -6;
        config.advanceFairway = 2.7;
        config.zoomTeeBox = -5;
        config.advanceFairway = 2.2;
        [parZoomLevels setObject:config forKey:@(4)];
        
        config = [ParViewConfig new];
        config.zoomFairway = -7.5;
        config.advanceFairway = 3.3;
        config.zoomTeeBox = -7;
        config.advanceFairway = 2.2;
        [parZoomLevels setObject:config forKey:@(5)];
        
        config = [ParViewConfig new];
        config.zoomFairway = -7;
        config.advanceFairway = 3.3;
        config.zoomTeeBox = -7;
        config.advanceFairway = 2.2;
        [parZoomLevels setObject:config forKey:@(6)];
        
        self->_parZoomLevels = parZoomLevels;
        self->_isAutozoomActive = isActive;
        self->_grid = grid;
        self->_zNormalizer = [NSMutableArray new];
        self->_overalHoleZposition = 0;
        if(_frustum == nil){
            self->_frustum = [Frustum new];
        }
        self->_diffuseColor = 0.7;
        self->_ambientColor = 0.1;
        self->_specularColor = 0.3;
        self->_navigationMode = NavigationModeOverallHole;
        self->_enteredFairway = false;
        
        [self applyOverallHole];
    }
    return self;
}

-(double)specularColor {
    return _specularColor;
}

-(double)ambientColor {
    return _ambientColor;
}

-(double)diffuseColor {
    return _diffuseColor;
}

-(void)setAmbientColor:(double)ambientColor {
    _ambientColor = ambientColor;
}

-(void)setDiffuseColor:(double)diffuseColor {
    _diffuseColor = diffuseColor;
}

-(void)setSpecularColor:(double)specularColor {
    _specularColor = specularColor;
}



-(void)prepareFlyoverParameters {
    
    if (_grid) {
        
        double maxAlt = 0;
        _extraZstartTitling = 0;
        
        FlyoverController* testFlyoverController = [FlyoverController new];
        [testFlyoverController setCleaner:[[CentralPathCleaner alloc]initWithGreenView:_greenLayer]];
        testFlyoverController.centralPath = _centralPath;
        testFlyoverController.defaultViewAngle = self.flyoverViewAngle;
        testFlyoverController.defaultZoom = self.FlyoverZPos;
        testFlyoverController.endZoom = 0;
        [testFlyoverController start];
        
        Vector* startPosition = [[Vector alloc] initWithX:testFlyoverController.position.x andY:testFlyoverController.position.y];
        
        while (testFlyoverController.finished == false) {
            
            [testFlyoverController testTick];
            
            double viewShift = [self getViewShiftAtPositionX:-testFlyoverController.position.x andY:-testFlyoverController.position.y andViewAngle:_flyoverController.viewAngle];
            
            Vector* shiftedPosition = [self getShiftedPositionForPosition:testFlyoverController.position andViewShift:viewShift andRotationAngle:testFlyoverController.rotationAngle];
            
            double vAlt = [_grid getZForPointX:-shiftedPosition.x andY:-shiftedPosition.y];
            
            maxAlt = MAX(maxAlt, vAlt);
        }
        
        Vector* endPosition = [[Vector alloc] initWithX:testFlyoverController.position.x andY:testFlyoverController.position.y];
        
        double startTitlingViewShift = [self getViewShiftAtPositionX:-testFlyoverController.position.x andY:-testFlyoverController.position.y andViewAngle:70];
        double endTitlingViewShift = [self getViewShiftAtPositionX:-testFlyoverController.position.x andY:-testFlyoverController.position.y andViewAngle:60];
        double extraZstartTitling = startTitlingViewShift / sin([VectorMath deg2radWithDeg:70]);
        double extraZendTitling = endTitlingViewShift / sin([VectorMath deg2radWithDeg:60]);
        double diffExtraZ = fabs(extraZstartTitling - extraZendTitling);
        
        _extraZstartTitling = extraZstartTitling;
        
        double startViewShift = [self getViewShiftAtPositionX:-startPosition.x andY:-startPosition.y andViewAngle:self.flyoverViewAngle];
        double endViewShift = [self getViewShiftAtPositionX:-endPosition.x andY:-endPosition.y andViewAngle:self.flyoverViewAngle];
        double defaultZoom = self.FlyoverZPos - (maxAlt / cos([VectorMath deg2radWithDeg:_flyoverViewAngle]));
        double endZoom = [self calculateGreenViewZpositionWithExtraZ:diffExtraZ andRotationAngle:testFlyoverController.rotationAngle];
        
        double holeAltitude = (maxAlt / cos([VectorMath deg2radWithDeg:_flyoverViewAngle]));
        
        if (fabs(defaultZoom - endZoom) < 0.5) {
            endZoom = defaultZoom;
        }
        
        _flyoverParameters = [[FlyoverParameters alloc] initWithStartPostion:startPosition
                                                                 endPosition:endPosition
                                                                 defaultZoom:defaultZoom
                                                              startViewShift:startViewShift
                                                                endViewShift:endViewShift
                                                                     endZoom:endZoom
                                                                holeAltitude:holeAltitude
                              ];
        
    } else {
        _flyoverParameters = [[FlyoverParameters alloc] initWithStartPostion:nil
                                                                 endPosition:nil
                                                                 defaultZoom:self.FlyoverZPos
                                                              startViewShift:0.0
                                                                endViewShift:0.0
                                                                     endZoom:self.FlyoverZPos * 0.68
                                                                holeAltitude:0.0
                              ];
    }
}

-(double)getAverageViewShiftAtCurrentPoint {
    
    Vector* cameraPoint = [self getCameraProjectionPoint];
    
    double cameraPointAlt = [_grid getZForPointX:cameraPoint.x andY:cameraPoint.y];
    double cameraPointShift = cameraPointAlt * tan([VectorMath deg2radWithDeg:_viewAngle]);
    double cameraViewPointAlt = [_grid getZForPointX:_x andY:_y];
    double cameraViewPointShift = cameraViewPointAlt * tan([VectorMath deg2radWithDeg:_viewAngle]);
    
    return (cameraPointShift + cameraViewPointShift) / 2;
}

-(void)tickWithCallback:(BOOL)withCallback andEffect:(GLKBaseEffect*)effect {
    
    if (withCallback) {
        
        if ((self.navigationMode == NavigationMode2DView) && _lastZoomDate != nil) {
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                [self calculateAutozoomWithInitialZoom:NO];
                self->_lastZoomDate = nil;
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        }
        
        if (self.navigationMode == NavigationMode2DGreenView && _lastZoomDate != nil) {
            
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                
                [self apply2DGreenView];
                self->_lastZoomDate = nil;
                
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        }
        
        if (self.navigationMode == NavigationModeFreeCam && _lastZoomDate != nil) {
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                
                self->_lastZoomDate = nil;
                
                if (_location.coordinate.latitude == _callouts.startPointLocation.coordinate.latitude && _location.coordinate.longitude == _callouts.startPointLocation.coordinate.longitude) {
                    
                    if (!_enteredFairway) {
                        [self apply3DFreeCamMode];
                    } else {
                        [self update3DFreeCamPosition];
                    }
                    
                } else {
                    [self apply3DFreeCamMode];
                }
                
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        }
        
        
        if (self.navigationMode == NavigationMode3DGreenView && _lastZoomDate != nil) {
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                
                self->_lastZoomDate = nil;
                
                [self apply3DGreenView];
                
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        }
        
    } else {
        if (_flyoverController != nil && _navigationMode != NavigationModeFlyoverPause) {
            [_flyoverController tick];
            
            _rotationAngle = _flyoverController.rotationAngle;
            
            _viewAngle = _flyoverController.viewAngle;
            
            if (_grid == nil) {
                _x = -_flyoverController.position.x;
                _y = -_flyoverController.position.y;
                _z = _flyoverController.zoom;
            } else {
                
                double endViewShift = [self getViewShiftAtPositionX:-_flyoverParameters.endPosition.x andY:-_flyoverParameters.endPosition.y andViewAngle:_flyoverController.viewAngle];
                double viewShift = _flyoverParameters.startViewShift + (endViewShift - _flyoverParameters.startViewShift) * _flyoverController.getCompletePercentage;
                
                if (_flyoverController.getAnimationState == AnimationStateTiltGreencenter || _flyoverController.getAnimationState == AnimationStateWaitForFinish) {
                    double extraZDiff = _extraZstartTitling - (viewShift / sin([VectorMath deg2radWithDeg:_viewAngle]));
                    _z = _flyoverController.zoom + (extraZDiff);
                } else {
                    _z = _flyoverController.zoom;
                }
                
                Vector* position = [[Vector alloc] initWithX:-_flyoverController.position.x andY:-_flyoverController.position.y];
                Vector* sPosition = [self getShiftedPositionForPosition:position andViewShift:viewShift andRotationAngle:_rotationAngle];
                
                _x = sPosition.x;
                _y = sPosition.y;
                
                [_grid setCurrentTileWithPosition:position andCamera:self];
            }
            
            if (_flyoverController.finished) {
                _flyoverController = nil;
                
                if ([delegate respondsToSelector:NSSelectorFromString(@"cameraFlyoverFinished")])
                    [delegate cameraFlyoverFinished];
                
            }
            
        } else if (_navigationMode == NavigationModeFlyoverPause || _navigationMode == NavigationModeOverallHole || _navigationMode == NavigationModeFreeCam || _navigationMode == NavigationMode3DGreenView) {
            
            double averageViewShift = [self getAverageViewShiftAtCurrentPoint];
            Vector* position = [[Vector alloc] initWithX:_x + _xGesturePan - cos([VectorMath deg2radWithDeg:(90 + _rotationAngle + _gestureRotation)]) * averageViewShift
                                                    andY:_y + _yGesturePan + sin([VectorMath deg2radWithDeg:(90 + _rotationAngle + _gestureRotation)]) * averageViewShift
                                ];
            
            [_grid setCurrentTileWithPosition:position andCamera:self];
            
        } else if ((self.navigationMode == NavigationMode2DView) && _lastZoomDate != nil) {
            if (_callouts.hasFocus || _gestureRotation != 0 || _gestureZoom != 0 || _gesturePan.x != 0 || _gesturePan.y != 0) {
                _lastZoomDate = [NSDate new];
            }
            
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                [self calculateAutozoomWithInitialZoom:NO];
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        } else if (self.navigationMode == NavigationModeFreeCam && _lastZoomDate != nil) {
            
            if (_gestureRotation != 0 || _gestureZoom != 0 || _gesturePan.x != 0 || _gesturePan.y != 0) {
                _lastZoomDate = [NSDate new];
            }
            
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                [self update3DFreeCamPosition];
                
                _lastZoomDate = nil;
                
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        } else if (self.navigationMode == NavigationMode3DGreenView && _lastZoomDate != nil) {
            
            if (_gestureRotation != 0 || _gestureZoom != 0 || _gesturePan.x != 0 || _gesturePan.y != 0) {
                _lastZoomDate = [NSDate new];
            }
            
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                
                [self apply3DGreenView];
                _lastZoomDate = nil;
                
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        } else if (self.navigationMode == NavigationMode2DGreenView && _lastZoomDate != nil) {
            
            if (_gestureRotation != 0 || _gestureZoom != 0 || _gesturePan.x != 0 || _gesturePan.y != 0) {
                _lastZoomDate = [NSDate new];
            }
            
            double timeInterval = [[NSDate new] timeIntervalSinceDate:_lastZoomDate];
            
            if (timeInterval > [Camera autoZoomPeriod] && _isAutozoomActive == true) {
                
                [self apply2DGreenView];
                self->_lastZoomDate = nil;
                
                if (withCallback) {
                    if ([delegate respondsToSelector:NSSelectorFromString(@"cameraRequiresDraw")])
                        [delegate cameraRequiresDraw];
                }
            }
        }
    }
}

-(Vector*)getShiftedPositionForCurrentCameraPoint {
    
    return [self getShiftedPositionForPosition:[[Vector alloc]initWithX:self.x andY:self.y] andViewShift:[self getViewShiftAtPositionX:self.x andY:self.y andViewAngle:_viewAngle] andRotationAngle:self.rotationAngle];
}

-(Vector*)getShiftedPositionForPosition:(Vector*)position andViewShift:(double)viewShift andRotationAngle:(double)rotationAngle {
    
    return [[Vector alloc] initWithX:position.x + cos([VectorMath deg2radWithDeg:(90 + rotationAngle)]) * viewShift
                                andY:position.y - sin([VectorMath deg2radWithDeg:(90 + rotationAngle)]) * viewShift
            ];
}

-(double)getViewShiftAtPositionX:(double)x andY:(double)y andViewAngle:(double)viewAngle {
    return ([_grid getZForPointX:x andY:y] * tan([VectorMath deg2radWithDeg:viewAngle]));
}

- (GLKMatrix4)makeProjectionMatrixWithView:(UIView*)view andRenderViewWidthPercent:(float) renderViewWidthPercent {
    
    double zNear = 0.1;
    double zFar = 5000.0;
    double aspect = fabs(view.bounds.size.width*renderViewWidthPercent / view.bounds.size.height);
    double fovy = 45.0;
    double top = zNear * tan(fovy * M_PI/360.0);
    double bottom = -top;
    double left = bottom * aspect;
    double right = top * aspect;
    
    return GLKMatrix4MakeFrustum(left, right, bottom, top, zNear, zFar);
}

- (void)apply2DView {
    self->_viewAngle = 0;
    [self calculateAutozoomWithInitialZoom:YES];
}

- (void)apply2DGreenView {
    
    _viewAngle = 0;
    
    Vector* startPosition = _rotateHoleOnLocationChanged ? _frontGreenMarker.markerPosition : _frontGreenMarker.markerOriginalPosition;
    Vector* endPosition = _rotateHoleOnLocationChanged ? _backGreenMarker.markerPosition : _backGreenMarker.markerOriginalPosition;
    
    if(_rotateHoleOnLocationChanged){
        Vector* userPositionVector = [[Vector alloc] initWithX:[Layer transformLonFromDouble:_location.coordinate.longitude] andY:[Layer transformLatFromDouble:_location.coordinate.latitude]];
        Vector* endPositionVector = _centralPath.pointList.firstObject.pointList.lastObject;
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:userPositionVector andEndPos:endPositionVector];
    }else {
        
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:startPosition andEndPos:endPosition];
    }
    
    
    Vector* position = [[VectorMath addedWithVector1:startPosition
                                          andVector2:endPosition]
                        multipliedWithFactor:0.5];
    
    
    self.x = -position.x;
    self.y = -position.y;
    
    double zPosition = self.FreeCamZPos;
    
    for (_z = 0 ; _z > -200 ; _z -= 0.1f) {
        
        self.z = _z;
        
        GLKMatrix4 mvm = GLKMatrix4Identity;
        mvm = GLKMatrix4Translate(mvm, 0, 0, _z);
        mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:-_viewAngle], 1, 0, 0);
        mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:_rotationAngle], 0, 0, 1);
        mvm = GLKMatrix4Translate(mvm, self.x, self.y, 0);
        
        [_frustum updateFrustrumWithModelviewMatrix:mvm andProjectionMatrix:self.projectionMatrix];
        
        if ([_greenLayer isInFrustum:_frustum withGrid:_grid]) {
            zPosition = _z + (-1.66);
            break;
        }
    }
    
    self.z = zPosition;
}

/*
 - (void)apply3DView {
 
 
 Vector* start;
 Vector* end;
 
 Vector* flagPosition = [[Vector alloc] initWithX:_callouts.endLocation.x
 andY:_callouts.endLocation.y
 andZ:[_grid getZForPointX:-_callouts.endLocation.x andY:-_callouts.endLocation.y]
 ];
 Vector* startLocation = [[Vector alloc] initWithX:_centralPath.pointList.firstObject.pointList.firstObject.x
 andY:_centralPath.pointList.firstObject.pointList.firstObject.y
 andZ:[_grid getZForPointX:-_centralPath.pointList.firstObject.pointList.firstObject.x andY:-_centralPath.pointList.firstObject.pointList.firstObject.y]
 ];
 
 start = startLocation;
 end = flagPosition;
 
 if (_parValue != 3) {
 Vector* farPoint;
 Vector* nearPoint;
 
 double maxDistance = [_fairwayPointListLayer.pointList.firstObject.pointList.firstObject distanceWithVector:flagPosition];
 double minDistance = [_fairwayPointListLayer.pointList.firstObject.pointList.firstObject distanceWithVector:flagPosition];
 
 if (_fairwayPointListLayer != nil) {
 for (PointList* pointList in _fairwayPointListLayer.pointList) {
 for (Vector* point in pointList.pointList) {
 double distance = [point distanceWithVector:flagPosition];
 
 if (farPoint == nil) {
 farPoint = point;
 nearPoint = point;
 maxDistance = distance;
 minDistance = distance;
 continue;
 }
 
 if (distance > maxDistance) {
 farPoint = point;
 maxDistance = distance;
 }
 
 if (distance < minDistance) {
 nearPoint = point;
 minDistance = distance;
 }
 }
 }
 }
 
 if (farPoint != nil && nearPoint != nil) {
 start = [[Vector alloc] initWithX:farPoint.x
 andY:farPoint.y
 andZ:[_grid getZForPointX:-farPoint.x andY:-farPoint.y]
 ];
 end = [[Vector alloc] initWithX:nearPoint.x
 andY:nearPoint.y
 andZ:[_grid getZForPointX:-nearPoint.x andY:-nearPoint.y]
 ];
 }
 [self setCameraPositionWithStartPosition:start andEndPosition:end andDefaultZoom:-3 andViewAngle:self.overallHoleViewAngle andExtraOffset:-0.5 usingCondition:^BOOL{
 return ([_frustum isVectorVisible:start] && [_frustum isVectorVisible:end] && [_greenLayer isInFrustum:_frustum withGrid:_grid]);
 }];
 } else {
 
 if (_teeBoxLayer != nil) {
 start = [[Vector alloc] initWithX:_teeBoxLayer.centroid.x
 andY:_teeBoxLayer.centroid.y
 andZ:[_grid getZForPointX:-_teeBoxLayer.centroid.x andY:-_teeBoxLayer.centroid.x]
 ];
 [self setCameraPositionWithStartPosition:start andEndPosition:end andDefaultZoom:-3 andViewAngle:self.overallHoleViewAngle andExtraOffset:0.0 usingCondition:^BOOL{
 return ([_teeBoxLayer isInFrustum:_frustum withGrid:_grid] && [_greenLayer isInFrustum:_frustum withGrid:_grid]);
 }];
 } else {
 [self setCameraPositionWithStartPosition:start andEndPosition:end andDefaultZoom:-3 andViewAngle:self.overallHoleViewAngle andExtraOffset:0.0 usingCondition:^BOOL{
 return ([_frustum isVectorVisible:start] && [_frustum isVectorVisible:end]);
 }];
 }
 }
 _overalHoleZposition = self.z;
 }
 
 */
- (void)applyOverallHole {
    
    if (_parValue == 0) {
        
        Vector* start = self->_centralPath.pointList.firstObject.pointList.firstObject;
        Vector* end = self->_centralPath.pointList.firstObject.pointList.lastObject;
        
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:start andEndPos:end];
        self->_viewAngle = self.overallHoleViewAngle;
        self->_lastZoomDate = nil;
        
        self->_x = -start.x + cos([VectorMath deg2radWithDeg:90 + _rotationAngle]) * _flyoverParameters.endViewShift;
        self->_y = -start.y - sin([VectorMath deg2radWithDeg:90 + _rotationAngle]) * _flyoverParameters.endViewShift;
        self->_z = -5 - _flyoverParameters.holeAltitude;
        self->_overalHoleZposition = -5;
        return;
    }
    
    Vector* farPoint;
    Vector* nearPoint;
    Vector* flagLocationVector = _callouts.endLocation;
    
    double maxDistance = 0;
    double minDistance = 0;
    
    if (_fairwayPointListLayer != nil) {
        for (PointList* pointList in _fairwayPointListLayer.pointList) {
            for (Vector* point in pointList.pointList) {
                double distance = [point distanceWithVector:flagLocationVector];
                
                if (farPoint == nil) {
                    farPoint = point;
                    nearPoint = point;
                    maxDistance = distance;
                    minDistance = distance;
                    continue;
                }
                
                if (distance > maxDistance) {
                    farPoint = point;
                    maxDistance = distance;
                }
                
                if (distance < minDistance) {
                    nearPoint = point;
                    minDistance = distance;
                }
            }
        }
    }
    
    ParViewConfig* config = _parZoomLevels[@(_parValue)];
    if (config == nil) {
        config = _parZoomLevels[@(0)];
    }
    
    Vector* overallCameraPoint;
    
    if (_parValue == 3) {
        Vector* start = _centralPath.pointList.firstObject.pointList.firstObject;
        Vector* end = _centralPath.pointList.firstObject.pointList.lastObject;
        overallCameraPoint = [[[end substractedWithVector:start] multipliedWithFactor:0.2] addedWithVector:start];
        self.z = config.zoomTeeBox - _flyoverParameters.holeAltitude;
        _overalHoleZposition = config.zoomTeeBox;
    } else if (farPoint == nil && nearPoint == nil) {
        Vector* start = _centralPath.pointList.firstObject.pointList.firstObject;
        Vector* end = _callouts.endLocation;
        overallCameraPoint = [[[end substractedWithVector:start] multipliedWithFactor:config.advanceFairway] addedWithVector:start];
        
        self.z = config.zoomTeeBox - _flyoverParameters.holeAltitude;
        _overalHoleZposition = config.zoomTeeBox;
    } else {
        overallCameraPoint = [[[[nearPoint substractedWithVector:farPoint] normalized]multipliedWithFactor:config.advanceFairway] addedWithVector:farPoint];
        self.z = config.zoomFairway - _flyoverParameters.holeAltitude;
        
        _overalHoleZposition = config.zoomFairway;
    }
    
    self.viewAngle = self.overallHoleViewAngle;
    self.rotationAngle = [self calculateRotationAngleWithStartPos:_centralPath.pointList.firstObject.pointList.firstObject andEndPos:_centralPath.pointList.firstObject.pointList.lastObject];
    
    self.x = -overallCameraPoint.x + cos([VectorMath deg2radWithDeg:90 + _rotationAngle]) * [self getViewShiftAtPositionX:-overallCameraPoint.x andY:-overallCameraPoint.y andViewAngle:_viewAngle];
    self.y = -overallCameraPoint.y - sin([VectorMath deg2radWithDeg:90 + _rotationAngle]) * [self getViewShiftAtPositionX:-overallCameraPoint.x andY:-overallCameraPoint.y andViewAngle:_viewAngle];
}


- (void)apply3DGreenView {
    
    Vector* startPosition = _rotateHoleOnLocationChanged ? _frontGreenMarker.markerPosition : _frontGreenMarker.markerOriginalPosition;
    Vector* endPosition = _rotateHoleOnLocationChanged ? _backGreenMarker.markerPosition : _backGreenMarker.markerOriginalPosition;
    
    if(_rotateHoleOnLocationChanged){
        
        Vector* userPositionVector = [[Vector alloc] initWithX:[Layer transformLonFromDouble:_location.coordinate.longitude] andY:[Layer transformLatFromDouble:_location.coordinate.latitude]];
        Vector* endPositionVector = _centralPath.pointList.firstObject.pointList.lastObject;
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:userPositionVector andEndPos:endPositionVector];
    }else {
        
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:startPosition andEndPos:endPosition];
    }
    
    
    self->_viewAngle = 50.0;
    
    [self setCameraPositionWithStartPosition:startPosition andEndPosition:endPosition andDefaultZoom:-3 andViewAngle:self.overallHoleViewAngle andExtraOffset:-0.5 andCalculateRotationAngle:false usingCondition:^BOOL{
        return ([_greenLayer isInFrustum:_frustum withGrid:_grid]);
    }];
}

- (void)update3DGreenViewRotation {
    
    Vector* startPosition = _rotateHoleOnLocationChanged ? _frontGreenMarker.markerPosition : _frontGreenMarker.markerOriginalPosition;
    Vector* endPosition = _rotateHoleOnLocationChanged ? _backGreenMarker.markerPosition : _backGreenMarker.markerOriginalPosition;
    
    if(_rotateHoleOnLocationChanged){
        Vector* userPositionVector = [[Vector alloc] initWithX:[Layer transformLonFromDouble:_location.coordinate.longitude] andY:[Layer transformLatFromDouble:_location.coordinate.latitude]];
        Vector* endPositionVector = _centralPath.pointList.firstObject.pointList.lastObject;
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:userPositionVector andEndPos:endPositionVector];
    }else {
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:startPosition andEndPos:endPosition];
    }
    
}

- (void)update2DGreenViewRotation {
    Vector* startPosition = _frontGreenMarker.markerPosition;
    Vector* endPosition = _backGreenMarker.markerPosition;
    
    self->_rotationAngle = [self calculateRotationAngleWithStartPos:startPosition andEndPos:endPosition];
}


-(void)restartZNormalizer {
    if (_zNormalizer.count > 0)
        [_zNormalizer removeAllObjects];
}

- (double)calculateGreenViewZpositionWithExtraZ:(double)extraZ andRotationAngle:(double)rotationAngle{
    
    Vector* endPos = _centralPath.pointList.firstObject.pointList.lastObject;
    
    self.viewAngle = self.flyoverViewAngle - 10;
    self.rotationAngle = rotationAngle;
    
    double endAlt = [_grid getZForPointX:-endPos.x andY:-endPos.y];
    double altZoom = endAlt / cos([VectorMath deg2radWithDeg:_flyoverViewAngle]);
    double viewShift = [self getViewShiftAtPositionX:-endPos.x andY:-endPos.y andViewAngle:self.viewAngle];
    
    double retval = self.FlyoverZPos * 0.68 - altZoom - extraZ;
    
    Vector* position = [[Vector alloc] initWithX:-endPos.x andY:-endPos.y];
    Vector* sPosition = [self getShiftedPositionForPosition:position andViewShift:viewShift andRotationAngle:self.rotationAngle];
    
    _x = sPosition.x;
    _y = sPosition.y;
    
    for (_z = 0 ; _z > -200 ; _z -= 0.1f) {
        
        self.z = _z;
        
        GLKMatrix4 mvm = GLKMatrix4Identity;
        mvm = GLKMatrix4Translate(mvm, 0, 0, _z);
        mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:-(self.flyoverViewAngle - 10)], 1, 0, 0);
        mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:rotationAngle], 0, 0, 1);
        mvm = GLKMatrix4Translate(mvm, sPosition.x, sPosition.y, 0);
        
        [_frustum updateFrustrumWithModelviewMatrix:mvm andProjectionMatrix:self.projectionMatrix];
        
        if ([_greenLayer isInFrustum:_frustum withGrid:_grid]) {
            retval = _z - extraZ - 0.5;
            break;
        }
    }
    
    return retval;
}

- (void)setCameraPositionWithStartPosition:(Vector*)startPosition
                            andEndPosition:(Vector*)endPosition
                            andDefaultZoom:(double)defaultZoom
                              andViewAngle:(double)viewAngle
                            andExtraOffset:(double)offset
                            andCalculateRotationAngle:(BOOL) calculateRotationAngle
                            usingCondition:(BOOL (^)(void))condition{
    
    
    
    if(calculateRotationAngle){
        self->_rotationAngle = [self calculateRotationAngleWithStartPos:startPosition andEndPos:endPosition];
    }
    self->_viewAngle = viewAngle;
    
    
    Vector* position = [[VectorMath addedWithVector1:startPosition
                                          andVector2:endPosition]
                        multipliedWithFactor:0.5];
    Vector* startPos = [[Vector alloc] initWithX:startPosition.x
                                            andY:startPosition.y
                                            andZ:[_grid getZForPointX:-startPosition.x
                                                                 andY:-startPosition.y]];
    Vector* endPos = [[Vector alloc] initWithX:endPosition.x
                                          andY:endPosition.y
                                          andZ:[_grid getZForPointX:-endPosition.x
                                                               andY:-endPosition.y]];
    
    double fovy = 45.0;
    
    double angleA = ((180.0 - fovy) / 2.0) + (90.0 - _viewAngle);
    double angleB = ((180.0 - fovy) / 2.0) - (90.0 - _viewAngle);
    
    double distance = [VectorMath distanceWithVector1:startPos andVector2:endPos];
    
    double distanceA = distance * sin([VectorMath deg2radWithDeg:angleB]) / sin([VectorMath deg2radWithDeg:fovy]);
    double distanceB = distance * sin([VectorMath deg2radWithDeg:angleA]) / sin([VectorMath deg2radWithDeg:fovy]);
    
    double aspect = 1.0 - distanceA / distanceB;
    
    Vector* shiftedPosition = [[Vector alloc] initWithX:position.x + cos([VectorMath deg2radWithDeg:90 + _rotationAngle]) * (aspect * distance) * 0.8
                                                   andY:position.y - sin([VectorMath deg2radWithDeg:90 + _rotationAngle]) * (aspect * distance) * 0.8];
    
    
    self.x = -shiftedPosition.x + cos([VectorMath deg2radWithDeg:90 + _rotationAngle]) * [self getViewShiftAtPositionX:-shiftedPosition.x andY:-shiftedPosition.y andViewAngle:_viewAngle];
    self.y = -shiftedPosition.y - sin([VectorMath deg2radWithDeg:90 + _rotationAngle]) * [self getViewShiftAtPositionX:-shiftedPosition.x andY:-shiftedPosition.y andViewAngle:_viewAngle];
    
    double zPosition = self.FreeCamZPos;
    
    for (_z = 0 ; _z > -200 ; _z -= 0.1f) {
        
        self.z = _z;
        
        GLKMatrix4 mvm = GLKMatrix4Identity;
        mvm = GLKMatrix4Translate(mvm, 0, 0, _z);
        mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:-_viewAngle], 1, 0, 0);
        mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:_rotationAngle], 0, 0, 1);
        mvm = GLKMatrix4Translate(mvm, self.x, self.y, 0);
        
        [_frustum updateFrustrumWithModelviewMatrix:mvm andProjectionMatrix:self.projectionMatrix];
        
        if (condition()) {
            zPosition = _z + offset;
            break;
        }
    }
    
    self.z = zPosition;
    
}


- (void)apply3DFreeCamMode {
    
    BOOL isFirstinterpolation = true;
    
    double maxDistance = 0.0;
    Vector* maxVector;
    Vector* flagVector = _callouts.endLocation;
    
    if (_parValue > 3 && _fairwayPointListLayer != nil) {
        for (PointList* list in _fairwayPointListLayer.pointList) {
            for (Vector* v in list.pointList) {
                if (isFirstinterpolation) {
                    
                    isFirstinterpolation = false;
                    maxDistance          = [VectorMath distanceWithVector1:flagVector andVector2:v];
                    maxVector            = v;
                    
                } else {
                    
                    double distance = [VectorMath distanceWithVector1:flagVector andVector2:v];
                    
                    if (distance > maxDistance) {
                        maxVector   = v;
                        maxDistance = distance;
                    }
                }
            }
        }
        
        maxVector.z = [_grid getZForPointX:-maxVector.x andY:-maxVector.y];
        
        [self restartZNormalizer];
        
        [self setCameraPositionWithStartPosition:maxVector
                                  andEndPosition:_callouts.endLocation
                                  andDefaultZoom:self.FreeCamZPos
                                    andViewAngle:_freeCamViewAngle
                                  andExtraOffset: -0.5
                                  andCalculateRotationAngle:true
                                  usingCondition:^BOOL{
                                      return ([_frustum isVectorVisible:maxVector] && [_greenLayer isInFrustum:_frustum withGrid:_grid]);
                                  }];
        _overalHoleZposition = self.z;
        if (_lastZoomDate == nil) {
            [self->_lineToFlag resetPosition];
        }
        self->_lastZoomDate = nil;
        
    } else if (_parValue <= 3 && _frontGreenMarker != nil  && _backGreenMarker != nil) {
        [self restartZNormalizer];
        
        [self setCameraPositionWithStartPosition:_frontGreenMarker.markerPosition
                                  andEndPosition:_backGreenMarker.markerPosition
                                  andDefaultZoom:self.FreeCamZPos
                                    andViewAngle:_freeCamViewAngle
                                  andExtraOffset: -1.66
                       andCalculateRotationAngle:true
                                  usingCondition:^BOOL{
                                      return ([_greenLayer isInFrustum:_frustum withGrid:_grid]);
                                  }];
        _overalHoleZposition = self.z;
        if (_lastZoomDate == nil) {
            [self->_lineToFlag resetPosition];
        }
        self->_lastZoomDate = nil;
    } else {
        for (PointList* list in _perimeterPointListLayer.pointList) {
            for (Vector* v in list.pointList) {
                if (isFirstinterpolation) {
                    
                    isFirstinterpolation = false;
                    maxDistance          = [VectorMath distanceWithVector1 :flagVector andVector2:v];
                    maxVector            = v;
                    
                } else {
                    
                    double distance = [VectorMath distanceWithVector1:flagVector andVector2:v];
                    
                    if (distance > maxDistance) {
                        maxVector   = v;
                        maxDistance = distance;
                    }
                }
            }
        }
        
        [self restartZNormalizer];
        
        [self setCameraPositionWithStartPosition:maxVector
                                  andEndPosition:_callouts.endLocation
                                  andDefaultZoom:self.FreeCamZPos
                                    andViewAngle:_freeCamViewAngle
                                  andExtraOffset: -0.5
                                  andCalculateRotationAngle:true
                                  usingCondition:^BOOL{
                                      
                                      return ([_perimeterPointListLayer isInFrustum:_frustum withGrid:_grid] && [_greenLayer isInFrustum:_frustum withGrid:_grid]);
                                  }];
        _overalHoleZposition = self.z;
        if (_lastZoomDate == nil) {
            [self->_lineToFlag resetPosition];
        }
        self->_lastZoomDate = nil;
    }
    
}

-(void)applyFreecamGreenView {
    
    [self restartZNormalizer];
    
    [self setCameraPositionWithStartPosition:_frontGreenMarker.markerPosition
                              andEndPosition:_backGreenMarker.markerPosition
                              andDefaultZoom:self.FreeCamZPos
                                andViewAngle:_freeCamViewAngle
                              andExtraOffset: -1.66
                   andCalculateRotationAngle:true
                              usingCondition:^BOOL{
                                  return ([_greenLayer isInFrustum:_frustum withGrid:_grid]);
                              }];
    _overalHoleZposition = self.z;
    if (_lastZoomDate == nil) {
        [self->_lineToFlag resetPosition];
    }
    self->_lastZoomDate = nil;
}


- (void)update3DGreenViewPosition {
    
    if (_lastZoomDate == nil) {
        [self apply3DGreenView];
        [self->_lineToFlag resetPosition];
    }

}

- (void)update2DGreenViewPosition {

    if (_lastZoomDate == nil) {
        [self apply2DGreenView];
    
    }
}

- (void)update2DPosition {
    
    if (_lastZoomDate == nil) {
        self->_viewAngle = 0;
        [self calculateAutozoomWithInitialZoom:false];
    }
}

- (void)update3DFreeCamPosition {
    
    if (_lastZoomDate != nil) {
        return;
    }
    
    Vector* userPositionVector = [[Vector alloc] initWithX:[Layer transformLonFromDouble:_location.coordinate.longitude] andY:[Layer transformLatFromDouble:_location.coordinate.latitude]];
    
    double distance = [_location distanceFromLocation:_callouts.endPointLocation];
    
    
    if (distance > 999.0) {
        return;
    } else if (distance < 151.0 && _parValue > 3 && _frontGreenMarker != nil  && _backGreenMarker != nil) {
        [self applyFreecamGreenView];
        return;
    } else if (_parValue <= 3) {
        [self applyFreecamGreenView];
        return;
    }
    
    if (!_enteredFairway && _parValue > 3) {
        if (_lastZoomDate == nil) {
            [self apply3DFreeCamMode];
        }
        return;
    }
    
    
    if (![userPositionVector isEqualToVector:_callouts.endLocation]) {
        [self apply3DFreeCamMode];
        //        return;
    }
    
    [self restartZNormalizer];
    
    
    Vector* startPos = [[Vector alloc] initWithX:_callouts.startLocation.x
                                            andY:_callouts.startLocation.y
                                            andZ:[_grid getZForPointX:-_callouts.startLocation.x
                                                                 andY:-_callouts.startLocation.y]];
    
    [self setCameraPositionWithStartPosition:_callouts.startLocation
                              andEndPosition:_callouts.endLocation
                              andDefaultZoom:self.FreeCamZPos
                                andViewAngle:_freeCamViewAngle
                              andExtraOffset: -0.5
                            andCalculateRotationAngle:true
                              usingCondition:^BOOL{
                                  
                                  return ([_frustum isVectorVisible:startPos] && [_greenLayer isInFrustum:_frustum withGrid:_grid]);
                              }];
    _overalHoleZposition = self.z;
    self->_lastZoomDate = nil;
}

- (NSArray<Vector*>*)unprojectViewport {
    NSMutableArray<Vector*>* retval = [NSMutableArray new];
    
    Vector* a = [self unprojectWithTouchPoint:CGPointMake(_viewportXOffset, 0)];
    Vector* b = [self unprojectWithTouchPoint:CGPointMake(_viewport.size.width+_viewportXOffset, 0)];
    Vector* c = [self unprojectWithTouchPoint:CGPointMake(_viewport.size.width+_viewportXOffset, _viewport.size.height)];
    Vector* d = [self unprojectWithTouchPoint:CGPointMake(_viewportXOffset, _viewport.size.height)];
    
    if (a != nil && b != nil && c != nil && d != nil) {
        [retval addObject:[self unprojectWithTouchPoint:CGPointMake(_viewportXOffset, 0)]];
        [retval addObject:[self unprojectWithTouchPoint:CGPointMake(_viewport.size.width+_viewportXOffset, 0)]];
        [retval addObject:[self unprojectWithTouchPoint:CGPointMake(_viewport.size.width+_viewportXOffset, _viewport.size.height)]];
        [retval addObject:[self unprojectWithTouchPoint:CGPointMake(+_viewportXOffset, _viewport.size.height)]];
    } else {
        return nil;
    }
    
    return retval;
}

- (void)calculateAutozoomWithInitialZoom:(BOOL)initial {
    
    Vector* startPos;
    Vector* endPos;
    if (_rotateHoleOnLocationChanged){
        startPos =  _callouts.startLocation;
        endPos =  _callouts.endLocation;
    } else {
        startPos = _centralPath.pointList.firstObject.pointList.firstObject;
        endPos =  _centralPath.pointList.firstObject.pointList.lastObject;
    }
    
    self.rotationAngle = [self calculateRotationAngleWithStartPos:startPos andEndPos:endPos];
    
    Vector* position;

    if (_rotateHoleOnLocationChanged || _perimeterLayer == nil) {
        position = [[startPos addedWithVector:endPos] multipliedWithFactor:0.5];
    } else {
        NSArray<Vector*>* leftRightLocations = [VectorMath findLeftAndRightSides:startPos andLineEnd:endPos andRectangleCorners:[_perimeterLayer getExtremeBox]];

        double rotation = [VectorMath angleBetweenTwoLines:startPos and:endPos and:leftRightLocations[0] and:leftRightLocations[1]];
        position = [_perimeterLayer getRotatedLayerCenterWithPivot:[_perimeterLayer getCenter] andAngleDegrees:-rotation];
    }
    
    
    self.x = -position.x;
    self.y = -position.y;
    
    int zoom = self.MinZ2D;
    
    if(_rotateHoleOnLocationChanged || _perimeterLayer == nil){
        float threshold = 0.9;
        while (zoom > self.MaxZ2D) {
            self.z = zoom;
            
            Vector* projectedStart = [self projectWithVector:startPos];
            Vector* projectedEnd = [self projectWithVector:endPos];
            
            if (fabs(projectedStart.y) < threshold && fabs(projectedEnd.y) < threshold) {
                break;
            }
            
            zoom -= 1;
        }
        
        if (zoom <= self.MaxZ2D) {
            int i = 0;
            const int maxOffset = 100;
            for (i = 0 ; i < maxOffset ; i++) {
                Vector* adjustmentVector = [[[[startPos substractedWithVector:position] normalized] multipliedWithFactor:i] addedWithVector:position];
                self.x = -adjustmentVector.x;
                self.y = -adjustmentVector.y;
                
                Vector* projectedStart = [self projectWithVector:startPos];
                if (fabs(projectedStart.y) < threshold) {
                    break;
                }
            }
            
            if (i == maxOffset) {
                self.x = -startPos.x;
                self.y = -startPos.y;
            }
        }
    } else {
        while (zoom > self.MaxZ2D) {
            self.z = zoom;
                
            GLKMatrix4 mvm = GLKMatrix4Identity;
            mvm = GLKMatrix4Translate(mvm, 0, 0, _z);
            mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:-0], 1, 0, 0);
            mvm = GLKMatrix4Rotate(mvm, [VectorMath deg2radWithDeg:_rotationAngle], 0, 0, 1);
            mvm = GLKMatrix4Translate(mvm, self.x, self.y, 0);
            
            [_frustum updateFrustrumWithModelviewMatrix:mvm andProjectionMatrix:self.projectionMatrix];
            
            if ([_perimeterLayer isInFrustum:_frustum withGrid:_grid]) {
                break;
            }
            zoom -= 1;
            
        }
    }
    
    [self->_callouts resetPosition];
}

- (void)applyZoomWithCustomTapPoint:(CGPoint)point {
    
    if (_navigationMode == NavigationMode2DView || _navigationMode == NavigationMode2DGreenView) {
        [self setGestureZoom:1.5];
        
        [self endZoom];
        
        Vector* vector = [self unprojectWithTouchPoint:point];
        
        _x = -vector.x;
        _y = -vector.y;
        self->_lastZoomDate = [NSDate new];
    }
    
}

-(void)updateLastZoomDate {
    self->_lastZoomDate = [NSDate date];
}

- (float)calculateRotationAngleWithStartPos:(Vector*)startPos andEndPos:(Vector*)endPos {
    
    Vector* middlePoint = startPos;
    Vector* startPoint = [[Vector alloc] initWithX:middlePoint.x andY:middlePoint.y + 1];
    Vector* endPoint = endPos;
    
    float rotationAngle = [VectorMath angleWithVector1:startPoint andVector2:middlePoint andVector3:endPoint];
    rotationAngle = [VectorMath rad2degWithRad:rotationAngle];
    
    if (endPoint.x < middlePoint.x) {
        rotationAngle *= -1;
    }
    
    return rotationAngle;
}

- (Vector*)projectAbsWithVector:(Vector*)position {
    
    Vector* retval = [self projectWithVector:position];
    
    retval.x = fabs(retval.x);
    retval.y = fabs(retval.y);
    
    return retval;
}

- (Vector*)calculateTouchPoint:(CGPoint)point {
    
    if (_grid != nil && _navigationMode != NavigationMode2DView && _navigationMode != NavigationMode2DGreenView) {
        
        Ray* ray = [[Ray alloc] initWithTouchX:point.x andTouchY:point.y andCamera:self];
        
        NSMutableArray<Vector*>* vectors = [NSMutableArray new];
        
        NSArray* tiles = [_grid getCurrentTiles];
        
        NSMutableArray<DrawTile*>* visibleTiles = [NSMutableArray new];
        
        for (DrawTile* tile in tiles) {
            
            NSArray<NSArray<Vector*>*>* vector2DList = [tile getVector2DList];
            
            for (NSArray<Vector*>* vectorList in vector2DList) {
                if ([_frustum isVectorListVisible:vectorList]) {
                    [visibleTiles addObject:tile];
                    break;
                }
            }
        }
        
        for (DrawTile* tile in visibleTiles) {
            NSArray* vertices = [tile getVertexArray];
            
            for (int y = 0; y <([vertices count] - 1); y++) {
                for (int x = 0; x < ([[vertices objectAtIndex:y] count] - 1); x++) {
                    Vertex* topLeft = [[vertices objectAtIndex:y] objectAtIndex:x];
                    Vertex* bottomLeft = [[vertices objectAtIndex:y + 1] objectAtIndex:x];
                    Vertex* bottomRight = [[vertices objectAtIndex:y + 1] objectAtIndex:x + 1];
                    Vertex* topRight = [[vertices objectAtIndex:y] objectAtIndex:x + 1];
                    
                    GLKVector4 surface[] = {
                        GLKVector4Make(topLeft.vector.x, topLeft.vector.y, topLeft.vector.z, 0), // top left
                        GLKVector4Make(bottomLeft.vector.x, bottomLeft.vector.y, bottomLeft.vector.z, 0), // bottom left
                        GLKVector4Make(bottomRight.vector.x, bottomRight.vector.y, bottomRight.vector.z, 0), // bottom right
                        GLKVector4Make(topLeft.vector.x, topLeft.vector.y, topLeft.vector.z, 0), // top left
                        GLKVector4Make(bottomRight.vector.x, bottomRight.vector.y, bottomRight.vector.z, 0), // bottom right
                        GLKVector4Make(topRight.vector.x, topRight.vector.y, topRight.vector.z, 0) // top right
                    };
                    
                    GLKVector4 resultVector;
                    GLKVector4 inputVector;
                    
                    GLKMatrix4 retval = GLKMatrix4Identity;
                    retval = GLKMatrix4Translate(retval, 0, 0, self.z);
                    retval = GLKMatrix4Rotate(retval, [VectorMath deg2radWithDeg:-self.viewAngle], 1, 0, 0);
                    retval = GLKMatrix4Rotate(retval, [VectorMath deg2radWithDeg:self.rotationAngle], 0, 0, 1);
                    retval = GLKMatrix4Translate(retval, self.x, self.y, 0);
                    
                    GLKMatrix4 modelViewMatrix = retval;
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
                            GLKVector4 unprojected = GLKMatrix4MultiplyVector4(self.intersectionUnprojectionMatrix, GLKVector4Make(intersectionPoint[0], intersectionPoint[1], intersectionPoint[2], intersectionPoint[3]));
                            Vector* v = [[Vector alloc] initWithX:unprojected.x andY:unprojected.y];
                            
                            [vectors addObject:v];
                        }
                    }
                }
            }
            
            if (vectors.count > 0) {
                Vector* cameraVector = [[Vector alloc] initWithX:-_x andY:-_y];
                Vector* nearest = [vectors objectAtIndex:0];
                double minDistance = ABS([VectorMath distanceWithVector1:cameraVector andVector2:nearest]);
                
                for (Vector* v in vectors) {
                    double distance = ABS([VectorMath distanceWithVector1:cameraVector andVector2:v]);
                    if (distance < minDistance) {
                        minDistance = distance;
                        nearest = v;
                    }
                }
                
                return nearest;
            }
        }
        return nil;
    } else {
        return [self unprojectWithTouchPoint:point];
        
    }
}

- (Vector*)unprojectWithTouchPoint:(CGPoint)point {
    Ray* ray = [[Ray alloc] initWithTouchX:point.x andTouchY:point.y andCamera:self];
    
    GLKVector4 surface[] = {
        GLKVector4Make(-5000, 5000, 0, 0), // top left
        GLKVector4Make(-5000, -5000, 0, 0), // bottom left
        GLKVector4Make(5000, -5000, 0, 0), // bottom right
        GLKVector4Make(-5000, 5000, 0, 0), // top left
        GLKVector4Make(5000, -5000, 0, 0), // bottom right
        GLKVector4Make(5000, 5000, 0, 0) // top right
    };
    
    GLKVector4 resultVector;
    GLKVector4 inputVector;
    
    GLKMatrix4 modelViewMatrix = self.modelViewMatrix;
    
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
            GLKVector4 unprojected = GLKMatrix4MultiplyVector4(self.intersectionUnprojectionMatrix, GLKVector4Make(intersectionPoint[0], intersectionPoint[1], intersectionPoint[2], intersectionPoint[3]));
            return [[Vector alloc] initWithX:unprojected.x andY:unprojected.y];
        }
    }
    
    return nil;
}

- (Vector*)projectWithVector:(Vector*)position {
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, self.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:-self.viewAngle], 1, 0, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, [VectorMath deg2radWithDeg:self.rotationAngle], 0, 0, 1);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, self.x + position.x, self.y + position.y, 0);
    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix);
    GLKVector4 projected = GLKMatrix4MultiplyVector4(modelViewProjectionMatrix, GLKVector4Make(0, 0, 0, 1));
    
    Vector* retval = [[Vector alloc] initWithX:projected.x / projected.w andY:projected.y / projected.w andZ: projected.z / projected.w];
    
    return retval;
}

- (Vector*)calculateFreeCamPosition {
    
    Vector* retval = nil;
    
    for (PointList* pointList in _centralPath.pointList) {
        NSArray<Vector*>* points = pointList.pointList;
        for (int i = 0 ; i < points.count - 1 ; i++) {
            retval = [VectorMath calculateProjectionPointWithPoint:self.callouts.startLocation andLinePoint1:points[i] andLinePoint2:points[i + 1]];
            if (retval != nil) {
                retval = [[[[self.callouts.endLocation substractedWithVector:retval] normalized] multipliedWithFactor:1.5] addedWithVector:retval];
                break;
            }
        }
    }
    
    if (retval == nil) {
        Vector* location = self.callouts.startLocation;
        Vector* first = [[_centralPath.pointList firstObject].pointList firstObject];
        Vector* last = [[_centralPath.pointList firstObject].pointList lastObject];
        double dfirst = [location distanceWithVector:first];
        double dlast = [location distanceWithVector:last];
        retval = dfirst < dlast ? first : last;
    }
    
    return retval;
}

- (double)normalizeZ:(double)newValue {
    
    [_zNormalizer addObject:@(newValue)];
    
    if (_zNormalizer.count > 7) {
        [_zNormalizer removeObjectAtIndex:0];
    }
    
    double sum = 0;
    
    for (NSNumber* value in _zNormalizer) {
        sum += [value doubleValue];
    }
    
    return sum / (double)_zNormalizer.count;
}

- (Vector*)getCameraProjectionPoint {
    return [self getCameraProjectionPointWithXGeturePan:_xGesturePan andYgesturePan:_yGesturePan andGestureRotation:_gestureRotation];
}

- (Vector*)getCameraProjectionPointWithXGeturePan:(double)xGesturePan andYgesturePan:(double)yGesturePan andGestureRotation:(double)gestureRotation {
    
    double cameraProjectionPointShift =  _z * cos([VectorMath deg2radWithDeg:180 - 90 - _viewAngle]);
    double cameraProjectionPointX = _x + xGesturePan + cos([VectorMath deg2radWithDeg:(90 + _rotationAngle + gestureRotation)]) * cameraProjectionPointShift;
    double cameraProjectionPointY = _y + yGesturePan - sin([VectorMath deg2radWithDeg:(90 + _rotationAngle + gestureRotation)]) * cameraProjectionPointShift;
    
    return [[Vector alloc] initWithX:cameraProjectionPointX andY:cameraProjectionPointY];
}


- (Vector *)cameraPoint {
    Vector* v = [self getCameraProjectionPoint];
    v.z = self.z * cos([VectorMath deg2radWithDeg:self.viewAngle]);
    return v;
}

- (void)setLocation:(CLLocation *)location {
    
    if (!_enteredFairway) {
        
        Vector* userPositionVector = [[Vector alloc] initWithX:[Layer transformLonFromDouble:_location.coordinate.longitude] andY:[Layer transformLatFromDouble:_location.coordinate.latitude]];
        
        if ([_fairwayPointListLayer containsWithVector:userPositionVector]) {
            _enteredFairway = true;
        }
    }
    
    _location = location;
}

-(CLLocation *)location {
    return _location;
}

-(NSString *)getProtectionCode {
    return _protectionCode;
}

- (void)setRotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged{
    _rotateHoleOnLocationChanged = rotateHoleOnLocationChanged;
//    NSLog(_navigationMode == nil ? @"_navigationMode nil" : @"navigation mode not nil" );
//    NSLog(@"setRotateHoleOnLocationChanged %lu= ",(unsigned long)_navigationMode);
    [self setNavigationMode:_navigationMode];
    
}

-(float) viewportXOffset {
    return _viewportXOffset;
}

@end
