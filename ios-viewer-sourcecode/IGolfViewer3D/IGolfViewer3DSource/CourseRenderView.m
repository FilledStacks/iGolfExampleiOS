//
//  CourseRenderView.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseRenderView.h"
#import <OpenGLES/ES3/gl.h>
#import "IGolfViewer3DPrivateImports.h"
#import "GreenViewCursor.h"
#import "GreenViewCursor.h"
#import <CoreText/CoreText.h>

static NSNotification* _navigationModeDidChangeNotification;
static NSNotification* _flyoverFinishedNotification;
static NSNotification* _flyoverFinishedNotification;
static NSNotification* _didLoadCourseDataNotification;
static NSNotification* _didLoadHoleDataNotification;
static NSNotification* _courseRenderViewReleasedNotification;
static CourseRenderView* _shared;

@interface CourseRenderView() <CameraDelegate> {
    
    Camera* _camera;
    
    int _holeIndex;
    double holeSetTimeStamp;
    
    NSDictionary* _gpsVectorData;
    NSArray* _gpsDetailsData;
    NSArray* _parData;
    
    NSMutableArray<NSObject<IDrawable>*>* _layerList;
    NSMutableArray<CartPath*>* _cartPathList;
    NSMutableArray<Tree*>* _treeList;
    NSMutableArray<DistanceMarker*>* _markerList;
    NSMutableArray<DistanceMarker*>* _markerListBeforeFlag;
    NSMutableArray<DistanceMarker*>* _markerListAfterFlag;
    NSMutableArray<CartPositionMarker*>* _cartPositionMarkerList;
    NSMutableArray<Bunker3D*>* _bunkerList;
    
    Layer* _perimeterLayer;
    Layer* _lakeBorderLayer;
    Layer* _lakeLayer;
    Layer* _lavaLayer;
    Layer* _oceanBorderLayer;
    Layer* _oceanLayer;
    Layer* _pondBorderLayer;
    Layer* _pondLayer;
    Layer* _waterBorderLayer;
    Layer* _waterLayer;
    Layer* _sandBorderLayer;
    Layer* _sandLayer;
    Layer* _bridgeLayer;
    Layer* _greenLayer;
    Layer* _teeBoxLayer;
    PointListLayer* _fairwayPointListLayer;

    NSDate *tapMarkerCreateDate;
    NSDate *startDrawDate;
    
    PointListLayer* _creekLayer;
    PointListLayer* _pathLayer;
    PointListLayer* _greenCenterLayer;
    PointListLayer* _treeLayer;
    PointListLayer* _centralPathLayer;
    
    NSMutableArray<PinMarker*>* _pinMarkerList;
    
    Flag* _flag;
    Cart* _cart;
    Ground* _groud;
    Sky* _skyGradient;
    Sky* _skyClouds;
    NSString* _idCourse;
    NSString* _referralAppKey;
    ElevationMap* _grid;
    
    NSMutableArray<DistanceMarker*>* _centralPathMarkers;
    DistanceMarker* _dogLegMarker;
    DistanceMarker* _frontGreenMarker;
    DistanceMarker* _backGreenMarker;
    DistanceMarker* _tapDistanceMarker;
    
    GreenViewCursor* _greenViewCursor;
    
    NavigationMode _initialNavigationMode;
    
    Callouts* _callouts;
    LineToFlag* _lineToFlag;
    
    BOOL _isCameraAutoZoomActive;
    BOOL _enableDrawing;
    BOOL _redraw;
    BOOL _isInvalidated;
    BOOL _shouldSendFlagScreenPointCoordinate;
    BOOL _isFlyoverAvailable;
    BOOL _isApplicationActive;
    BOOL _isCartMarkerVisible;
    BOOL _initialHoleLoad;
    BOOL _usesOverridedPinPosition;
    BOOL _usesEvergreenTreeTextureSet;
    BOOL _viewCartActive;
    BOOL _dataSourceChanged;
    BOOL _areFrontBackMarkersDynamic;
    BOOL _autoAdvanceActive;
    BOOL _rotateHoleOnLocationChanged;
    BOOL _drawDogLegMarker;
    BOOL _drawCentralPathMarkers;
    BOOL _cutLayersByHolePerimeter;
    BOOL _draw3DCentralPath;
    float _renderViewWidthPercent;
    
    NSMutableArray* _courseObjectsToDestroy;
    NSMutableArray* _holeObjectsToDestroy;
    NSMutableDictionary* _perimeterLayerCache;
    
    GLuint _textureVertexBuffer;
    GLuint _textureUVBuffer;
    
    GLuint _textureVertexBuffer3D;
    GLuint _textureUVBuffer3D;
    
    
    int _holeTreesCount;
    
    NSTimer* _timer;
    
    GLKBaseEffect* _effect;
    
    TextureType _textureType;
    TextureProfile* _textureProfile;
    
    PinPositionOverride* _pinPositionOverride;
    
    UIView* _timerView;
    UILabel* _timerLabel;
    
    NSUInteger _holeWithin;
    
    V3DRest* _rest;
    CourseRenderViewLoader* _loader;
    
    NSString* _viewerApiKey;
    NSString* _viewerSecretKey;
    
    UIView* _loadingView;

//    SiriVoice* _voice;
}


@property (nonatomic, readonly) double CalloutOverlapThreshold;

@end

@implementation CourseRenderView

@synthesize delegate;
@synthesize dataSource;


- (UIColor *)backgroundColor {
    return UIColor.blackColor;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.backgroundColor = UIColor.blackColor;
    if (self) {
        
        self->holeSetTimeStamp = 0;
        self->_renderViewWidthPercent = 1;
        self->_drawDogLegMarker                    = true;
        self->_drawCentralPathMarkers              = true;
        self->_enableDrawing                       = true;
        self->_redraw                              = true;
        self->_shouldSendFlagScreenPointCoordinate = false;
        self->_usesOverridedPinPosition            = false;
        self->_viewCartActive                      = false;
        self->_isCameraAutoZoomActive              = true;
        self->_isInvalidated                       = false;
        self->_dataSourceChanged                   = false;
        self->_usesEvergreenTreeTextureSet         = false;
        self->_overallHoleViewAngle                = 60;
        self->_freeCamViewAngle                    = 60;
        self->_holeWithin                          = 0;
        self->_areFrontBackMarkersDynamic          = true;
        self->_autoAdvanceActive                   = false;
        self->_rotateHoleOnLocationChanged         = false;
        self->_cutLayersByHolePerimeter            = false;
        self->_draw3DCentralPath                   = false;
        //      self->_greenViewViewAngle                  = 50;
        self->_flyoverViewAngle                    = 70;
        self->_textureType                         = TextureTypeMixedDesert;
        self->_textureProfile                      = [[TextureProfile alloc] initWithTextureType :_textureType];
        self->_layerList                           = [NSMutableArray new];
        self->_cartPathList                        = [NSMutableArray new];
        self->_treeList                            = [NSMutableArray new];
        self->_markerList                          = [NSMutableArray new];
        self->_markerListBeforeFlag                = [NSMutableArray new];
        self->_markerListAfterFlag                 = [NSMutableArray new];
        self->_holeObjectsToDestroy                = [NSMutableArray new];
        self->_courseObjectsToDestroy              = [NSMutableArray new];
        self->_cartPositionMarkerList              = [NSMutableArray new];
        self->_pinMarkerList                       = [NSMutableArray new];
        self->_centralPathMarkers                  = [NSMutableArray new];
        self->_viewerApiKey                        = @"";
        self->_viewerSecretKey                     = @"";
        
        UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureWithRegognizer:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
        UIPinchGestureRecognizer* pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureWithRecognizer:)];
        pinchGestureRecognizer.delegate = self;
        [self addGestureRecognizer:pinchGestureRecognizer];
        
        UIRotationGestureRecognizer* rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureWithRecognizer:)];
        rotationGestureRecognizer.delegate = self;
        [self addGestureRecognizer:rotationGestureRecognizer];
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureWithRegognizer:)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        UITapGestureRecognizer* doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureWithRegognizer:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        doubleTapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    _shared = self;
    
    glEnable(GL_SCISSOR_TEST);
    glScissor(0, 0, [self getCurrentWidth:false], [self getCurrentHeight]);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDisable(GL_SCISSOR_TEST);
    return self;
}

-(void) registerFontWithName:(NSString*) name {
    @try {
        NSURL *fontURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"ttf"];
        CFErrorRef error;
        if (fontURL) {
            CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error);
        }
    } @catch (NSException *exception) {
        NSLog(@"An exception occurred: %@", exception);
    }
}

-(UIFont*) getFontWithName:(NSString*) name {
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    UIFont* font = [UIFont fontWithName:fontPath size:40];
    return font;
}

-(void) getFontWithName2:(NSString*) name {
    UIFont* font = [UIFont fontWithName:name size:60];
}

-(void)viewCartWithGpsVectorData:(NSDictionary *)gpsVectorData {
    
    self->_textureType = [TextureProfile determineTextureTypeWithVectorData:gpsVectorData];
    self->_textureProfile = [[TextureProfile alloc] initWithTextureType:_textureType];
    
    NSArray *vertexList = @[
        @(-1.0), @(1.0), @(0.0),
        @(-1.0), @(-1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(-1.0), @(1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(1.0), @(1.0), @(0.0)
    ];
    
    NSArray *vertexList3D = @[
        @(-1.0), @(1.0), @(0.0),
        @(-1.0), @(-1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(-1.0), @(1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(1.0), @(1.0), @(0.0),
        
        @(0.0), @(1.0), @(-1.0),
        @(0.0), @(-1.0), @(-1.0),
        @(0.0), @(-1.0), @(1.0),
        @(0.0), @(1.0), @(-1.0),
        @(0.0), @(-1.0), @(1.0),
        @(0.0), @(1.0), @(1.0),
    ];
    
    NSArray *uvList3D = @[
        @(0.0), @(0.0),
        @(0.0), @(1.0),
        @(1.0), @(1.0),
        @(0.0), @(0.0),
        @(1.0), @(1.0),
        @(1.0), @(0.0),
        @(0.0), @(0.0),
        @(0.0), @(1.0),
        @(1.0), @(1.0),
        @(0.0), @(0.0),
        @(1.0), @(1.0),
        @(1.0), @(0.0),
    ];
    
    NSArray *uvList = @[
        @(0.0), @(0.0),
        @(0.0), @(1.0),
        @(1.0), @(1.0),
        @(0.0), @(0.0),
        @(1.0), @(1.0),
        @(1.0), @(0.0)
    ];
    
    self.measurementSystem = MeasurementSystemImperial;
    
    _textureVertexBuffer = [GLHelper getBuffer:vertexList];
    _textureUVBuffer = [GLHelper getBuffer:uvList];
    _textureVertexBuffer3D = [GLHelper getBuffer:vertexList3D];
    _textureUVBuffer3D = [GLHelper getBuffer:uvList3D];
    _initialHoleLoad = true;
    _gpsVectorData = gpsVectorData;
    _initialNavigationMode = NavigationMode2DView;
    _holeTreesCount = 0;
    _effect = [GLKBaseEffect new];
    _isApplicationActive = true;
    _viewCartActive = true;
    _isCameraAutoZoomActive = false;
    [self loadStaticData];
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)loadWithLoader:(CourseRenderViewLoader *)loader {
    NSLog(@"🚀 [IGolfViewer3D] loadWithLoader called, isPreloaded: %@", loader.isPreloaded ? @"YES" : @"NO");
    _loader = loader;
    if (_loader.isPreloaded) {
        NSLog(@"✅ [IGolfViewer3D] Course is preloaded, launching immediately");
        [self launchWithLoader:_loader];

    } else {
        NSLog(@"⏳ [IGolfViewer3D] Course not preloaded, starting preload...");
        _loadingView = loader.getLoadingView;
        
        if (_loadingView) {
            [self.superview addSubview:_loadingView];
            _loadingView.center = self.superview.center;
        }
        
        [_loader preloadWithCompletionHandler:^{
            NSLog(@"✅ [IGolfViewer3D] Preload completed successfully, launching course");
            if (_loadingView) {
                [_loadingView removeFromSuperview];
            }
            [self launchWithLoader:_loader];
        } errorHandler:^(NSError * _Nullable error) {
            NSLog(@"❌ [IGolfViewer3D] Preload FAILED with error: %@", error ? error.localizedDescription : @"nil error");
            if (_loadingView) {
                [_loadingView removeFromSuperview];
            }
            if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidFailWithError:")])
                [delegate courseRenderViewDidFailWithError:error];
        }];
    }
}

- (void)launchWithLoader:(CourseRenderViewLoader *)loader {
    NSLog(@"🏌️ [IGolfViewer3D] launchWithLoader called, about to load course with ID: %@", loader.idCourse);
    [self setRenderViewWidthPercent:1];
    NSArray* holes = nil;
    if (loader.coursePinPositionDetailsResponse && [loader.coursePinPositionDetailsResponse objectForKey:@"holes"]) {
        holes = [loader.coursePinPositionDetailsResponse valueForKey:@"holes"];
    }
    if (!holes) {
        holes = [NSArray array];
    }
    [self loadCourseWithId: loader.idCourse
            referralAppKey:loader.endpoint.applicationAPIKey
             gpsVectorData:[loader.courseGPSVectorDetailsResponse valueForKey:@"vectorGPSObject"]
            gpsDetailsData:[loader.courseGPSDetailsResponse valueForKey:@"GPSList"]
                   parData:[self getParHoleFromResponse:loader.courseScorecardDetailsResponse forMen:loader.isUserGenderMale]
             elevationData:loader.courseElevationDataDetails
              pinPositions:holes
            textureQuality:loader.textureQuality
          calloutsDrawMode:loader.calloutsDrawMode
       showCalloutsOverlay:loader.showCalloutOverlay
         measurementSystem:loader.measurementSystem
     initialNavigationMode:loader.initialNavigationMode
    cartGpsPositionVisible:loader.isCartGPSPositionVisible
          drawDogLegMarker:loader.drawDogLegMarker
    drawCentralPathMarkers:loader.drawCentralPathMarkers
areFrontBackMarkersDynamic:loader.areFrontBackMarkersDynamic
rotateHoleOnLocationChanged:loader.rotateHoleOnLocationChanged
         autoAdvanceActive:loader.autoAdvanceActive
  cutLayersByHolePerimeter:loader.cutLayersByHoleBackground
         draw3DCentralPath:loader.draw3DCentralLine];
    
    [self setCurrentHole: loader.hole];
    
    
}

-(NSArray *)getParHoleFromResponse:(NSDictionary *)courseScorecardDetailsResponse forMen:(BOOL)isForMen {
    
    NSDictionary* dict = courseScorecardDetailsResponse;
    
    NSArray* menList = [dict valueForKey:@"menScorecardList"];
    NSArray* menParHole;
    NSArray* wmnParHole;
    
    if (menList != nil && menList.count > 0) {
        NSDictionary* listDict = menList.firstObject;
        if (listDict != nil) {
            NSArray* parHole  = [listDict valueForKey:@"parHole"];
            if (parHole != nil) {
                menParHole = parHole;
            }
        }
    }
    
    NSArray* wmnList = [dict valueForKey:@"wmnScorecardList"];
    
    if (wmnList != nil && wmnList.count > 0) {
        NSDictionary* listDict = wmnList.firstObject;
        if (listDict != nil) {
            NSArray* parHole  = [listDict valueForKey:@"parHole"];
            if (parHole != nil) {
                wmnParHole = parHole;
            }
        }
    }
    
    if (isForMen) {
        if (menParHole != nil) {
            return menParHole;
        }
        return wmnParHole;
    } else {
        if (wmnParHole != nil) {
            return wmnParHole;
        }
        return menParHole;
    }
}

-(void)    loadCourseWithId:(NSString*)idCourse
             referralAppKey:(NSString*)referralAppKey
              gpsVectorData:(NSDictionary *)gpsVectorData
             gpsDetailsData:(NSArray *)gpsDetailsData
                    parData:(NSArray *)parData
              elevationData:(NSDictionary *)elevationData
               pinPositions:(NSArray *)pinPositions
             textureQuality:(TextureQuality)textureQuality
           calloutsDrawMode:(CalloutsDrawMode)calloutsDrawMode
        showCalloutsOverlay:(BOOL)showCalloutOverlay
          measurementSystem:(MeasurementSystem)measurementSystem
      initialNavigationMode:(NavigationMode)navigationMode
     cartGpsPositionVisible:(BOOL)isVisible
           drawDogLegMarker:(BOOL)drawDogLegMarker
     drawCentralPathMarkers:(BOOL)drawCentralPathMarkers
 areFrontBackMarkersDynamic:(BOOL)areFronBackMarkersDynamic
rotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged
          autoAdvanceActive:(BOOL)autoAdvanceActive
   cutLayersByHolePerimeter:(BOOL)cutLayersByHolePerimeter
          draw3DCentralPath:(BOOL)draw3DCentralPath
{
    
    VEndpoint* endpoint = [[VEndpoint alloc] init:_loader.endpoint.host
                                applicationAPIKey: _loader.endpoint.applicationAPIKey
                             applicationSecretKey: _loader.endpoint.applicationSecretKey
                                       apiVersion:@"1.1"
                                 signatureVersion:@"2.0"
                                  signatureMethod:@"HmacSHA256"
                                   responseFormat:@"JSON"];
    
    self->_rest = [[V3DRest alloc] initWithEndpoint:endpoint];
    self->_idCourse = idCourse;
    self->_referralAppKey = referralAppKey;
    
    [self loadGpsVectorData:gpsVectorData
          andGpsDetailsData:gpsDetailsData
                 andParData:parData
           andElevationData:elevationData
            andPinPositions:pinPositions
          setTextureQuality:textureQuality
        andCalloutsDrawMode:calloutsDrawMode
     andShowCalloutsOverlay:showCalloutOverlay
       andMeasurementSystem:measurementSystem
   andInitialNavigationMode:navigationMode
  andCartGpsPositionVisible:isVisible
           drawDogLegMarker:drawDogLegMarker
     drawCentralPathMarkers:drawCentralPathMarkers
 areFrontBackMarkersDynamic:areFronBackMarkersDynamic
rotateHoleOnLocationChanged:rotateHoleOnLocationChanged
          autoAdvanceActive:autoAdvanceActive
   cutLayersByHolePerimeter:cutLayersByHolePerimeter
          draw3DCentralPath:draw3DCentralPath];
}


-(void) loadGpsVectorData:(NSDictionary *)gpsVectorData
        andGpsDetailsData:(NSArray *)gpsDetailsData
               andParData:(NSArray *)parData
         andElevationData:(NSDictionary *)elevationData
          andPinPositions:(NSArray *)pinPositions
        setTextureQuality:(TextureQuality)textureQuality
      andCalloutsDrawMode:(CalloutsDrawMode)calloutsDrawMode
   andShowCalloutsOverlay:(BOOL)showCalloutOverlay
     andMeasurementSystem:(MeasurementSystem)measurementSystem
 andInitialNavigationMode:(NavigationMode)navigationMode
andCartGpsPositionVisible:(BOOL)isVisible
         drawDogLegMarker:(BOOL)drawDogLegMarker
   drawCentralPathMarkers:(BOOL)drawCentralPathMarkers
areFrontBackMarkersDynamic:(BOOL)areFronBackMarkersDynamic
rotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged
        autoAdvanceActive:(BOOL)autoAdvanceActive
 cutLayersByHolePerimeter:(BOOL)cutLayersByHolePerimeter
        draw3DCentralPath:(BOOL)draw3DCentralPath
{
    
    if (gpsDetailsData.count == 0 || gpsVectorData.allKeys.count == 0 || parData.count == 0) {
        
        NSMutableDictionary* errorDict = [NSMutableDictionary new];
        [errorDict setValue:@"Not enough data to present golf course map." forKey:@"NSLocalizedDescription"];
        [errorDict setValue:@(-999) forKey:@"Code"];
        [errorDict setValue:@"com.iGolf.errorDomain" forKey:@"Error Domain"];
        NSError* error = [[NSError alloc] initWithDomain:@"com.iGolf.errorDomain" code:-999 userInfo:errorDict];
        
        if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidFailWithError:")])
            [delegate courseRenderViewDidFailWithError:error];
    }
    
    self->_textureType = [TextureProfile determineTextureTypeWithVectorData:gpsVectorData];
    self->_textureProfile = [[TextureProfile alloc] initWithTextureType:_textureType];
    
    NSArray *vertexList = @[
        @(-1.0), @(1.0), @(0.0),
        @(-1.0), @(-1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(-1.0), @(1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(1.0), @(1.0), @(0.0)
    ];
    
    NSArray *vertexList3D = @[
        @(-1.0), @(1.0), @(0.0),
        @(-1.0), @(-1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(-1.0), @(1.0), @(0.0),
        @(1.0), @(-1.0), @(0.0),
        @(1.0), @(1.0), @(0.0),
        
        @(0.0), @(1.0), @(-1.0),
        @(0.0), @(-1.0), @(-1.0),
        @(0.0), @(-1.0), @(1.0),
        @(0.0), @(1.0), @(-1.0),
        @(0.0), @(-1.0), @(1.0),
        @(0.0), @(1.0), @(1.0),
    ];
    
    NSArray *uvList3D = @[
        @(0.0), @(0.0),
        @(0.0), @(1.0),
        @(1.0), @(1.0),
        @(0.0), @(0.0),
        @(1.0), @(1.0),
        @(1.0), @(0.0),
        @(0.0), @(0.0),
        @(0.0), @(1.0),
        @(1.0), @(1.0),
        @(0.0), @(0.0),
        @(1.0), @(1.0),
        @(1.0), @(0.0),
    ];
    
    NSArray *uvList = @[
        @(0.0), @(0.0),
        @(0.0), @(1.0),
        @(1.0), @(1.0),
        @(0.0), @(0.0),
        @(1.0), @(1.0),
        @(1.0), @(0.0)
    ];
    
    self.measurementSystem = measurementSystem;
    _textureVertexBuffer = [GLHelper getBuffer:vertexList];
    _textureUVBuffer = [GLHelper getBuffer:uvList];
    _textureVertexBuffer3D = [GLHelper getBuffer:vertexList3D];
    _textureUVBuffer3D = [GLHelper getBuffer:uvList3D];
    _initialHoleLoad = true;
    _gpsVectorData = gpsVectorData;
    _gpsDetailsData = gpsDetailsData;
    _parData = parData;
    _holeTreesCount = 0;
    
    if (elevationData) {
        
        _grid = [[ElevationMap alloc] initWithJsonObject:elevationData
                                       andTextureQuality:textureQuality
                                    andTextureProfile:_textureProfile];
    }
    
    _callouts = [[Callouts alloc] initWithLocationTextureFilePath:[[NSBundle mainBundle] pathForResource:@"v2d_current_location" ofType:@"png"]
                                            andEndLocationTexture:[[NSBundle mainBundle] pathForResource:@"v2d_end_location" ofType:@"png"]
                                         andCursorTextureFilePath:[[NSBundle mainBundle] pathForResource:@"v2d_cursor" ofType:@"png"]
                                                  andVertexbuffer:_textureVertexBuffer
                                                      andUVBuffer:_textureUVBuffer];
    
    _lineToFlag = [[LineToFlag alloc] initWithLocationTextureFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_viewercurrentloc" ofType:@"png"] andElevationGrid:_grid andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer];
    
    
    _greenViewCursor = [[GreenViewCursor alloc] initWithCursorTextureFilePath:[[NSBundle mainBundle] pathForResource:@"v2d_green_cursor" ofType:@"png"]
                                                              andVertexbuffer:_textureVertexBuffer
                                                                  andUVBuffer:_textureUVBuffer];
    
    self.autoAdvanceActive = autoAdvanceActive;
    self.calloutsDrawMode = calloutsDrawMode;
    self.showCalloutOverlay = showCalloutOverlay;
    self.drawDogLegMarker = drawDogLegMarker;
    self.drawCentralPathMarkers = drawCentralPathMarkers;
    self.areFrontBackMarkersDynamic = areFronBackMarkersDynamic;
    self.rotateHoleOnLocationChanged = rotateHoleOnLocationChanged;
    self.draw3DCentralLine = draw3DCentralPath;
    self.cutLayersByHoleBackground = cutLayersByHolePerimeter;
    
    _callouts.calloutsDrawMode = calloutsDrawMode;
    _effect = [GLKBaseEffect new];
    _isApplicationActive = true;
    _initialNavigationMode = navigationMode;
    _isCartMarkerVisible = isVisible;
    _pinPositionOverride = [[PinPositionOverride alloc] initWithData:pinPositions];
    
    [self loadStaticData];
}

- (void)loadStaticData {
    Profiler* profiler = [Profiler new];
    
    [self releaseCourseData];
    
    if (_grid == nil) {
        [Layer resetBaseValues];
    }
    
    _sandBorderLayer = [self addBorderLayerWithJsonObject:_gpsVectorData
                                             andLayerName:@"Sand" andInterpolation:PointInterpolationInterpolate
                                                andExtend:METERS_IN_POINT];
    [self addCourseObjectToDestroy:_sandBorderLayer];
    
    _sandLayer = [self addLayerWithJsonObject:_gpsVectorData
                                 andLayerName:@"Sand"];
    
    [self addCourseObjectToDestroy:_sandLayer];
    
    _lakeBorderLayer = [self addBorderLayerWithJsonObject:_gpsVectorData
                                             andLayerName:@"Lake" andInterpolation:PointInterpolationKeepOriginal
                                                andExtend:METERS_IN_POINT];
    [self addCourseObjectToDestroy:_lakeBorderLayer];
    
    _lakeLayer = [self addLayerWithJsonObject:_gpsVectorData
                                 andLayerName:@"Lake"];
    
    [self addCourseObjectToDestroy:_lakeLayer];
    
    _lavaLayer = [self addLayerWithJsonObject:_gpsVectorData
                                 andLayerName:@"Lava"];
    
    [self addCourseObjectToDestroy:_lavaLayer];
    
    _oceanBorderLayer = [self addBorderLayerWithJsonObject:_gpsVectorData
                                              andLayerName:@"Ocean"
                                          andInterpolation:PointInterpolationKeepOriginal
                                                 andExtend:METERS_IN_POINT];
    
    [self addCourseObjectToDestroy:_oceanBorderLayer];
    
    _oceanLayer = [self addLayerWithJsonObject:_gpsVectorData andLayerName:@"Ocean"];
    
    [self addCourseObjectToDestroy:_oceanLayer];
    
    _pondBorderLayer = [self addBorderLayerWithJsonObject:_gpsVectorData andLayerName:@"Pond" andInterpolation:PointInterpolationKeepOriginal andExtend:METERS_IN_POINT];
    
    [self addCourseObjectToDestroy:_pondBorderLayer];
    _pondLayer = [self addLayerWithJsonObject:_gpsVectorData andLayerName:@"Pond"];
    
    [self addCourseObjectToDestroy:_pondLayer];
    
    _waterBorderLayer = [self addBorderLayerWithJsonObject:_gpsVectorData andLayerName:@"Water" andInterpolation:PointInterpolationKeepOriginal andExtend:METERS_IN_POINT];
    
    [self addCourseObjectToDestroy:_waterBorderLayer];
    _waterLayer = [self addLayerWithJsonObject:_gpsVectorData andLayerName:@"Water" andInterpolation:PointInterpolationKeepOriginal andExtend:0];
    
    [self addCourseObjectToDestroy:_waterLayer];
    
    _bridgeLayer = [self addLayerWithJsonObject:_gpsVectorData andLayerName:@"Bridge" andInterpolation:PointInterpolationKeepOriginal andExtend:0];
    
    [self addCourseObjectToDestroy:_bridgeLayer];
    
    _groud = [[Ground alloc] initWith2DTextureFilePath:[[NSBundle mainBundle] pathForResource:_textureProfile.backgroundTexture2DName ofType:@"png"] and3DTextureFilePath:[[NSBundle mainBundle] pathForResource:_textureProfile.backgroundTexture3DName ofType:@"png"] andFlyoverTextureFilePath:[[NSBundle mainBundle] pathForResource:_textureProfile.flyoverTextureName ofType:@"png"]];
    
    
    _skyGradient = [[Sky alloc] initWithDefaultFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_sky_gradient" ofType:@"png"] andTextureFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_sky_gradient" ofType:@"png"]];
    
    _skyClouds = [[Sky alloc] initWithDefaultFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_sky_clouds" ofType:@"png"] andTextureFilePath:[[NSBundle mainBundle] pathForResource:@"v3d_sky_clouds" ofType:@"png"]];
    
    if ([_gpsVectorData objectForKey:@"Tree"] != nil) {
        _treeLayer = [[PointListLayer alloc] initWithJsonObject:[_gpsVectorData objectForKey:@"Tree"] andTransform:YES];
    }
    
    if ([_gpsVectorData objectForKey:@"Path"] != nil) {
        _pathLayer = [[PointListLayer alloc] initWithJsonObject:[_gpsVectorData objectForKey:@"Path"] andTransform:YES];
    }
    
    if ([_gpsVectorData objectForKey:@"Creek"] != nil) {
        _creekLayer = [[PointListLayer alloc] initWithJsonObject:[_gpsVectorData objectForKey:@"Creek"] andTransform:YES];
    }
    
    _numberOfHoles = [[_gpsVectorData objectForKey:@"HoleCount"] intValue];
    _perimeterLayerCache = [NSMutableDictionary new];
    
    NSDictionary* holesObject = [_gpsVectorData objectForKey:@"Holes"];
    NSArray* holeArray = [holesObject objectForKey:@"Hole"];
    for (NSDictionary* holeObject in holeArray) {
        NSDictionary* perimeter = [holeObject objectForKey:@"Perimeter"];
        if (perimeter == nil) {
            continue;
        }
        
        int holeNumber = [[holeObject objectForKey:@"HoleNumber"] intValue];
        PointListLayer* layer = [[PointListLayer alloc] initWithJsonObject:perimeter andTransform:NO];
        [_perimeterLayerCache setObject:layer forKey:@(holeNumber)];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:CourseRenderView.didLoadCourseDataNotification];
    
    if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidLoadCourseData")])
        [delegate courseRenderViewDidLoadCourseData];
    
    [profiler stopWithMessage:@"loadStaticData"];
}

- (void)setCurrentHole:(NSUInteger)currentHole {
    _holeIndex = (int)currentHole - 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startLoadHoleData];
        self->holeSetTimeStamp = [[NSDate date] timeIntervalSinceReferenceDate];
    });
}

- (void)startLoadHoleData {
    [self loadHoleData];
}

- (void)loadAllHoles {
    for (int i = 1; i <= _numberOfHoles; i++) {
        [self setCurrentHole:i];
    }
}

- (void)loadHoleData {
    Profiler* profiler = [Profiler new];
    [_grid clean];
    [self releaseHoleData];
    [_layerList removeAllObjects];
    [_cartPathList removeAllObjects];
    [_treeList removeAllObjects];
    [_markerList removeAllObjects];
    NSDictionary* holesObject = [_gpsVectorData objectForKey:@"Holes"];
    NSArray* holeArray = [holesObject objectForKey:@"Hole"];
    NSDictionary* holeObject = holeArray[_holeIndex];
    _perimeterLayer = [self addLayerWithJsonObject:holeObject andLayerName:@"Perimeter"];
    PointListLayer* perimeterPointListLayer = [[PointListLayer alloc] initWithJsonObject:holeObject[@"Perimeter"] andTransform:YES];
    Layer* layer = nil;
    layer = [self addBorderLayerWithJsonObject:holeObject andLayerName:@"Fairway" andInterpolation:PointInterpolationInterpolate andExtend:2 * METERS_IN_POINT];
    [self addHoleObjectToDestroy:layer];
    layer = [self addLayerWithJsonObject:holeObject andLayerName:@"Fairway"];
    [self addHoleObjectToDestroy:layer];
    _fairwayPointListLayer = nil;
    if (layer != nil) {
        _fairwayPointListLayer = [[PointListLayer alloc] initWithJsonObject:holeObject[@"Fairway"] andTransform:YES];
    }
    layer = [self addBorderLayerWithJsonObject:holeObject andLayerName:@"Bunker" andInterpolation:PointInterpolationInterpolate andExtend:0.5 * METERS_IN_POINT];
    [self addHoleObjectToDestroy:layer];
    layer = [self addBorderLayerWithJsonObject:holeObject andLayerName:@"Bunker" andInterpolation:PointInterpolationInterpolate andExtend:0.5 * METERS_IN_POINT];
    [self addHoleObjectToDestroy:layer];
    _bunkerList = [NSMutableArray new];
    layer = [self addBorderLayerWithJsonObject:holeObject andLayerName:@"Bunker" andInterpolation:PointInterpolationInterpolate andExtend:0.5 * METERS_IN_POINT];
    [self addHoleObjectToDestroy:layer];
    layer = [self addLayerWithJsonObject:holeObject andLayerName:@"Bunker"];
    [self addHoleObjectToDestroy:layer];
    if (_grid != nil) {
        _bunkerList = [NSMutableArray new];
        NSDictionary* bunkerDict = [holeObject objectForKey:@"Bunker"];
        NSDictionary* shapes = [bunkerDict objectForKey:@"Shapes"];
        NSArray* shape = [shapes objectForKey:@"Shape"];
        
        for (NSDictionary* dict in shape) {
            [_bunkerList addObject:[[Bunker3D alloc]initWithDictionary:dict andElevationMap:_grid]];
        }
    }
    layer = [self addBorderLayerWithJsonObject:holeObject andLayerName:@"Green" andInterpolation:PointInterpolationInterpolate andExtend:0.5 * METERS_IN_POINT];
    [self addHoleObjectToDestroy:layer];
    _greenLayer = [self addLayerWithJsonObject:holeObject andLayerName:@"Green"];
    [self addHoleObjectToDestroy:_greenLayer];
    
    [self addLayer:_lakeBorderLayer];
    [self addLayer:_lakeLayer];
    [self addLayer:_lavaLayer];
    [self addLayer:_oceanBorderLayer];
    [self addLayer:_oceanLayer];
    [self addLayer:_pondBorderLayer];
    [self addLayer:_pondLayer];
    [self addLayer:_waterBorderLayer];
    [self addLayer:_waterLayer];
    [self addLayer:_sandBorderLayer];
    [self addLayer:_sandLayer];
    if (_creekLayer != nil) {
        NSMutableArray<Creek*>* creekList = [NSMutableArray new];
        for (PointList* pointList in _creekLayer.pointList) {
            if (CGRectIntersectsRect(pointList.boundingBox, _perimeterLayer.boundingBox) == NO) {
                continue;
            }
            
            Creek* creek = [[Creek alloc] initWithTextureFilename:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_creek" ofType:@"png"] andPointList:pointList andWidth:2 * METERS_IN_POINT];
            [creekList addObject:creek];
            [self addHoleObjectToDestroy:creek];
        }
        
        CreekRenderer* creekRenderer = [CreekRenderer new];
        creekRenderer.creekList = creekList;
        [_layerList addObject:creekRenderer];
        
    }
    [self addLayer:_bridgeLayer];
    
    layer = [self addBorderLayerWithJsonObject:holeObject andLayerName:@"Teebox" andInterpolation:PointInterpolationKeepOriginal andExtend:METERS_IN_POINT];
    [self addHoleObjectToDestroy:layer];
    
    if (layer != nil) {
        _teeBoxLayer = layer;
    }
    layer = [self addLayerWithJsonObject:holeObject andLayerName:@"Teebox" andInterpolation:PointInterpolationKeepOriginal andExtend:0.0];
    [self addHoleObjectToDestroy:layer];
    
    [self loadTrees];
    for (PointList* pointList in _pathLayer.pointList) {
        if (CGRectIntersectsRect(pointList.boundingBox, _perimeterLayer.boundingBox) == NO) {
            continue;
        }
        
        CartPath* cartPath = [[CartPath alloc] initWithTextureFilename:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_cart_path" ofType:@"png"] andPointList:pointList andWidth: 2 * METERS_IN_POINT];
        [_cartPathList addObject:cartPath];
        [self addHoleObjectToDestroy:cartPath];
    }
    _greenCenterLayer = [[PointListLayer alloc] initWithJsonObject:[holeObject objectForKey:@"Greencenter"] andTransform:YES];
    
    Vector* position = _greenCenterLayer.pointList.firstObject.pointList.firstObject;
    
    Vector* overridedPosition = [_pinPositionOverride getPositionForHole:self.currentHole];
    
    if (overridedPosition != nil) {
        position = overridedPosition;
    }
    
    _usesOverridedPinPosition = overridedPosition != nil;
    position.z = [_grid getZForPointX:-position.x andY:-position.y];
    
    _flag = [[Flag alloc] initWithTextureFilename:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_flag" ofType:@"png"] andPosition:position andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer];
    _greenViewCursor.position = position;
    
    [self loadDistanceMarkers];
    
    _cart = [[Cart alloc] initWithTextureFilename:[[NSBundle mainBundle] pathForResource:@"v3d_user_location_pin" ofType:@"png"] andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationMap:_grid];
    
    
    _isFlyoverAvailable = NO;
    
    NSDictionary* centralPathDictionary = [holeObject objectForKey:@"Centralpath"];
    
    if (centralPathDictionary != nil) {
        
        _centralPathLayer = [[PointListLayer alloc] initWithJsonObject:centralPathDictionary andTransform:YES];
        Vector* greenCenter = _greenCenterLayer.pointList.firstObject.pointList.firstObject;
        Vector* centralPath1 = _centralPathLayer.pointList.lastObject.pointList.firstObject;
        Vector* centralPath2 = _centralPathLayer.pointList.lastObject.pointList.lastObject;
        
        double len1 = [greenCenter distanceWithVector:centralPath1];
        double len2 = [greenCenter distanceWithVector:centralPath2];
        
        if (len2 > len1) {
            [_centralPathLayer.pointList.firstObject reverse];
        }
        
        NSMutableArray<Vector*>* centralPathPoints = _centralPathLayer.pointList.firstObject.pointList;
        
        [centralPathPoints removeLastObject];
        [centralPathPoints addObject:position];
        
        if(_camera == nil){
            _camera = [[Camera alloc] init];
            [_camera updateViewportAndProjectionMatrix:self andRenderWidthPercent:([self shouldUsePercentageWidth] ? _renderViewWidthPercent : 1)];
        }
        
        _camera = [_camera initWithView:self andAutoZoomActive:_isCameraAutoZoomActive andElevationMap:_grid andFinalPosition:position andRotateHoleOnLocationChanged:_rotateHoleOnLocationChanged];
        _camera.delegate = self;
        _camera.teeBoxLayer = _teeBoxLayer;
        _camera.centralPath = _centralPathLayer;
        _camera.callouts = _callouts;
        _camera.lineToFlag = _lineToFlag;
        _camera.location = _currentLocation;
        _camera.x = -_centralPathLayer.pointList[0].pointList[0].x;
        _camera.y = -_centralPathLayer.pointList[0].pointList[0].y;
        
        _camera.frontGreenMarker = _frontGreenMarker;
        _camera.backGreenMarker = _backGreenMarker;
        
        _camera.greenLayer = _greenLayer;
        _camera.perimeterLayer = _perimeterLayer;
        _camera.perimeterPointListLayer = perimeterPointListLayer;
        
        _camera.fairwayPointListLayer = _fairwayPointListLayer;
        _camera.parValue = [_parData[_holeIndex] intValue];
        
        _camera.overallHoleViewAngle = _overallHoleViewAngle;
        _camera.freeCamViewAngle = _freeCamViewAngle;
        //_camera.greenViewViewAngle = _greenViewViewAngle;
        
        _camera.flyoverViewAngle = _flyoverViewAngle;
        
        [_camera prepareFlyoverParameters];
        
        _isFlyoverAvailable = true;
        
        [self addAdditionalHazardForDogLegHoles];
        [self addCentralPathHazards];
        [_callouts setCentralPath:_centralPathLayer andDogLegLocation:((_dogLegMarker != nil) ? [_dogLegMarker location] : nil)];
    } else {
        _isFlyoverAvailable = false;
        _callouts.centralPath = nil;
    }
    _holeTreesCount = (int)_treeList.count;
    
    [profiler stopWithMessage:@"loadHoleData"];
    
    if (_initialHoleLoad) {
        [self startDrawing];
        [self performDraw:false];
        _initialHoleLoad = false;
    }
    
    [self setNavigationMode:_initialNavigationMode];
    
    [self startDrawing];
    [self draw];
    [[NSNotificationCenter defaultCenter] postNotification:CourseRenderView.didLoadHoleDataNotification];
    
    if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidLoadHoleData")]) {
        [delegate courseRenderViewDidLoadHoleData];
    }
    
    if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidUpdateCurrentHole:")])
        [delegate courseRenderViewDidUpdateCurrentHole:_holeIndex + 1];
    
    [self sendDistances];
}


- (void)setupTimer {
    
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(onTimerTick)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer fire];
    }
    
    
    
}

- (void)invalidateTimer {
    
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

//-(void)sayDistanceToCenter {
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        double center = [DistanceCalculator distanceWithLocation1:_currentLocation
//                                                     andLocation2:_flag.location
//                                             andMEasurementSystem:_measurementSystem];
//
//        if (_currentLocation == nil) {
//            center = 999.0;
//        }
//
//        NSString* stringToSpeak = [NSString stringWithFormat:@"Distance to center is %d ", (int)fmin(center, 999.0)];
//
//        if (_measurementSystem == MeasurementSystemMetric) {
//            stringToSpeak = [stringToSpeak stringByAppendingString:@"meters."];
//        } else {
//            stringToSpeak = [stringToSpeak stringByAppendingString:@"yards."];
//        }
//
//        if (_voice) {
//            [_voice interrupt];
//        }
//
//        _voice = [[SiriVoice alloc] initWithString:stringToSpeak];
//
//        [_voice speak];
//
//    });
//}

//-(void)sayDistanceToCenterWhileChangingHole {
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        double center = [DistanceCalculator distanceWithLocation1:_currentLocation
//                                                     andLocation2:_flag.location
//                                             andMEasurementSystem:_measurementSystem];
//
//        if (_currentLocation == nil) {
//            center = 999.0;
//        }
//
//        NSString* stringToSpeak = [NSString stringWithFormat:@"Changing to hole %d. Distance to center is %d ",_holeIndex + 1, (int)fmin(center, 999.0)];
//
//        if (_measurementSystem == MeasurementSystemMetric) {
//            stringToSpeak = [stringToSpeak stringByAppendingString:@"meters."];
//        } else {
//            stringToSpeak = [stringToSpeak stringByAppendingString:@"yards."];
//        }
//
//        if (_voice) {
//            [_voice interrupt];
//        }
//
//        _voice = [[SiriVoice alloc] initWithString:stringToSpeak];
//
//        [_voice speak];
//    });
//
//
//}



-(void)tapGestureWithRegognizer:(UITapGestureRecognizer*)recognizer {
    
    Vector *pos = [_camera calculateTouchPoint:[recognizer locationInView:self]];
    CLLocation* location = nil;
    
    if (pos != nil) {
        location = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:pos.y] longitude:[Layer transformToLonWithDouble:pos.x]];
        
        
        if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidReceiveTapAtLocation:")]) {
            [delegate courseRenderViewDidReceiveTapAtLocation:location];
        }
        
    }
    
    
    if (_camera.navigationMode != NavigationMode2DView && _camera.navigationMode != NavigationMode2DGreenView) {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            if (location != nil) {
                
                _tapDistanceMarker = [[DistanceMarker alloc] initWithGroundTextureFilename:[[NSBundle mainBundle] pathForResource:@"v3d_custom_distance_target" ofType:@"png"] andCalloutTextureFileName:nil andtexture2DFileName:nil andLocation:location andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationGrid:_grid andMarkerType:2];
                _tapDistanceMarker.measurementSystem = _measurementSystem;
                
                
                tapMarkerCreateDate = [[NSDate alloc]init];
                
                //                _tapDistanceMarker = [[DistanceMarker3D alloc]initWithGroundTextureFilename:[[NSBundle mainBundle] pathForResource:@"v3d_custom_distance_target" ofType:@"png"] andLocation:location andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationGrid:_grid];
                //                _tapDistanceMarker.measurementSystem = _measurementSystem;
                
                
                tapMarkerCreateDate = [[NSDate alloc]init];
                
                [self startDrawing];
            }
        }
    }
}

-(void)doubleTapGestureWithRegognizer:(UITapGestureRecognizer*)recognizer {
    
    CGPoint point = [recognizer locationInView:self];
    [_camera applyZoomWithCustomTapPoint:point];
    
    [self startDrawing];
}


- (void)panGestureWithRegognizer:(UIPanGestureRecognizer*)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateEnded: {
            [_camera endPan];
            break;
        }
        default: {
            CGPoint translation = [recognizer translationInView:self];
            _camera.gesturePan = translation;
            break;
        }
    }
    [self startDrawing];
}

- (void)rotationGestureWithRecognizer:(UIRotationGestureRecognizer*)recognizer {
    
    if (_camera.navigationMode == NavigationMode2DView || _camera.navigationMode == NavigationMode2DGreenView || _camera.navigationMode == NavigationMode3DGreenView) {
        return;
    }
    
    if (_camera.navigationMode == NavigationModeFlyover && _grid != nil) {
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateEnded: {
            [_camera endRotation];
            break;
        }
        default: {
            _camera.gestureRotation = -[VectorMath rad2degWithRad:recognizer.rotation];
        }
    }
    
    [self startDrawing];
}

- (void)pinchGestureWithRecognizer:(UIPinchGestureRecognizer*)recognizer {
    
    if (!(_camera.navigationMode == NavigationMode2DView || _camera.navigationMode == NavigationMode2DGreenView)) {
        return;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateEnded: {
            [_camera endZoom];
            break;
        }
        default: {
            _camera.gestureZoom = recognizer.scale;
        }
    }
    [self startDrawing];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    [self startDrawing];
    return _callouts.hasFocus == NO && _greenViewCursor.hasFocus == NO && _lineToFlag.hasFocus == NO;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    BOOL handled = NO;
    
    if (touches.count == 1 && (_camera.navigationMode == NavigationMode2DView || _camera.navigationMode == NavigationMode2DGreenView)) {
        
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInView:self];
        Vector* unprojected = [_camera unprojectWithTouchPoint:point];
        
        if (_camera.navigationMode == NavigationMode2DView) {
            handled = [_callouts onTouchDown:unprojected andCamera:_camera];
        } else if (_camera.navigationMode == NavigationMode2DGreenView) {
            handled = [_greenViewCursor onTouchDown:unprojected andCamera:_camera];
        }
    }else if(touches.count == 1 ){
        if (_draw3DCentralPath && _lineToFlag != NULL){
            UITouch* touch = touches.anyObject;
            CGPoint point = [touch locationInView:self];
            handled = [_lineToFlag onTouchDown:point andCamera:_camera];
        }
    }
    
    if (handled == NO) {
        [super touchesBegan:touches withEvent:event];
    } else {
        [_camera updateLastZoomDate];
    }
    
    [self startDrawing];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event {
    BOOL handled = NO;
    
    if (touches.count == 1 && (_camera.navigationMode == NavigationMode2DView || _camera.navigationMode == NavigationMode2DGreenView) && (_callouts.hasFocus || _greenViewCursor.hasFocus)) {
        
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInView:self];
        Vector* unprojected = [_camera unprojectWithTouchPoint:point];
        
        if (_camera.navigationMode == NavigationMode2DView) {
            handled = [_callouts onTouchMove:unprojected];
        } else if (_camera.navigationMode == NavigationMode2DGreenView) {
            handled = [_greenViewCursor onTouchMove:unprojected];
            if (handled) {
                [self sendDistances];
            }
        }
    } else if (touches.count == 1 && _lineToFlag.hasFocus){
        if (_draw3DCentralPath && _lineToFlag != NULL){
            UITouch* touch = touches.anyObject;
            CGPoint point = [touch locationInView:self];
            Vector* unprojected = [_camera unprojectWithTouchPoint:point];
            handled = [_lineToFlag onTouchMove:unprojected];
        }
    }
    
    if (handled == NO) {
        [super touchesMoved:touches withEvent:event];
    } else {
        [_camera updateLastZoomDate];
    }
    
    [self startDrawing];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent*)event {
    
    BOOL handled = NO;
    if (touches.count == 1 && (_camera.navigationMode == NavigationMode2DView || _camera.navigationMode == NavigationMode2DGreenView)) {
        UITouch* touch = touches.anyObject;
        CGPoint point = [touch locationInView:self];
        Vector* unprojected = [_camera unprojectWithTouchPoint:point];
        
        if (_camera.navigationMode == NavigationMode2DView) {
            handled = [_callouts onTouchUp:unprojected];
        } else if (_camera.navigationMode == NavigationMode2DGreenView) {
            handled = [_greenViewCursor onTouchUp:unprojected];
        }
        [_camera updateLastZoomDate];
    } else if(touches.count == 1){
        if (_draw3DCentralPath && _lineToFlag != NULL){
            UITouch* touch = touches.anyObject;
            CGPoint point = [touch locationInView:self];
            Vector* unprojected = [_camera unprojectWithTouchPoint:point];
            handled = [_lineToFlag onTouchUp:unprojected];
        }
    }
    
    if (handled == NO) {
        [super touchesEnded:touches withEvent:event];
    } else {
        [_camera updateLastZoomDate];
    }
    
    [self startDrawing];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch locationInView:self].x * [UIScreen mainScreen].scale < [self getCurrentOffset:[self shouldUsePercentageWidth]]){
        return false;
    }
    return true;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if([gestureRecognizer isKindOfClass: UIPinchGestureRecognizer.class] || [gestureRecognizer isKindOfClass: UIRotationGestureRecognizer.class])   {
        if([otherGestureRecognizer isKindOfClass: UIPinchGestureRecognizer.class] || [otherGestureRecognizer isKindOfClass: UIRotationGestureRecognizer.class]) {
            return true;
        }
    }
    
    return false;
}

- (void)sendDistances {
    CLLocation* location =  (_callouts != nil && _currentLocation == nil) ? [_callouts startPointLocation] : _currentLocation;
    if (location == nil || _frontGreenMarker == nil || _backGreenMarker == nil || _flag == nil) {
        return;
    }
    
    if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidUpdateDistancesToFrontGreen:toCenterGreen:toBackGreen:")]) {
        double front = [DistanceCalculator distanceWithLocation1:location
                                                    andLocation2:_frontGreenMarker.location
                                            andMEasurementSystem:_measurementSystem];
        
        double center = [DistanceCalculator distanceWithLocation1:location
                                                     andLocation2: _camera.navigationMode == NavigationMode2DGreenView ? _greenViewCursor.location : _flag.location
                                             andMEasurementSystem:_measurementSystem];
        
        double back = [DistanceCalculator distanceWithLocation1:location
                                                   andLocation2:_backGreenMarker.location
                                           andMEasurementSystem:_measurementSystem];
        
        
        [delegate courseRenderViewDidUpdateDistancesToFrontGreen:fmin(front, 999.0)
                                                   toCenterGreen:fmin(center, 999.0)
                                                     toBackGreen:fmin(back, 999.0)];
    }
}

- (void)setSimulatedLocation:(CLLocation *)simulatedLocation {
    
    _currentLocation = simulatedLocation;
    
    [self updateHoleWithin: simulatedLocation];
    
    if (_isApplicationActive) {
        [self processNewLocation: simulatedLocation];
    } else {
        [self sendDistances];
    }
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    
    _currentLocation = currentLocation;
    
    if (_areFrontBackMarkersDynamic) {
        [self updateFronAndBackMarkersDynamicaly];
    }
    
    [self updateHoleWithin: currentLocation];
    
    if (_isApplicationActive) {
        [self processNewLocation: currentLocation];
    } else {
        [self sendDistances];
    }
}

- (void)updateFronAndBackMarkersDynamicaly {
    
    if (_frontGreenMarker == nil || _backGreenMarker == nil || _currentLocation == nil) {
        return;
    }
    
    double currentX = [Layer transformLonFromDouble:_currentLocation.coordinate.longitude];
    double currentY = [Layer transformLatFromDouble:_currentLocation.coordinate.latitude];
    
    Vector* start = [[Vector alloc] initWithX:currentX andY:currentY];
    
    Vector* end  = _flag.flagPosition;
    
    
    Line* centerLine = [[Line alloc] initWithP1: start
                                          andP2:end];
    
    NSMutableArray<Vector*>* intersections = [NSMutableArray new];
    
    for (LayerPolygon * p in _greenLayer.layerPolygons) {
        for (int i = 0; i < p.vectorArray.count - 1; i++) {
            Vector* v1 = p.vectorArray[i];
            Vector* v2 = p.vectorArray[i + 1];
            Line* line = [[Line alloc] initWithP1:v1
                                            andP2:v2];
            
            Vector* intersection = [VectorMath externalIntersectionWithLineA:centerLine andLineB:line];
            
            if (intersection != nil) {
                [intersections addObject:intersection];
            }
        }
    }
    
    if (intersections.count == 0) {
        return;
    }
    
    Vector* closest = intersections.firstObject;
    Vector* furthest = intersections.firstObject;
    
    double closestDistance = fabs([VectorMath distanceWithVector1:centerLine.p1 andVector2:furthest]);
    double furthestDistane = fabs([VectorMath distanceWithVector1:centerLine.p1 andVector2:closest]);
    
    for (Vector* v in intersections) {
        
        double distance = fabs([VectorMath distanceWithVector1:centerLine.p1 andVector2:v]);
        
        if (distance < closestDistance) {
            closest = v;
            closestDistance = distance;
        }
        
        if (distance > furthestDistane) {
            furthest = v;
            furthestDistane = distance;
        }
    }
    
    double frontLat = [Layer transformToLatWithDouble:closest.y];
    double frontLon = [Layer transformToLonWithDouble:closest.x];
    
    double backLat = [Layer transformToLatWithDouble:furthest.y];
    double backLon = [Layer transformToLonWithDouble:furthest.x];
    
    [_frontGreenMarker updateMarkerLocation:[[CLLocation alloc] initWithLatitude:frontLat longitude:frontLon]];
    [_backGreenMarker updateMarkerLocation:[[CLLocation alloc] initWithLatitude:backLat longitude:backLon]];
}

- (void)updateHoleWithin:(CLLocation*)location {
    
    __block NSUInteger newHoleWithin = 0;
    
    __block Vector* point = [[Vector alloc] initWithX:location.coordinate.longitude andY:_currentLocation.coordinate.latitude];
    [_perimeterLayerCache enumerateKeysAndObjectsUsingBlock:^(NSNumber* _Nonnull key, PointListLayer* _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj containsWithVector:point]) {
            newHoleWithin = [key unsignedIntegerValue];
            *stop = true;
        }
    }];
    
    if (_holeWithin != newHoleWithin) {
        _holeWithin = newHoleWithin;
        
        if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidUpdateHoleWithin:")]) {
            [delegate courseRenderViewDidUpdateHoleWithin:_holeWithin];
        }
    }
    [self autoAdvanceHoleIfNeeded:_holeWithin];
}

-(void)autoAdvanceHoleIfNeeded:(NSUInteger)holeWithin {
    if(_autoAdvanceActive == false){
        return;
    }
    
    if(holeSetTimeStamp == 0){
        return;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    double diff = (now - holeSetTimeStamp);
    
    if (diff < 20) {
        return;
    }
    
    if(holeWithin != (self.currentHole + 1)){
        return;
    }
    
    [self setCurrentHole:holeWithin];
    
}

- (void)processNewLocation:(CLLocation*)location {
    
    [_callouts setCurrentLocation:location];
    [_lineToFlag setCurrentLocation:location];
    
    if (_camera != nil) {
        
        _camera.location = location;
        
        if (_camera.navigationMode == NavigationModeFreeCam) {
            if (_camera.isAutozoomActive == true) {
                [_camera update3DFreeCamPosition];
            }
        }
        
        if (_camera.navigationMode == NavigationMode3DGreenView) {
            if (_camera.isAutozoomActive == true) {
                [_camera update3DGreenViewPosition];
            }
        }
        
        if (_camera.navigationMode == NavigationMode2DGreenView) {
            if (_camera.isAutozoomActive == true) {
                [_camera update2DGreenViewPosition];
            }
        }
        if (_camera.navigationMode == NavigationMode2DView) {
            if (_camera.isAutozoomActive == true) {
                [_camera update2DPosition];
            }
        }
    }
    
    [self sendDistances];
    
    [self startDrawing];
}

-(void)setInitialNavigationMode:(NavigationMode)initialNavigationMode {
    _initialNavigationMode = initialNavigationMode;
}

- (void)setNavigationMode:(NavigationMode)navigationMode {
    _camera.navigationMode = navigationMode;
    [self updateViewportSize:[self shouldUsePercentageWidth]];
    [self updateCameraViewportAndProjectionMatrix];
    [self sendDistances];
    [self startDrawing];
}

-(BOOL) shouldUsePercentageWidth {
    return _camera.navigationMode != NavigationModeFlyover && _camera.navigationMode != NavigationModeFlyoverPause;
}



- (void)setCalloutsDrawMode:(CalloutsDrawMode)calloutsDrawMode {
    _calloutsDrawMode = calloutsDrawMode;
    _callouts.calloutsDrawMode = calloutsDrawMode;
    [self startDrawing];
}

- (void)setDrawDogLegMarker:(BOOL)drawDogLegMarker {
    _drawDogLegMarker = drawDogLegMarker;
    [self startDrawing];
}

- (void)setAreFrontBackMarkersDynamic:(BOOL)areFrontBackMarkersDynamic{
    _areFrontBackMarkersDynamic = areFrontBackMarkersDynamic;
    if (_areFrontBackMarkersDynamic) {
        [self updateFronAndBackMarkersDynamicaly];
    } else {
        if (_frontGreenMarker != nil) {
            [_frontGreenMarker restoreOriginalLocation];
        }
        if (_backGreenMarker != nil) {
            [_backGreenMarker restoreOriginalLocation];
        }
    }
    [self startDrawing];
}

- (void)setRotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged{
    _rotateHoleOnLocationChanged = rotateHoleOnLocationChanged;
    [_camera setRotateHoleOnLocationChanged:_rotateHoleOnLocationChanged];
    [self startDrawing];
}



- (void)setAutoAdvanceActive:(BOOL)autoAdvanceActive{
    _autoAdvanceActive = autoAdvanceActive;
}

- (void)setDrawCentralPathMarkers:(BOOL)drawCentralPathMarkers{
    _drawCentralPathMarkers = drawCentralPathMarkers;
    [self startDrawing];
}

- (void)setCutLayersByHoleBackground:(BOOL)cutLayersByHolePerimeter {
    _cutLayersByHolePerimeter = cutLayersByHolePerimeter;
    [_grid clean];
    [self startDrawing];
}

- (void)setDraw3DCentralLine:(BOOL)draw3DCentralPath{
    _draw3DCentralPath = draw3DCentralPath;
    [self startDrawing];
}

- (BOOL)drawDogLegMarker {
    return _drawDogLegMarker;
}

- (BOOL)drawCentralPathMarkers {
    return _drawCentralPathMarkers;
}

- (BOOL)cutLayersByHoleBackground {
    return _cutLayersByHolePerimeter;
}

-(BOOL)draw3DCentralLine {
    return _draw3DCentralPath;
}

- (BOOL)autoAdvanceActive {
    return _autoAdvanceActive;
}

- (void)setShowCalloutOverlay:(BOOL)showCalloutOverlay {
    
    _callouts.showOverlay = showCalloutOverlay;
    
    [self startDrawing];
}

-(void)setAutozoomActive:(BOOL)autozoomActive {
    _isCameraAutoZoomActive = autozoomActive;
    
    if (_camera == nil) {
        return;
    }
    
    [_camera setAutoZoomActive:autozoomActive];
}

- (void)setMeasurementSystem:(MeasurementSystem)measurementSystem {
    _measurementSystem = measurementSystem;
    _callouts.measurementSystem = measurementSystem;
    
    if (_tapDistanceMarker) {
        _tapDistanceMarker.measurementSystem = measurementSystem;
    }
    
    for (DistanceMarker* marker in _markerList) {
        marker.measurementSystem = measurementSystem;
    }
    
    [self sendDistances];
    
    [self startDrawing];
}

-(void)setDrawingEnabled:(BOOL)isEnabled {
    _enableDrawing = isEnabled;
    
    if (isEnabled)
        [self performDraw:true];
}

- (void)setOverallHoleViewAngle:(double)overallHoleViewAngle {
    
    if (overallHoleViewAngle > 30 && overallHoleViewAngle < 75) {
        _overallHoleViewAngle = overallHoleViewAngle;
        _camera.overallHoleViewAngle = _overallHoleViewAngle;
        [self startDrawing];
    }
}

- (void)setFlyoverViewAngle:(double)flyoverViewAngle {
    
    if (flyoverViewAngle > 30 && flyoverViewAngle < 75) {
        _flyoverViewAngle = flyoverViewAngle;
        _camera.flyoverViewAngle = _flyoverViewAngle;
        [self startDrawing];
    }
}

- (void)setFreeCamViewAngle:(double)freeCamViewAngle {
    if (freeCamViewAngle > 30 && freeCamViewAngle < 75) {
        _freeCamViewAngle = freeCamViewAngle;
        _camera.freeCamViewAngle = freeCamViewAngle;
        [self startDrawing];
    }
    
}




- (double)CalloutOverlapThreshold {
    if(_camera.parValue != nil){
        switch (_camera.parValue) {
            case 0:
                return 0.2;
                break;
            case 3:
                return 0.27;
                break;
            case 4:
                return 0.12;
                break;
            case 5:
                return 0.1;
                break;
            case 6:
                return 0.1;
                break;
            default:
                return 0.2;
                break;
        }
    }
    return 0.2;
}

- (NSUInteger)currentHole {
    
    return _holeIndex + 1;
}


- (NavigationMode)navigationMode {
    
    return _camera.navigationMode;
}

-(CGPoint)flagScreenCoorinatePoint {
    
    return [GLHelper getObjectScreenCoordinate:_flag.flagPosition camera:_camera];
}

-(void)setShowCartGpsPosition:(BOOL)showCartGpsPosition {
    _isCartMarkerVisible = showCartGpsPosition;
    [self startDrawing];
}

-(BOOL)showCalloutOverlay {
    return _callouts.showOverlay;
}



-(BOOL)autozoomActive {
    return _camera.isAutozoomActive;
}



-(BOOL)showCartGpsPosition {
    return _isCartMarkerVisible;
}


- (NSUInteger)holeWithin {
    return _holeWithin;
}

- (BOOL)currentLocationVisible {
    return _camera.currentLocationVisible;
}


/*
 -(void)setFreeCamViewAngle:(double)freeCamViewAngle {
 _freeCamViewAngle = freeCamViewAngle;
 _camera.freeCamViewAngle = _freeCamViewAngle;
 [self startDrawing];
 }
 
 
 -(void)setGreenViewViewAngle:(double)greenViewViewAngle {
 _greenViewViewAngle = greenViewViewAngle;
 _camera.greenViewViewAngle = greenViewViewAngle;
 [self startDrawing];
 }
 */

- (void)applicationWillResignActive {
    
    if (_camera.navigationMode == NavigationModeFlyover) {
        _camera.navigationMode = NavigationModeFlyoverPause;
    }
    
    [self invalidateTimer];
    
    _isApplicationActive = false;
}

- (void)applicationDidBecomeActive {
    
    _isApplicationActive = true;
    
    if (_currentLocation != nil) {
        [self processNewLocation: _currentLocation];
    }
    
    [self setupTimer];
    
    [self draw];
}



- (void)onTimerTick {
    
    [self draw];
    [_camera tickWithCallback:true andEffect:_effect];
}

- (void)startDrawing {
    _redraw = true;
}

- (void)stopDrawing {
    _redraw = false;
}

- (void)draw {
    if (self == NULL) {
        return;
    }
    if (!_isApplicationActive) {
        return;
    }
    if (_enableDrawing && _redraw) {
        [self invalidateTimer];
        [self performDraw:true];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self draw];
        });
        
    } else {
        if (_timer == nil && !_isInvalidated) {
            [self setupTimer];
        }
    }
    
    if (tapMarkerCreateDate != nil) {
        
        if (_isApplicationActive) {
            
            if([[[NSDate alloc] init]timeIntervalSinceDate:tapMarkerCreateDate] > 7) {
                _tapDistanceMarker = nil;
                
                tapMarkerCreateDate = nil;
                
                [self performDraw:true];
            }
        }
    }
}

- (void)performDraw:(BOOL)present {
    if (_isApplicationActive == false) {
        return;
    }
    if (_camera == nil) {
        return;
    }
    [_camera updateFrustum];
    [_camera tickWithCallback:false andEffect:_effect];
    _effect.transform.modelviewMatrix = _camera.modelViewMatrix;
    _effect.transform.projectionMatrix = _camera.projectionMatrix;
    [_effect prepareToDraw];
    
    
//    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
//    glEnable(GL_SCISSOR_TEST);
//    glScissor([self getCurrentOffset:[self shouldUsePercentageWidth]], 0, [self getCurrentWidth:[self shouldUsePercentageWidth]], [self getCurrentHeight]);
//    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glDisable(GL_SCISSOR_TEST);
//    glGetError();
    if ([self navigationMode] == NavigationMode2DView && _viewCartActive == true) {
        [self render2DViewCart];
    } else if ([self navigationMode] == NavigationMode2DView || [self navigationMode] == NavigationMode2DGreenView) {
        [self render2D];
    } else {
        if (_grid) {
            //[self render3DWithElevations];
            [self render3DWithElevationsAnd3DBunkers];
        } else {
            [self render3D];
        }
    }
    if (present) {
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
    }
    if (_shouldSendFlagScreenPointCoordinate) {
        if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidUpdateFlagScreenPoint:")]) {
            [delegate courseRenderViewDidUpdateFlagScreenPoint:[self flagScreenCoorinatePoint]];
        }
    }
    
    if ([self navigationMode] != NavigationModeFlyover) {
        [self stopDrawing];
    }
}

- (void)render2D {
    [_perimeterLayer enableDrawing];
    
    [_groud renderWithEffect:_effect using2DTexture:true isFlyover:[_camera isFlyover]];
    
    [self enableStencilMaskIfNeeded:_camera.frustum];
    
    for (Layer* layer in _layerList) {
        if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
            [self disableStencilTest];
        }
        [layer renderWithEffect:_effect andFrustum:_camera.frustum];
        if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
            [self enableStencilTest];
        }
    }
    
    for (CartPath* cartPath in _cartPathList) {
        [cartPath renderWithEffect:_effect andFrustum:_camera.frustum];
    }
    
    [self disableStencilMaskIfNeeded];
    
    NSArray* shapes = [dataSource renderViewShapesForHole: self.currentHole];
    
    for (V3DShape* shape in shapes) {
        [shape renderWithEffect:_effect];
    }
    
    double treeScale = [self calculateTreeScale];
    
    for (Tree* tree in _treeList) {
        tree.scale = treeScale;
        [tree calculatePositionWithCamera:_camera];
    }
    
    //    [_flag renderWithEffect:_effect andCamera:_camera];
    
    [_frontGreenMarker renderWithEffect:_effect andCamera:_camera];
    [_backGreenMarker renderWithEffect:_effect andCamera:_camera];
    
    if([_camera lastZoomDate] == nil){
        _greenViewCursor.position = _greenCenterLayer.pointList.firstObject.pointList.firstObject;
    }
    [_greenViewCursor renderWithEffect:_effect andCamera:_camera];
    
    [_treeList sortUsingComparator:^NSComparisonResult(Tree* lhs, Tree* rhs) {
        return lhs.yPosition < rhs.yPosition;
    }];
    
    for (Tree* tree in _treeList) {
        [tree drawTreeWithEffect:_effect andCamera:_camera];
        [tree drawShadowWithEffect:_effect andCamera:_camera];
    }
    
    if (_camera.navigationMode == NavigationMode2DView) {
        [_callouts renderWithEffect:_effect andCamera:_camera];
    }
}

- (void)render2DViewCart {
    [_perimeterLayer enableDrawing];
    
    [_groud renderWithEffect:_effect using2DTexture:true isFlyover:[_camera isFlyover]];
    
    [self enableStencilMaskIfNeeded:_camera.frustum];
    
    for (Layer* layer in _layerList) {
        if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
            [self disableStencilTest];
        }
        [layer renderWithEffect:_effect andFrustum:_camera.frustum];
        if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
            [self enableStencilTest];
        }
    }
    
    for (CartPath* cartPath in _cartPathList) {
        [cartPath renderWithEffect:_effect andFrustum:_camera.frustum];
    }
    
    [self disableStencilMaskIfNeeded];
    
    NSArray* shapes = [dataSource renderViewShapesForHole: self.currentHole];
    
    for (V3DShape* shape in shapes) {
        [shape renderWithEffect:_effect];
    }
    
    double treeScale = [self calculateTreeScale];
    
    for (Tree* tree in _treeList) {
        tree.scale = treeScale;
        [tree calculatePositionWithCamera:_camera];
    }
    
    [_flag renderWithEffect:_effect andCamera:_camera];
    
    [_treeList sortUsingComparator:^NSComparisonResult(Tree* lhs, Tree* rhs) {
        return lhs.yPosition < rhs.yPosition;
    }];
    
    for (Tree* tree in _treeList) {
        [tree drawTreeWithEffect:_effect andCamera:_camera];
        [tree drawShadowWithEffect:_effect andCamera:_camera];
    }
    
    for (CartPositionMarker* marker in _cartPositionMarkerList) {
        [marker renderWithCamera:_camera andEffect:_effect];
    }
}

- (void)render3D {
    
    //    if (_textureType == TextureTypeRough) {
    //        [_perimeterLayer disableDrawing];
    //    } else if (_textureType == TextureTypeMixedDesert) {
    //        [_perimeterLayer enableDrawing];
    //    } else if (_textureType == TextureTypeDesert) {
    //        [_perimeterLayer disableDrawing];
    //    }
    
    [_skyGradient renderWithEffect:_effect andIsFlyover:[_camera isFlyover]];
    [_skyClouds renderWithEffect:_effect andIsFlyover:[_camera isFlyover]];
    
    [_groud renderWithEffect:_effect using2DTexture:false isFlyover:[_camera isFlyover]];
    [_perimeterLayer enableDrawing];
    
    [self calculateMarkersOverlapping];
    
    [self enableStencilMaskIfNeeded:_camera.frustum];
    
    for (Layer* layer in _layerList) {
        if([layer isKindOfClass:Layer.class] &&layer.isWaterLayer == true){
            [self disableStencilTest];
        }
        [layer renderWithEffect:_effect andFrustum:_camera.frustum];
        if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
            [self enableStencilTest];
        }
    }
    
    for (CartPath* cartPath in _cartPathList) {
        [cartPath renderWithEffect:_effect andFrustum:_camera.frustum];
    }
    
    [self disableStencilMaskIfNeeded];
    
    NSArray* shapes = [dataSource renderViewShapesForHole: self.currentHole];
    
    for (V3DShape* shape in shapes) {
        [shape renderWithEffect:_effect];
    }
    
    double treeScale = [self calculateTreeScale];
    
    for (Tree* tree in _treeList) {
        tree.scale = treeScale;
        [tree drawShadowWithEffect:_effect andCamera:_camera];
        [tree calculatePositionWithCamera:_camera];
    }
    
    [self updateMarkersScaling];
    
    for (DistanceMarker* marker in _markerList) {
        [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
    }
    
    for (Tree* tree in _treeList) {
        [tree drawTreeWithEffect:_effect andCamera:_camera];
    }
    
    for (DistanceMarker* marker in _markerListBeforeFlag) {
        [marker renderWithEffect:_effect andCamera:_camera];
    }
    
    if(_centralPathMarkers != nil){
        for (DistanceMarker* marker in _centralPathMarkers) {
            
            glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
            [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
            [marker renderWithEffect:_effect andCamera:_camera];
        }
    }
    if(_dogLegMarker != nil){
        glDepthFunc(_dogLegMarker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [_dogLegMarker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [_dogLegMarker renderWithEffect:_effect andCamera:_camera];
    }
    
    if (_tapDistanceMarker != nil) {
        [_tapDistanceMarker renderGroundMarkerWithEffect:_effect andCamera:_camera];
    }
    
    
    [_flag renderWithEffect:_effect andCamera:_camera];
    
    for (DistanceMarker* marker in _markerListAfterFlag) {
        [marker renderWithEffect:_effect andCamera:_camera];
    }
    
    if (_tapDistanceMarker != nil) {
        [_tapDistanceMarker renderWithEffect:_effect andCamera:_camera];
    }
    
    if (_isCartMarkerVisible) {
        _cart.location = self.currentLocation;
        //        [_cart renderWithEffect:_effect andCamera:_camera];
    }
    
    if(_lineToFlag!= NULL && _draw3DCentralPath == true){
        [_lineToFlag renderWithEffect:_effect andCamera:_camera];
    }
    
    [_treeList sortUsingComparator:^NSComparisonResult(Tree* lhs, Tree* rhs) {
        return lhs.yPosition < rhs.yPosition;
    }];
    
    
}

-(void)render3DWithElevations {
    
    double treeScale = [self calculateTreeScale];
    
    for (Tree* tree in _treeList) {
        tree.scale = treeScale;
        
        [tree calculatePositionWithCamera:_camera];
    }
    
    if (_textureType == TextureTypeRough) {
        [_perimeterLayer disableDrawing];
    } else if (_textureType == TextureTypeMixedDesert) {
        [_perimeterLayer enableDrawing];
    } else if (_textureType == TextureTypeDesert) {
        [_perimeterLayer disableDrawing];
    }
    
    
    NSArray* tiles = [_grid getTilesForRedraw];
    
    if (tiles.count > 0) {
        [self captureTexturesForTiles:tiles andDisabledLayers:@""];
        
        _effect.transform.modelviewMatrix = _camera.modelViewMatrix;
        _effect.transform.projectionMatrix = _camera.projectionMatrix;
        [_effect prepareToDraw];
        
        [self normalizeBuffers:[self shouldUsePercentageWidth]];
        
        [_grid clearRedrawTiles];
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
    }
    
    [_skyGradient renderWithEffect:_effect andIsFlyover:[_camera isFlyover]];
    [_skyClouds renderWithEffect:_effect andIsFlyover:[_camera isFlyover]];
    
    
    [_groud renderWithEffect:_effect using2DTexture:false isFlyover:[_camera isFlyover]];
    
    
    
    [_grid renderWithEffect:_effect andCamera:_camera andDepthFunk:GL_LEQUAL];
    
    
    
    [_grid renderTilesWithEffect:_effect andCamera:_camera];
    
    
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_LEQUAL);
    
    [_treeList sortUsingComparator:^NSComparisonResult(Tree* lhs, Tree* rhs) {
        return lhs.yPosition < rhs.yPosition;
    }];
    
    for (Tree* tree in _treeList) {
        [tree drawTreeWithEffect:_effect andCamera:_camera];
    }
    
    [self updateMarkersScaling];
    
    [self calculateMarkersOverlapping];
    
    
    
    for (DistanceMarker* marker in _markerListBeforeFlag) {
        
        glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [marker renderWithEffect:_effect andCamera:_camera];
    }
    
    if(_centralPathMarkers != nil){
        for (DistanceMarker* marker in _centralPathMarkers) {
            
            glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
            [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
            [marker renderWithEffect:_effect andCamera:_camera];
        }
    }
    if(_dogLegMarker != nil){
        glDepthFunc(_dogLegMarker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [_dogLegMarker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [_dogLegMarker renderWithEffect:_effect andCamera:_camera];
    }
    
    [_flag renderWithEffect:_effect andCamera:_camera];
    
    for (DistanceMarker* marker in _markerListAfterFlag) {
        
        glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [marker renderWithEffect:_effect andCamera:_camera];
    }
    
    
    
    glDepthFunc(GL_LEQUAL);
    
    if (_tapDistanceMarker != nil) {
        glDepthFunc(GL_ALWAYS);
        [_tapDistanceMarker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [_tapDistanceMarker renderWithEffect:_effect andCamera:_camera];
    }
    
    if (_isCartMarkerVisible) {
        _cart.location = self.currentLocation;
        [_cart renderWithEffect:_effect andCamera:_camera];
    }
    
    
    if(_lineToFlag != NULL && _draw3DCentralPath == true){
        [_lineToFlag renderWithEffect:_effect andCamera:_camera];
    }
    
    glDepthMask(GL_TRUE);
    glDisable(GL_DEPTH_TEST);
}


-(void)render3DWithElevationsAnd3DBunkers {
    NSArray<V3DShape*>* shapes = [dataSource renderViewShapesForHole: self.currentHole];
    if (_dataSourceChanged) {
        
        _dataSourceChanged = false;
        
        [_camera requestRedrawingTiles];
    }
    double treeScale = [self calculateTreeScale];
    for (Tree* tree in _treeList) {
        tree.scale = treeScale;
        
        [tree calculatePositionWithCamera:_camera];
    }
    
    [_perimeterLayer enableDrawing];
    NSArray* tiles = [_grid getTilesForRedraw];
    if (tiles.count > 0) {
        [self captureTexturesForTiles:tiles andDisabledLayers:@"Bunker Bunker_border Green"];
        _effect.transform.modelviewMatrix = _camera.modelViewMatrix;
        _effect.transform.projectionMatrix = _camera.projectionMatrix;
        [_effect prepareToDraw];
        
        [self normalizeBuffers:[self shouldUsePercentageWidth]];
        [_grid clearRedrawTiles];
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    glDisable(GL_STENCIL_TEST);
    glDisable(GL_DEPTH_TEST);
    
    [_skyGradient renderWithEffect:_effect andIsFlyover:[_camera isFlyover]];
    [_skyClouds renderWithEffect:_effect andIsFlyover:[_camera isFlyover]];
    
    [_groud renderWithEffect:_effect using2DTexture:false isFlyover:[_camera isFlyover]];
    glStencilMask(0xFF);
    
    glFrontFace(GL_CCW);
    glDisable(GL_CULL_FACE);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glEnable(GL_STENCIL_TEST);
    
    glStencilFuncSeparate(GL_FRONT, GL_ALWAYS, 1, 255);
    glStencilOpSeparate(GL_FRONT, GL_KEEP, GL_KEEP, GL_REPLACE);
    
    glStencilFuncSeparate(GL_BACK, GL_ALWAYS, 1, 255);
    glStencilOpSeparate(GL_BACK, GL_ZERO, GL_KEEP, GL_ZERO);
    for(Bunker3D* bunker in _bunkerList) {
        [bunker renderWithEffect:_effect andCamera:_camera andDepthFunc:GL_LESS];
    }
    glStencilFuncSeparate(GL_FRONT, GL_EQUAL, 0, 255);
    glStencilOpSeparate(GL_FRONT, GL_KEEP, GL_KEEP, GL_KEEP);
    
    glStencilFuncSeparate(GL_BACK, GL_ALWAYS, 0, 255);
    glStencilOpSeparate(GL_BACK, GL_KEEP, GL_KEEP, GL_REPLACE);
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    
    [_grid renderWithEffect:_effect andCamera:_camera andDepthFunk:GL_LESS];
    [_grid renderTilesWithEffect:_effect andCamera:_camera];
    [_grid renderBorderTilesWithEffect:_effect isFlyover:[_camera isFlyover]];
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    [_grid renderWithEffect:_effect andCamera:_camera andDepthFunk:GL_LESS];
    [_grid renderTilesWithEffect:_effect andCamera:_camera];
    [_grid renderBorderTilesWithEffect:_effect isFlyover:[_camera isFlyover]];
    glDisable(GL_CULL_FACE);
    glDisable(GL_STENCIL_TEST);
    
    if (shapes.count > 0) {
        [_grid additionalRenderTilesWithEffect:_effect andCamera:_camera];
    }
    
    glEnable(GL_DEPTH_TEST);
    
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_LEQUAL);
    
    [_treeList sortUsingComparator:^NSComparisonResult(Tree* lhs, Tree* rhs) {
        return lhs.yPosition < rhs.yPosition;
    }];
    for (Tree* tree in _treeList) {
        [tree drawTreeWithEffect:_effect andCamera:_camera];
    }
    
    [self updateMarkersScaling];
    
    [self calculateMarkersOverlapping];
    for (DistanceMarker* marker in _markerListBeforeFlag) {
        
        glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [marker renderWithEffect:_effect andCamera:_camera];
    }
    if(_centralPathMarkers != nil){
        for (DistanceMarker* marker in _centralPathMarkers) {
            
            glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
            [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
            [marker renderWithEffect:_effect andCamera:_camera];
        }
    }
    if(_dogLegMarker != nil){
        glDepthFunc(_dogLegMarker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [_dogLegMarker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [_dogLegMarker renderWithEffect:_effect andCamera:_camera];
    }
    [_flag renderWithEffect:_effect andCamera:_camera];
    
    for (PinMarker* maker in _pinMarkerList) {
        [maker renderWithEffect:_effect andCamera:_camera];
    }
    for (DistanceMarker* marker in _markerListAfterFlag) {
        
        glDepthFunc(marker.hasGroundMarker ? GL_ALWAYS : GL_LEQUAL);
        [marker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [marker renderWithEffect:_effect andCamera:_camera];
    }
    
    glDepthFunc(GL_LEQUAL);
    
    if (_tapDistanceMarker != nil) {
        glDepthFunc(GL_ALWAYS);
        [_tapDistanceMarker renderGroundMarkerWithEffect:_effect andCamera:_camera];
        [_tapDistanceMarker renderWithEffect:_effect andCamera:_camera];
        
    }
    if (_isCartMarkerVisible) {
        _cart.location = self.currentLocation;
        [_cart renderWithEffect:_effect andCamera:_camera];
    }
    glDisable(GL_DEPTH_TEST);
    if(_lineToFlag != NULL && _draw3DCentralPath == true){
        [_lineToFlag renderWithEffect:_effect andCamera:_camera];
    }
    glEnable(GL_DEPTH_TEST);
    
    glDepthMask(GL_TRUE);
    glDisable(GL_DEPTH_TEST);
}

- (void)captureTexturesForTiles:(NSArray*)tiles andDisabledLayers:(NSString*)disabledLayers {
    NSArray<V3DShape*>* shapes = [dataSource renderViewShapesForHole: self.currentHole];
    
    _effect.light0.enabled = false;
    
    [_effect prepareToDraw];
    for (DrawTile* t in tiles) {
        Frustum* frustum = [t captureTextureWithEffect:_effect andCamera:_camera];
        if (shapes.count > 0) {
            NSMutableArray<V3DShape*>* shapesToRender = [NSMutableArray new];
            
            for (V3DShape* shape in shapes) {
                if (CGRectIntersectsRect(t.boundingBox, shape.boundingBox)) {
                    [shapesToRender addObject:shape];
                }
            }
            
            [t prepareAdditionalBuffersForCapture];
            
            if (shapesToRender.count > 0) {
                
                for (V3DShape* shape in shapesToRender) {
                    [shape renderWithEffect:_effect];
                }
            }
        }
        [t prepareBuffersForCapture];
        [self render2DForTile:t withFrustum:frustum andPosition:t.getPosition andDisabledLayers:disabledLayers];
        [t endCapture];
    }
    [_grid clearRedrawTiles];
}

-(void)render2DForTile:(DrawTile*)tile withFrustum:(Frustum*)frustum andPosition:(Vector*)position andDisabledLayers:(NSString*)disabledLayers {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [_perimeterLayer enableDrawing];
    [self enableStencilMaskIfNeeded:frustum];
    for (Layer* layer in _layerList) {
        if (![disabledLayers containsString:layer.drawableId]) {
            
            if ([layer isKindOfClass:Layer.class]) {
                if(layer.isWaterLayer == true){
                    [self disableStencilTest];
                }
                if (CGRectIntersectsRect(layer.boundingBox, tile.boundingBox)) {
                    [layer renderWithEffect:_effect andFrustum:frustum];
                }
                if(layer.isWaterLayer == true){
                    [self enableStencilTest];
                }
            } else {
                [layer renderWithEffect:_effect andFrustum:frustum];
            }
        }
    }
    if (CGRectIntersectsRect(_greenLayer.boundingBox, tile.boundingBox)) {
        [_greenLayer renderWithEffect:_effect andFrustum:frustum];
    }
    for (Bunker3D* bunker in _bunkerList) {
        if (CGRectIntersectsRect(bunker.border.boundingBox, tile.boundingBox)) {
            [bunker.border renderWithEffect:_effect andFrustum:frustum];
        }
    }
    for (CartPath* cartPath in _cartPathList) {
        [cartPath renderWithEffect:_effect andFrustum:frustum];
    }
    for (Tree* tree in _treeList) {
        [tree drawShadowForPosition:position andEffect:_effect andFrustum:frustum];
    }
    [self disableStencilMaskIfNeeded];
    
}

-(void)render2DForTextureWithFrustum:(Frustum*)frustum andPosition:(Vector*)position andDisabledLayers:(NSString*)disabledLayers {
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    glEnable(GL_SCISSOR_TEST);
//    glScissor([self getCurrentOffset:[self shouldUsePercentageWidth]], 0, [self getCurrentWidth:[self shouldUsePercentageWidth]], [self getCurrentHeight]);
//    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glDisable(GL_SCISSOR_TEST);

    [_perimeterLayer enableDrawing];
    [self enableStencilMaskIfNeeded:frustum];
    [_perimeterLayer disableDrawing];
    
    for (Layer* layer in _layerList) {
        if (![disabledLayers containsString:layer.drawableId]) {
            if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
                [self disableStencilTest];
            }
            [layer renderWithEffect:_effect andFrustum:frustum];
            if([layer isKindOfClass:Layer.class] && layer.isWaterLayer == true){
                [self enableStencilTest];
            }
        }
    }
    
    [_greenLayer renderWithEffect:_effect andFrustum:frustum];
    
    for (Bunker3D* bunker in _bunkerList) {
        [bunker.border renderWithEffect:_effect andFrustum:frustum];
    }
    
    for (CartPath* cartPath in _cartPathList) {
        [cartPath renderWithEffect:_effect andFrustum:frustum];
    }
    
    for (Tree* tree in _treeList) {
        [tree drawShadowForPosition:position andEffect:_effect andFrustum:frustum];
    }
    
    [self disableStencilMaskIfNeeded];
    
}

-(void) enableStencilMaskIfNeeded:(Frustum*)frustum {
    if (_cutLayersByHolePerimeter == false){
        return;
    }
    glEnable(GL_STENCIL_TEST);
    glClearStencil(0);
    glStencilMask(0xFF);
    glClear(GL_STENCIL_BUFFER_BIT);
    glStencilFunc(GL_ALWAYS, 1, 1);
    glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
    
    [_perimeterLayer renderWithEffect:_effect andFrustum:frustum];
    
    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
}

-(void) disableStencilMaskIfNeeded {
    if (_cutLayersByHolePerimeter == false){
        return;
    }
    glDisable(GL_STENCIL_TEST);
}

-(void) disableStencilTest {
    if (_cutLayersByHolePerimeter == false){
        return;
    }
    glDisable(GL_STENCIL_TEST);
}

-(void) enableStencilTest {
    if (_cutLayersByHolePerimeter == false){
        return;
    }
    glEnable(GL_STENCIL_TEST);
}


-(void)dataSourceChanged {
    
    _dataSourceChanged = true;
    
    [self performDraw:true];
}


- (void)updateMarkersScaling {
    
    if (_camera.navigationMode != NavigationMode2DView && _camera.navigationMode != NavigationMode2DGreenView) {
        
        bool isFlyover = _camera.navigationMode == NavigationModeFlyover || _camera.navigationMode == NavigationModeFlyoverPause;
        bool isFreeCam = _camera.navigationMode == NavigationModeFreeCam;
        bool is3DGreenView = _camera.navigationMode == NavigationMode3DGreenView;
        
        if (_tapDistanceMarker != nil) {
            [_tapDistanceMarker calculateMatricesWithCamera:_camera];
            
            double tapDistanceScale = 20 * METERS_IN_POINT;
            
            if (isFlyover) {
                tapDistanceScale = 12 * METERS_IN_POINT;
            }
            
            if (isFreeCam) {
                tapDistanceScale = 15 * METERS_IN_POINT;
            }
            
            [_tapDistanceMarker scaleByPositionWithAdditionalScale:tapDistanceScale];
        }
        
        double distanceMarkerScale = 28 * METERS_IN_POINT;
        
        if (isFlyover) {
            distanceMarkerScale = 10 * METERS_IN_POINT;
        }
        
        if (isFreeCam) {
            distanceMarkerScale = 14 * METERS_IN_POINT;
        }
        
        if (is3DGreenView) {
            distanceMarkerScale = 10 * METERS_IN_POINT;
        }
        
        for (DistanceMarker *marker in _markerList) {
            [marker setScale:distanceMarkerScale];
        }
        for (DistanceMarker *marker in _centralPathMarkers) {
            [marker setScale:distanceMarkerScale];
        }
        if(_dogLegMarker != nil){
            [_dogLegMarker setScale:distanceMarkerScale];
        }
    }
}


- (Layer*)addLayerWithJsonObject:(NSDictionary*)jsonObject andLayerName:(NSString*)layerName {
    
    return [self addLayerWithJsonObject:jsonObject andLayerName:layerName andInterpolation:PointInterpolationInterpolate andExtend:0];
}

- (Layer*)addLayerWithJsonObject:(NSDictionary*)jsonObject andLayerName:(NSString*)layerName andInterpolation:(PointInterpolation)interpolation andExtend:(double)extend {
    
    Layer* layer = [self loadLayerWithJsonObject:jsonObject andLayerName:layerName andInterpolation:interpolation andExtend:extend];
    [self addLayer:layer];
    
    return layer;
}

- (Layer*)addBorderLayerWithJsonObject:(NSDictionary*)jsonObject andLayerName:(NSString*)layerName andInterpolation:(PointInterpolation)interpolation andExtend:(double)extend {
    
    Layer* layer = [self loadBorderLayerWithJsonObject:jsonObject
                                          andLayerName:layerName
                                      andInterpolation:interpolation
                                             andExtend:extend];
    
    [self addLayer:layer];
    return layer;
}

- (Layer*)loadLayerWithJsonObject:(NSDictionary*)jsonObject andLayerName:(NSString*)layerName andInterpolation:(PointInterpolation)interpolation andExtend:(double)extend {
    
    if ([jsonObject objectForKey:layerName] == nil) {
        return nil;
    }
    
    NSString* texturePath = [self texturePathFromLayerName:layerName];
    Layer* layer = [[Layer alloc] initWithJsonObject:[jsonObject objectForKey:layerName]
                                         andFilePath:texturePath
                                    andInterpolation:interpolation
                                           andExtend:extend];
    layer.drawableId = layerName;
    return layer;
}

- (Layer*)loadBorderLayerWithJsonObject:(NSDictionary*)jsonObject andLayerName:(NSString*)layerName andInterpolation:(PointInterpolation)interpolation andExtend:(double)extend {
    
    if ([jsonObject objectForKey:layerName] == nil) {
        return nil;
    }
    
    NSString* texturePath = [self borderTexturePathFromLayerName:layerName];
    Layer* layer = [[Layer alloc] initWithJsonObject:[jsonObject objectForKey:layerName]
                                         andFilePath:texturePath
                                    andInterpolation:interpolation
                                           andExtend:extend];
    layer.drawableId = [layerName stringByAppendingString:@"_border"];
    return layer;
}

- (void)addLayer:(Layer*)layer {
    if (layer != nil) {
        [_layerList addObject:layer];
    }
}

- (NSString*)texturePathFromLayerName:(NSString*)layerName {
    
    NSString* retval;
    
    if ([layerName isEqualToString:@"Perimeter"]) {
        retval = [[NSBundle mainBundle] pathForResource:_textureProfile.perimeterTextureName ofType:@"png"];
    } else if ([layerName isEqualToString:@"Fairway"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_fairway" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Bunker"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_bunker" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Green"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_green" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Sand"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_sand" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Lake"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_lake" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Lava"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_lava" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Ocean"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_ocean" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Pond"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_pond" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Water"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_pond" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Teebox"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_teebox" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Creek"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_creek" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Bridge"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_bridge" ofType:@"png"];
    }
    
    return retval;
}

- (NSString*)borderTexturePathFromLayerName:(NSString*)layerName {
    
    NSString* retval = nil;
    
    if ([layerName isEqualToString:@"Fairway"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_fairway_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Bunker"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_bunker_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Green"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_green_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Sand"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_sand_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Lake"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_lake_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Ocean"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_ocean_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Pond"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_pond_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Water"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_pond_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Teebox"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_teebox_border" ofType:@"png"];
    } else if ([layerName isEqualToString:@"Creek"]) {
        retval = [[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_creek_border" ofType:@"png"];
    }
    
    return retval;
}

- (void)loadTrees {
    
    NSArray<GLKTextureInfo*>* treeTextures = _usesEvergreenTreeTextureSet ? _textureProfile.getEvergreenTreeTextureSet : _textureProfile.getDefaultTreeTextureSet;
    NSArray<GLKTextureInfo*>* treeShadowTextures = _usesEvergreenTreeTextureSet ? _textureProfile.getEvergreenTreeShadowTextureSet : _textureProfile.getDefaultTreeShadowTextureSet;
    
    for (PointList* pointList in _treeLayer.pointList) {
        for (Vector* vector in pointList.pointList) {
            if (CGRectContainsPoint(_perimeterLayer.boundingBox, CGPointMake(vector.x, vector.y)) == NO) {
                continue;
            }
            
            int textureIndex = rand() % treeTextures.count;
            
            vector.z = [_grid getZForPointX:-vector.x andY:-vector.y];
            
            Tree* treeObject = [[Tree alloc] initWithTreeTexure3D:treeTextures[textureIndex] andShadowtexture:treeShadowTextures[textureIndex] andPosition:vector andVertexBuffer3D:_textureVertexBuffer3D andUVBuffer3D:_textureUVBuffer3D andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer];
            
            
            [_treeList addObject:treeObject];
        }
    }
}

- (void)loadDistanceMarkers {
    
    NSDictionary* gpsData = nil;
    
    for (int i = 0 ; i < _gpsDetailsData.count ; i++) {
        NSDictionary* data = _gpsDetailsData[i];
        if ([[data objectForKey:@"holeNumber"] intValue] == _holeIndex+1) {
            gpsData = data;
            break;
        }
    }
    
    _frontGreenMarker = [self loadDistanceMarkerWithGpsData:gpsData
                                                 andLatName:@"frontLat"
                                                 andLonName:@"frontLon"
                                  andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout_front_back" ofType:@"png"]
                                       andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_frontgreen_distance_target" ofType:@"png"]
                                           andTexture2DPath:[[NSBundle mainBundle] pathForResource:@"v2d_frontgreen_distance_target" ofType:@"png"] andMarkerType:0];
    [self addHoleObjectToDestroy:_frontGreenMarker];
    
    _backGreenMarker = [self loadDistanceMarkerWithGpsData:gpsData
                                                andLatName:@"backLat"
                                                andLonName:@"backLon"
                                 andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout_front_back" ofType:@"png"]
                                      andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_backgreen_distance_target" ofType:@"png"]
                                          andTexture2DPath:[[NSBundle mainBundle] pathForResource:@"v2d_backgreen_distance_target" ofType:@"png"] andMarkerType:0];
    [self addHoleObjectToDestroy:_backGreenMarker];
    
    DistanceMarker* marker = nil;
    marker = [self loadDistanceMarkerWithGpsData:gpsData andLatName:@"customLat1" andLonName:@"customLon1"
                            andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]
                       andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"] andMarkerType:1];
    [self addHoleObjectToDestroy:marker];
    
    marker = [self loadDistanceMarkerWithGpsData:gpsData andLatName:@"customLat2" andLonName:@"customLon2"
                            andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]
                       andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"] andMarkerType:1];
    [self addHoleObjectToDestroy:marker];
    
    marker = [self loadDistanceMarkerWithGpsData:gpsData andLatName:@"customLat3" andLonName:@"customLon3"
                            andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]
                       andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"] andMarkerType:1];
    [self addHoleObjectToDestroy:marker];
    
    marker = [self loadDistanceMarkerWithGpsData:gpsData andLatName:@"customLat4" andLonName:@"customLon4"
                            andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]
                       andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"]andMarkerType:1];
    [self addHoleObjectToDestroy:marker];
}

- (void)addAdditionalHazardForDogLegHoles {
    if(_dogLegMarker!= nil)
        [_dogLegMarker destroy];
    _dogLegMarker = nil;
    if (_centralPathLayer == nil || _greenLayer == nil || _centralPathLayer.pointList == nil || _centralPathLayer.pointList.count == 0 || _centralPathLayer.pointList.firstObject.pointList == nil){
        return;
    }
    NSMutableArray<Vector*>* pointListArray = _centralPathLayer.pointList.firstObject.pointList;
    for(Vector* point in pointListArray){
        CLLocation* l = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:point.y] longitude:[Layer transformToLonWithDouble:point.x]];
    }
    pointListArray = [self deleteRedudantPointsInCentralPath:pointListArray andGreen: _greenLayer];
    for(Vector* point in pointListArray){
        CLLocation* l = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:point.y] longitude:[Layer transformToLonWithDouble:point.x]];
    }
    if(pointListArray.count <= 2){
        return;
    }
    
    if (pointListArray.count == 3){
        double angle = [VectorMath angleWithVector1:pointListArray[0] andVector2:pointListArray[1] andVector3:pointListArray[2]];
        angle = [VectorMath rad2degWithRad:angle];
        if (angle < 0) {
            angle += 360;
        }
        if (angle < 150.0 && angle > 30) {
            CLLocation* location = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:pointListArray[1].y] longitude:[Layer transformToLonWithDouble:pointListArray[1].x]];
            
            _dogLegMarker = [self loadDistanceMarkerWithLocationSimple:location andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"] andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]];
        }
    } else {
        
        Vector* line1Start = pointListArray[0];
        Vector* line1End = pointListArray[1];
        
        Vector* line2Start = pointListArray[pointListArray.count-2];
        Vector* line2End = pointListArray[pointListArray.count-1];
        
        Line* lineA = [[Line alloc] initWithP1:line1Start andP2:line1End];
        Line* lineB = [[Line alloc] initWithP1:line2Start andP2:line2End];
        
        Vector* intersection = [VectorMath intersectionWithLineA:lineA andLineB:lineB];
        
        if(intersection == nil)
            return;
        
        double angle = [VectorMath angleWithVector1:lineA.p1 andVector2:intersection andVector3:lineB.p2];
        angle = [VectorMath rad2degWithRad:angle];
        
        if (angle < 0) {
            angle += 360;
        }
        if (angle < 150.0 && angle > 30) {
            NSArray<Vector*>* arr =[Interpolator interpolateWithCoordinateArray:pointListArray andPointsPerSegment:10 andCurveType:CatmullRomTypeCentripetal];
            double minDistance = fabs([VectorMath distanceWithVector1:intersection andVector2:arr[0]]);
            Vector* closest = arr[0];
            
            for (Vector* vector in arr) {
                double d = fabs([VectorMath distanceWithVector1:intersection andVector2:vector]);
                if(d < minDistance){
                    minDistance = d;
                    closest = vector;
                }
            }
            
            CLLocation* location = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:closest.y] longitude:[Layer transformToLonWithDouble:closest.x]];
            
            _dogLegMarker = [self loadDistanceMarkerWithLocationSimple:location andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"] andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]];
        }
        
        
    }
    
    [self addHoleObjectToDestroy:_dogLegMarker];
}

- (NSMutableArray<Vector*>*) deleteRedudantPointsInCentralPath: (NSMutableArray<Vector*>*) centralPathList andGreen:(Layer*) green {
    NSMutableArray<Vector*>* updatedList = [NSMutableArray new];
    Vector* point;
    for (int i = 0; i < (int)centralPathList.count - 1; i++) {
        point = centralPathList[i];
        if (![self greenContainsRedundantPoint: point andBoundingBox: green.getExtremeBox]){
            [updatedList addObject:point];
        }
    }
    [updatedList addObject:centralPathList[(int)centralPathList.count -1]];
    return updatedList;
}

- (BOOL) greenContainsRedundantPoint: (Vector*) point andBoundingBox:(NSMutableArray<Vector*>*) points {
    int i;
    int j;
    BOOL result = false;
    for (i = 0, j = (int)points.count - 1; i < points.count; j = i++) {
        if ((points[i].y > point.y) != (points[j].y > point.y) &&
            (point.x < (points[j].x - points[i].x) * (point.y - points[i].y) / (points[j].y - points[i].y) + points[i].x)) {
            result = !result;
        }
    }
    return result;
}

- (void)addCentralPathHazards {
    if(_centralPathMarkers != nil){
        for(DistanceMarker* marker in _centralPathMarkers){
            marker.destroy;
        }
        _centralPathMarkers.removeAllObjects;
        _centralPathMarkers = nil;
    }
    _centralPathMarkers = [NSMutableArray new];
    NSMutableArray<Vector*>* pointListArray = _centralPathLayer.pointList.firstObject.pointList;
    pointListArray = [self deleteRedudantPointsInCentralPath:pointListArray andGreen: _greenLayer];
//    pointListArray = [Interpolator interpolateWithCoordinateArray:pointListArray andPointsPerSegment:10 andCurveType:CatmullRomTypeCentripetal];
    
    
    DistanceMarker* marker = nil;
    
    for (int i = 0; i < pointListArray.count; i++) {
        if(i == 0|| i == (int)pointListArray.count -1)
            continue;
//
        CLLocation* location = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:pointListArray[i].y] longitude:[Layer transformToLonWithDouble:pointListArray[i].x]];
        
        marker = [self loadDistanceMarkerWithLocationSimple:location andCalloutTextureFileName:[[NSBundle mainBundle] pathForResource:@"v3d_gpsmap_callout" ofType:@"png"] andGroundTexturePath:[[NSBundle mainBundle] pathForResource:@"v3d_hazard_backgroud" ofType:@"png"]];
        [self addHoleObjectToDestroy:marker];
        [_centralPathMarkers addObject:marker];
        
    }
}

- (DistanceMarker*)loadDistanceMarkerWithGpsData:(NSDictionary*)gpsData andLatName:(NSString*)latName andLonName:(NSString*)lonName andGroundTexturePath:(NSString*)groundTexturePath andCalloutTextureFileName:(NSString*)calloutTextureFileName andMarkerType:(int) type {
    
    NSNumber* lat = [gpsData objectForKey:latName];
    NSNumber* lon = [gpsData objectForKey:lonName];
    
    if (lat == nil || lon == nil) {
        return nil;
    }
    
    double latValue = [lat doubleValue];
    double lonValue = [lon doubleValue];
    
    if (latValue == 0 && lonValue == 0) {
        return nil;
    }
    
    DistanceMarker* retval = [[DistanceMarker alloc] initWithGroundTextureFilename:groundTexturePath andCalloutTextureFileName:calloutTextureFileName andtexture2DFileName:nil andLocation:[[CLLocation alloc] initWithLatitude:latValue longitude:lonValue] andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationGrid:_grid andMarkerType:type];
    retval.measurementSystem = self.measurementSystem;
    
    [_markerList addObject:retval];
    return retval;
}

- (DistanceMarker*)loadDistanceMarkerWithGpsData:(NSDictionary*)gpsData andLatName:(NSString*)latName andLonName:(NSString*)lonName andCalloutTextureFileName:(NSString*)calloutTextureFileName andGroundTexturePath:(NSString*)groundTexturePath andTexture2DPath:(NSString*)texture2DPath andMarkerType: (int) type {
    
    NSNumber* lat = [gpsData objectForKey:latName];
    NSNumber* lon = [gpsData objectForKey:lonName];
    
    if (lat == nil || lon == nil) {
        return nil;
    }
    
    double latValue = [lat doubleValue];
    double lonValue = [lon doubleValue];
    
    if (latValue == 0 && lonValue == 0) {
        return nil;
    }
    
    DistanceMarker* retval = [[DistanceMarker alloc] initWithGroundTextureFilename:groundTexturePath andCalloutTextureFileName:calloutTextureFileName andtexture2DFileName:texture2DPath andLocation:[[CLLocation alloc] initWithLatitude:latValue longitude:lonValue] andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationGrid:_grid andMarkerType: type];
    retval.measurementSystem = self.measurementSystem;
    
    [_markerList addObject:retval];
    return retval;
}

- (DistanceMarker*)loadDistanceMarkerWithLocation:(CLLocation*)location andCalloutTextureFileName:(NSString*)calloutTextureFileName andGroundTexturePath:(NSString*)groundTexturePath andTexture2DPath:(NSString*)texture2DPath  {
    
    double latValue = location.coordinate.latitude;
    double lonValue = location.coordinate.longitude;
    
    if (latValue == 0 && lonValue == 0) {
        return nil;
    }
    
    
    
    DistanceMarker* retval = [[DistanceMarker alloc] initWithGroundTextureFilename:groundTexturePath andCalloutTextureFileName:calloutTextureFileName andtexture2DFileName:texture2DPath andLocation:[[CLLocation alloc] initWithLatitude:latValue longitude:lonValue] andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationGrid:_grid andMarkerType: 1];
    retval.measurementSystem = self.measurementSystem;
    
    [_markerList addObject:retval];
    return retval;
}

- (DistanceMarker*)loadDistanceMarkerWithLocationSimple:(CLLocation*)location andCalloutTextureFileName:(NSString*)calloutTextureFileName andGroundTexturePath:(NSString*)groundTexturePath {
    
    double latValue = location.coordinate.latitude;
    double lonValue = location.coordinate.longitude;
    
    if (latValue == 0 && lonValue == 0) {
        return nil;
    }
    
    
    
    DistanceMarker* retval = [[DistanceMarker alloc] initWithGroundTextureFilename:groundTexturePath andCalloutTextureFileName:calloutTextureFileName andtexture2DFileName:nil andLocation:[[CLLocation alloc] initWithLatitude:latValue longitude:lonValue] andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer andElevationGrid:_grid andMarkerType: 1];
    retval.measurementSystem = self.measurementSystem;
    return retval;
}

- (void)calculateMarkersOverlapping {
    
    [_flag calculateMatricesWithCamera:_camera];
    [_markerListBeforeFlag removeAllObjects];
    [_markerListAfterFlag removeAllObjects];
    
    for (DistanceMarker* marker in _markerList) {
        marker.currentLocation = self.currentLocation;
        marker.measurementSystem = self.measurementSystem;
        [marker calculateMatricesWithCamera:_camera];
    }
    
    if (_tapDistanceMarker) {
        _tapDistanceMarker.currentLocation = self.currentLocation;
//        [_tapDistanceMarker setCenterLocation:_flag.location andCurrentLocation:self.currentLocation];
        _tapDistanceMarker.measurementSystem = self.measurementSystem;
    }
    
    if(_dogLegMarker!= nil){
        _dogLegMarker.currentLocation = self.currentLocation;
        _dogLegMarker.measurementSystem = self.measurementSystem;
        [_dogLegMarker calculateMatricesWithCamera:_camera];
    }
    
    if(_centralPathMarkers != nil){
        for (DistanceMarker* marker in _centralPathMarkers) {
            marker.currentLocation = self.currentLocation;
            marker.measurementSystem = self.measurementSystem;
            [marker calculateMatricesWithCamera:_camera];
        }
        
        [_centralPathMarkers sortUsingComparator:^NSComparisonResult(DistanceMarker* lhs, DistanceMarker* rhs) {
            return rhs.zPosition < lhs.zPosition;
        }];
    }
    
    [_markerList sortUsingComparator:^NSComparisonResult(DistanceMarker* lhs, DistanceMarker* rhs) {
        return rhs.zPosition < lhs.zPosition;
    }];
    
    for (DistanceMarker* marker in _markerList) {
        if (marker.zPosition > _flag.zPosition) {
            [_markerListAfterFlag addObject:marker];
        } else {
            [_markerListBeforeFlag addObject:marker];
        }
    }
    
    Vector* cameraPoint = [[Vector alloc] initWithX:-_camera.cameraPoint.x andY:-_camera.cameraPoint.y];
    double distanceToFront = [_frontGreenMarker.markerPosition distanceWithVector:cameraPoint];
    double distanceToBack = [_backGreenMarker.markerPosition distanceWithVector:cameraPoint];
    double distance = [_backGreenMarker.projectedPosition distanceWithVector:_frontGreenMarker.projectedPosition];
    if(distanceToFront < distanceToBack){
        _frontGreenMarker.visible = true;
        _backGreenMarker.visible = distance >= self.CalloutOverlapThreshold;
    } else {
        _backGreenMarker.visible = true;
        _frontGreenMarker.visible = distance >= self.CalloutOverlapThreshold;
    }
    
    for (int i = 0 ; i < _markerList.count ; i++) {
        DistanceMarker* marker = _markerList[i];
        
        if (marker == _backGreenMarker || marker == _frontGreenMarker) {
            continue;
        }
        
        double distanceToFront = _frontGreenMarker.visible ? [marker.projectedPosition distanceWithVector:_frontGreenMarker.projectedPosition] : 999.0;
        double distanceToBack = _backGreenMarker.visible ? [marker.projectedPosition distanceWithVector:_backGreenMarker.projectedPosition] : 999.0;
        double distanceToPrev = 999.0;
        
        if (i > 0) {
            distanceToPrev = [marker.projectedPosition distanceWithVector:_markerList[i-1].projectedPosition];
        }
        
        marker.visible = distanceToFront >= self.CalloutOverlapThreshold && distanceToBack >= self.CalloutOverlapThreshold && distanceToPrev >= self.CalloutOverlapThreshold;
    }
    
    if(_dogLegMarker != nil && _drawDogLegMarker){
        double distanceToFront = _frontGreenMarker.visible ? [_dogLegMarker.projectedPosition distanceWithVector:_frontGreenMarker.projectedPosition] : 999.0;
        double distanceToBack = _backGreenMarker.visible ? [_dogLegMarker.projectedPosition distanceWithVector:_backGreenMarker.projectedPosition] : 999.0;
        _dogLegMarker.visible = distanceToFront >= self.CalloutOverlapThreshold && distanceToBack >= self.CalloutOverlapThreshold;
    }else {
        if(_dogLegMarker != nil){
            _dogLegMarker.visible = false;
        }
    }
    if(_centralPathMarkers != nil){
        for (int i = 0 ; i < _centralPathMarkers.count ; i++) {
            DistanceMarker* marker = _centralPathMarkers[i];
            
            double distanceToFront = _frontGreenMarker.visible ? [marker.projectedPosition distanceWithVector:_frontGreenMarker.projectedPosition]: 999.0;
            double distanceToBack = _backGreenMarker.visible ? [marker.projectedPosition distanceWithVector:_backGreenMarker.projectedPosition] : 999.0;
            double distanceToPrev = 999.0;
            
            if (i > 0) {
                distanceToPrev = [marker.projectedPosition distanceWithVector:_centralPathMarkers[i-1].projectedPosition];
            }
            
            marker.visible = distanceToFront >= self.CalloutOverlapThreshold && distanceToBack >= self.CalloutOverlapThreshold && _drawCentralPathMarkers;
        }
    }
}

- (double)calculateTreeScale {
    return 20 * METERS_IN_POINT;
}

- (void)addCourseObjectToDestroy:(id)object {
    
    if (object != nil) {
        [_courseObjectsToDestroy addObject:object];
    }
}

- (void)addHoleObjectToDestroy:(id)object {
    
    if (object != nil) {
        [_holeObjectsToDestroy addObject:object];
    }
}


- (void)cameraFlyoverFinished {
    
    [self setNavigationMode:_initialNavigationMode];
    [self cameraRequiresDraw];
    
    [[NSNotificationCenter defaultCenter]postNotification:CourseRenderView.flyoverFinishedNotification];
    
    if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewFlyoverFinished")])
        [delegate courseRenderViewFlyoverFinished];
}

- (void)cameraDidChangeNavigationMode:(NavigationMode)navigationMode {
    
    if (!_initialHoleLoad) {
        [[NSNotificationCenter defaultCenter]postNotification:CourseRenderView.navigationModeDidChangeNotification];
        
        if ([delegate respondsToSelector:NSSelectorFromString(@"courseRenderViewDidChangeNavigationMode:")])
            [delegate courseRenderViewDidChangeNavigationMode:navigationMode];
    }
}

-(void)cameraRequiresDraw {
    
    if (self == NULL) {
        return;
    }
    
    [self performDraw:true];
}

-(CGPoint)flagScreenPoint {
    return [self flagScreenCoorinatePoint];
}

-(void)setShouldSendFlagScreenPointCoordinate:(BOOL)shouldSendFlagScreenPointCoordinate {
    _shouldSendFlagScreenPointCoordinate = shouldSendFlagScreenPointCoordinate;
}

-(BOOL)shouldSendFlagScreenPointCoordinate {
    return _shouldSendFlagScreenPointCoordinate;
}

-(CLLocation *)flagLocation {
    
    return _flag.location;
}

-(BOOL)usesOverridedPinPosition {
    
    return _usesOverridedPinPosition;
}

-(void)removePinMarkers {
    [_pinMarkerList removeAllObjects];
}

-(void)addPinMarkerForPosition:(Vector *)position withColor:(PinMarkerColor)color {
    
    NSString* textureName = @"ic_pin_";
    
    switch (color) {
        case PinMarkerColorRed:
            textureName = [textureName stringByAppendingString:@"red"];
            break;
        case PinMarkerColorGreen:
            textureName = [textureName stringByAppendingString:@"green"];
            break;
        case PinMarkerColorYellow:
            textureName = [textureName stringByAppendingString:@"yellow"];
            break;
        case PinMarkerColorBlue:
            textureName = [textureName stringByAppendingString:@"blue"];
            break;
        case PinMarkerColorPurple:
            textureName = [textureName stringByAppendingString:@"purple"];
            break;
        default:
            break;
    }
    
    position.z = [_grid getZForPointX:-position.x andY:-position.y];
    
    [_pinMarkerList addObject:[[PinMarker alloc]initWithTextureFilename:[[NSBundle mainBundle] pathForResource:textureName ofType:@"png"] andPosition:position andVertexBuffer:_textureVertexBuffer andUVBuffer:_textureUVBuffer]];
}

-(NavigationMode)initialNavigationMode {
    return _initialNavigationMode;
}

-(BOOL)usesEvergreenTreeTextureSet {
    return _usesEvergreenTreeTextureSet;
}

-(void)setUsesEvergreenTreeTextureSet:(BOOL)usesEvergreenTreeTextureSet {
    _usesEvergreenTreeTextureSet = usesEvergreenTreeTextureSet;
}

-(void)addCartMarkerWithName:(NSString*)name andLocation:(CLLocation*)location andId:(int)cartId {
    
    CartPositionMarker* cartMarker = [[CartPositionMarker alloc] initWithCartName:name andId:cartId andLocation:location andUVBuffer:_textureUVBuffer andVertexbuffer:_textureVertexBuffer];
    
    [_cartPositionMarkerList addObject:cartMarker];
    
    [self performDraw:true];
}

-(void)updateCartMarkerWithId:(int)cartId newLocation:(CLLocation*)location {
    
    for (CartPositionMarker* marker in _cartPositionMarkerList) {
        if (marker.cartId == cartId) {
            [marker updateLocation:location];
        }
    }
    
    [self performDraw:true];
}

-(void)removeCartMarkerWithId:(int)cartId {
    
    CartPositionMarker* cartMarker;
    
    for (CartPositionMarker* marker in _cartPositionMarkerList) {
        if (marker.cartId == cartId) {
            cartMarker = marker;
        }
    }
    
    if (cartMarker != nil) {
        [_cartPositionMarkerList removeObject:cartMarker];
    }
    
    [self performDraw:true];
}

+(CourseRenderView *)shared {
    
    return _shared;
}

+(NSNotification *)navigationModeDidChangeNotification {
    
    if (_navigationModeDidChangeNotification == nil) {
        _navigationModeDidChangeNotification = [[NSNotification alloc] initWithName:@"com.l1.3DViewer.navigationModeDidChangeNotification" object:nil userInfo:nil];
    }
    
    return _navigationModeDidChangeNotification;
}

+(NSNotification *)flyoverFinishedNotification {
    
    if (_flyoverFinishedNotification == nil) {
        _flyoverFinishedNotification = [[NSNotification alloc] initWithName:@"com.l1.3DViewer.flyoverFinishedNotification" object:nil userInfo:nil];
    }
    
    return _flyoverFinishedNotification;
}

+(NSNotification *)didLoadCourseDataNotification {
    
    if (_didLoadCourseDataNotification == nil) {
        _didLoadCourseDataNotification = [[NSNotification alloc] initWithName:@"com.l1.3DViewer.didLoadCourseDataNotification" object:nil userInfo:nil];
    }
    
    return _didLoadCourseDataNotification;
}

+(NSNotification *)courseRenderViewReleasedNotification {
    
    if (_courseRenderViewReleasedNotification == nil) {
        _courseRenderViewReleasedNotification = [[NSNotification alloc] initWithName:@"com.l1.3DViewer.courseRenderViewReleasedNotification" object:nil userInfo:nil];
    }
    
    return _courseRenderViewReleasedNotification;
}

+(NSNotification *)didLoadHoleDataNotification {
    
    if (_didLoadHoleDataNotification == nil) {
        _didLoadHoleDataNotification = [[NSNotification alloc] initWithName:@"com.l1.3DViewer.didLoadHoleDataNotification" object:nil userInfo:nil];
    }
    
    return _didLoadHoleDataNotification;
}

- (void)releaseCourseData {
    
    for (id object in _courseObjectsToDestroy) {
        [object destroy];
    }
    
    [_courseObjectsToDestroy removeAllObjects];
}

- (void)releaseHoleData {
    
    for (id object in _holeObjectsToDestroy) {
        [object destroy];
    }
    
    [_holeObjectsToDestroy removeAllObjects];
}

- (void)invalidate {
    _shared        = nil;
    _isInvalidated = true;
    
    [self stopDrawing];
    [self invalidateTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
    
    _effect = nil;
    
    [self releaseHoleData];
    [self releaseCourseData];
    
    [_callouts destroy];
    [_greenViewCursor destroy];
    [_groud destroy];
    [_skyClouds destroy];
    [_skyGradient destroy];
    

    if(_lineToFlag != NULL){
        [_lineToFlag destroy];
    }
    
    [GLKTextureInfo releaseAll];
    [GLHelper deleteAllBuffers];
    
    [_grid clean];
    
    _grid   = nil;
    _camera = nil;
    
    [self tearDown];
    
    NSLog(@"iGolf Viewer 3D: INVALIDATED");
}

- (NSString *)getConfigurationValueForKey:(NSString *)key {
    
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"l1.IGolfViewer3D"];
    return [[bundle infoDictionary] valueForKey:key];
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] postNotification:CourseRenderView.courseRenderViewReleasedNotification];
    
    NSLog(@"iGolf Viewer 3D: RELEASED");
}

-(void) updateCameraViewportAndProjectionMatrix{
    if(_camera == nil){
        _camera = [[Camera alloc] init];
    }
    [_camera updateViewportAndProjectionMatrix:self andRenderWidthPercent:([self shouldUsePercentageWidth] ? _renderViewWidthPercent : 1)];
}

-(void) setRenderViewWidthPercent:(float)renderViewWidthPercent{
    _renderViewWidthPercent = renderViewWidthPercent;
    [self initializeDymamicWidth:_renderViewWidthPercent];
    [self updateCameraViewportAndProjectionMatrix];
    glEnable(GL_SCISSOR_TEST);
    glScissor(0, 0, [self getCurrentWidth:false], [self getCurrentHeight]);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glScissor([self getCurrentOffset:[self shouldUsePercentageWidth]], 0, [self getCurrentWidth:[self shouldUsePercentageWidth]], [self getCurrentHeight]);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDisable(GL_SCISSOR_TEST);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

-(float) renderViewWidthPercent {
    return _renderViewWidthPercent;
}


@end
