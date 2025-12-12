//
//  CourseDataLoader.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseRenderViewLoader.h"
#import "IGolfViewer3DPrivateImports.h"

@interface CourseRenderViewLoader() {
    
    V3DRest* _rest;
    NSString* _idCourse;
    NSString* _applicationAPIKey;
    NSString* _applicationSecretKey;
    UIView* _loadingView;
    
    CourseGPSVectorDetailsResponse* _courseGPSVectorDetailsResponseObject;
    CourseGPSDetailsResponse* _courseGPSDetailsResponseObject;
    CourseScorecardDetailsResponse* _courseScorecardDetailsResponseObject;
    CoursePinPositionDetailsResponse* _coursePinPositionDetailsResponseObject;
    CourseElevationDataDetailsResponse* _courseElevationDataDetailsResponseObject;
    NSDictionary* _courseElevationDataDetails;

    NSUInteger _hole;
    NavigationMode _initialNavigationMode;
    TextureQuality _textureQuality;
    CalloutsDrawMode _calloutsDrawMode;
    MeasurementSystem _measurementSystem;
    
    
    BOOL _cutLayersByHolePerimeter;
    BOOL _draw3DCentralPath;
    BOOL _drawDogLegMarker;
    BOOL _drawCentralPathMarkers;
    BOOL _areFrontBackMarkersDynamic;
    BOOL _autoAdvanceActive;
    BOOL _rotateHoleOnLocationChanged;
    BOOL _showCalloutOverlay;
    BOOL _isCartGPSPositionVisible;
    BOOL _isUserGenderMale;
    BOOL _isPreloaded;
    
    VEndpoint* _endpoint;
}

@end

@implementation CourseRenderViewLoader

-(id)initWithApplicationAPIKey:(NSString *)applicationAPIKey applicationSecretKey:(NSString *)applicationSecretKey idCourse:(NSString *)idCourse {
    
    self = [super init];
    
    if (self) {
        
        VEndpoint* endpoint = [[VEndpoint alloc] init:@"https://api-connect.igolf.com/rest/action/"
                                        applicationAPIKey:applicationAPIKey
                                     applicationSecretKey:applicationSecretKey
                                               apiVersion:@"1.1"
                                         signatureVersion:@"2.0"
                                          signatureMethod:@"HmacSHA256"
                                           responseFormat:@"JSON"];
        
        [self commonInitWithEndoint:endpoint idCourse:idCourse];
    }
    
    return self;
}

-(id)initLoaderWithEndpont:(VEndpoint *)endpoint idCourse:(NSString *)idCourse {
    
    self = [super init];
    
    if (self) {
        
        [self commonInitWithEndoint:endpoint idCourse:idCourse];
    }
    
    return self;
    
}



-(void)commonInitWithEndoint:(VEndpoint *)endpoint idCourse:(NSString *)idCourse {
    
    self->_endpoint = endpoint;
    self->_rest = [[V3DRest alloc] initWithEndpoint:endpoint];
    self->_showCalloutOverlay = true;
    self->_isCartGPSPositionVisible = true;
    self->_isPreloaded = false;
    self->_initialNavigationMode = NavigationMode2DView;
    self->_textureQuality = TextureQualityMediumHigh;
    self->_calloutsDrawMode = CalloutsDrawModeTwoSegments;
    self->_measurementSystem = MeasurementSystemImperial;
    self->_isUserGenderMale = true;
    self->_idCourse = idCourse;
    self->_applicationAPIKey = endpoint.applicationAPIKey;
    self->_applicationSecretKey = endpoint.applicationSecretKey;
    self->_hole = 1;
    self->_loadingView = [[LoadingView alloc] init];
    self->_areFrontBackMarkersDynamic = true;
    self->_rotateHoleOnLocationChanged = false;
    self-> _autoAdvanceActive = false;
    self->_drawDogLegMarker = true;
    self->_drawCentralPathMarkers = true;
}

-(void)preloadWithCompletionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError * _Nullable error))errorHandler {
    NSLog(@"🎯 [IGolfViewer3D] preloadWithCompletionHandler called for course: %@", _idCourse);
    __weak CourseRenderViewLoader* loader = self;
    NSString* idCourse = _idCourse.copy;

    [loader loadCourseGPSVectorDetailsWithIdCourse:idCourse completionHandler:^(CourseGPSVectorDetailsResponse * _Nullable courseGPSVectorDetailsResponse) {
        NSLog(@"✅ [IGolfViewer3D] GPS Vector Details loaded successfully");

        [loader setCourseGPSVectorDetailsResponse:courseGPSVectorDetailsResponse];
        [loader loadCourseGPSDetailsResponseWithIdCourse:idCourse completionHandler:^(CourseGPSDetailsResponse * _Nullable courseGPSDetailsResponse) {
            NSLog(@"✅ [IGolfViewer3D] GPS Details loaded successfully");
            [loader setCourseGPSDetailsResponse:courseGPSDetailsResponse];
            [loader loadCourseScorecardDetailsResponseWithIdCourse:idCourse completionHandler:^(CourseScorecardDetailsResponse * _Nullable courseScorecardDetailsResponse) {
                NSLog(@"✅ [IGolfViewer3D] Scorecard Details loaded successfully");
                [loader setCourseScorecardDetailsResponse:courseScorecardDetailsResponse];
                [loader loadCoursePinPositionDetailsResponseWithIdCourse:idCourse completionHandler:^(CoursePinPositionDetailsResponse * _Nullable coursePinPositionDetailsResponse) {
                    NSLog(@"✅ [IGolfViewer3D] Pin Position Details loaded successfully");
                    [loader setCoursePinPositionsDetailsResponse:coursePinPositionDetailsResponse];
                    
                    BOOL useElevations = true;
            
                    if (useElevations == false){
                        [loader setIsPreloaded:true];
                        completionHandler();
                    } else {
                        [loader loadCourseElevationDataDetailsResponseWithIdCourse:idCourse completionHandler:^(CourseElevationDataDetailsResponse * _Nullable courseElevationDataDetailsResponse) {
                            NSLog(@"✅ [IGolfViewer3D] Elevation Data Details loaded successfully");
                            [loader setCourseElevationDataDetailsResponse:courseElevationDataDetailsResponse];
                            if (courseElevationDataDetailsResponse != nil) {
                                [loader loadCourseElevationDataDetailsUrl:courseElevationDataDetailsResponse.jsonFullUrl completionHandler:^(NSDictionary * _Nullable data) {
                                    [loader setElevationData:data];
                                    
                                    NSError* error = [loader checkData];

                                    if (error != nil) {
                                        NSLog(@"❌ [IGolfViewer3D] ERROR: checkData failed: %@", error.localizedDescription);
                                        errorHandler(error);
                                        return;
                                    }

                                    NSLog(@"✅ [IGolfViewer3D] All course data loaded successfully, calling completionHandler");
                                    [loader setIsPreloaded:true];

                                    completionHandler();
                                } errorHandler:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
                                    NSLog(@"❌ [IGolfViewer3D] ERROR loading Elevation Data URL: %@", error.localizedDescription ?: @"Unknown error");
                                    [loader processErrorResponse:errorResponse error:error withHandler:errorHandler];
                                }];
                            } else {
                                
                                NSError* error = [loader checkData];
                                
                                if (error != nil) {
                                    errorHandler(error);
                                    return;
                                }
                                
                                [loader setIsPreloaded:true];
                                
                                completionHandler();
                            }
                        } errorHandler:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
                            NSLog(@"❌ [IGolfViewer3D] ERROR in Elevation Data Details: %@", error.localizedDescription ?: @"Unknown error");
                            [loader processErrorResponse:errorResponse error:error withHandler:errorHandler];
                        }];
                    }
                } errorHandler:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
                    NSLog(@"❌ [IGolfViewer3D] ERROR in Pin Position Details: %@", error.localizedDescription ?: @"Unknown error");
                    [loader processErrorResponse:errorResponse error:error withHandler:errorHandler];
                }];
            } errorHandler:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
                NSLog(@"❌ [IGolfViewer3D] ERROR in Scorecard Details: %@", error.localizedDescription ?: @"Unknown error");
                [loader processErrorResponse:errorResponse error:error withHandler:errorHandler];
            }];
        } errorHandler:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
            NSLog(@"❌ [IGolfViewer3D] ERROR in GPS Details: %@", error.localizedDescription ?: @"Unknown error");
            [loader processErrorResponse:errorResponse error:error withHandler:errorHandler];
        }];
    } errorHandler:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
        NSLog(@"❌ [IGolfViewer3D] ERROR in GPS Vector Details: %@", error.localizedDescription ?: @"Unknown error");
        [loader processErrorResponse:errorResponse error:error withHandler:errorHandler];
    }];
}

-(void)processErrorResponse:(DefaultResponse *)errorReponse error:(nullable NSError*)error withHandler:(void (^)(NSError * _Nullable error))errorHandler {
    
    NSError* errorObject = error;
    
    if (errorObject == nil) {
        errorObject = [[NSError alloc] initWithDomain:@"com.iGolf.viewer3D" code:errorReponse.status.integerValue userInfo:errorReponse.dict];
    }
    
    errorHandler(error);
}

-(void)launchCourseWithRenderView:(CourseRenderView *)renderView gpsVectorData:(NSDictionary *)gpsVectorData gpsDetailsData:(NSArray *)gpsDetailsData parData:(NSArray *)parData elevationData:(NSDictionary *)elevationData pinPositions:(NSArray *)pinPositions{
    
    
    [renderView loadWithLoader:self];
    renderView.currentHole = _hole;
}

-(nullable NSError *)checkData {
    
    NSError* error;
    
    if (_courseGPSDetailsResponseObject.gpsList.count == 0 || _courseGPSVectorDetailsResponseObject.vectorGPSObject.allKeys.count == 0 || [self getParHole].count == 0) {
        
        NSMutableDictionary* errorDict = [NSMutableDictionary new];
        [errorDict setValue:@"Not enough data to present golf course map." forKey:@"NSLocalizedDescription"];
        [errorDict setValue:@(-999) forKey:@"Code"];
        [errorDict setValue:@"com.iGolf.errorDomain" forKey:@"Error Domain"];
        error = [[NSError alloc] initWithDomain:@"com.iGolf.errorDomain" code:-999 userInfo:errorDict];
    }
    
    return error;
}

-(void)loadCourseGPSVectorDetailsWithIdCourse:(NSString *)idCourse completionHandler:(void (^)(CourseGPSVectorDetailsResponse * _Nullable courseGPSVectorDetailsResponse))completionHandler errorHandler:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))errorHandler {
    
    [_rest courseGPSVectorDetails:idCourse success:^(CourseGPSVectorDetailsResponse * _Nullable response) {
        completionHandler(response);
    } failed:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
        errorHandler(errorResponse, error);
    }];
}

-(void)loadCourseGPSDetailsResponseWithIdCourse:(NSString *)idCourse completionHandler:(void (^)(CourseGPSDetailsResponse * _Nullable courseGPSDetailsResponse))completionHandler errorHandler:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))errorHandler {
    
    [_rest courseGPSDetails:idCourse success:^(CourseGPSDetailsResponse * _Nullable response) {
        completionHandler(response);
    } failed:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
        errorHandler(errorResponse, error);
    }];
}

-(void)loadCourseScorecardDetailsResponseWithIdCourse:(NSString *)idCourse completionHandler:(void (^)(CourseScorecardDetailsResponse * _Nullable courseScorecardDetailsResponse))completionHandler errorHandler:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))errorHandler {
    
    [_rest courseScorecardDetails:idCourse success:^(CourseScorecardDetailsResponse * _Nullable response) {
        completionHandler(response);
    } failed:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
        errorHandler(errorResponse, error);
    }];
}

-(void)loadCoursePinPositionDetailsResponseWithIdCourse:(NSString *)idCourse completionHandler:(void (^)(CoursePinPositionDetailsResponse * _Nullable coursePinPositionDetailsResponse))completionHandler errorHandler:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))errorHandler {
    
    [_rest coursePinPositionDetails:idCourse success:^(CoursePinPositionDetailsResponse * _Nullable response) {
        completionHandler(response);
    } failed:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
        NSLog(@"⚠️ [IGolfViewer3D] Pin Position API returned status: %@ (error: %@)", errorResponse.status, error.localizedDescription ?: @"nil");
        if (errorResponse.status.integerValue == 501 || errorResponse.status.integerValue == 206) {
            NSLog(@"✅ [IGolfViewer3D] Pin Position status is %@ (allowed), continuing without pin positions", errorResponse.status);
            completionHandler(nil);
        } else {
            NSLog(@"❌ [IGolfViewer3D] Pin Position status is %@, treating as error", errorResponse.status);
            errorHandler(errorResponse, error);
        }
    }];
}

-(void)loadCourseElevationDataDetailsResponseWithIdCourse:(NSString *)idCourse completionHandler:(void (^)(CourseElevationDataDetailsResponse * _Nullable courseElevationDataDetailsResponse))completionHandler errorHandler:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))errorHandler {
    
    [_rest courseElevationDataDetails:_idCourse success:^(CourseElevationDataDetailsResponse * _Nullable response) {
        completionHandler(response);
    } failed:^(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error) {
        if (errorResponse.status.integerValue == 206) {
            completionHandler(nil);
        } else if (errorResponse.status.integerValue != 501) {
            errorHandler(errorResponse, error);
        } else {
            completionHandler(nil);
        }
    }];
}

-(void)loadCourseElevationDataDetailsUrl:(NSString*)url completionHandler:(void (^)(NSDictionary * _Nullable data))completionHandler errorHandler:(void (^)(DefaultResponse * _Nullable errorResponse, NSError * _Nullable error))errorHandler {
    
    [_rest get:[NSURL URLWithString:url] httpHeaders:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil || data == nil) {
            errorHandler(nil, error);
        } else {
            NSError* serializationError;
            NSDictionary * elevationData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            
            if (serializationError != nil) {
                errorHandler(nil, serializationError);
            } else {
                completionHandler(elevationData);
            }
        }
    }];
}

-(NSArray *)getParHole {
    NSArray* retval = _courseScorecardDetailsResponseObject.menParHole;
    
    if (!_isUserGenderMale) {
        if (_courseScorecardDetailsResponseObject.wmnParHole != nil) {
            retval = _courseScorecardDetailsResponseObject.wmnParHole;
        }
    }
    
    return retval;
}

-(void)setCourseGPSVectorDetailsResponse:(CourseGPSVectorDetailsResponse *)response {
    _courseGPSVectorDetailsResponseObject = response;
}

-(void)setCourseGPSDetailsResponse:(CourseGPSDetailsResponse *)response {
    _courseGPSDetailsResponseObject = response;
}

-(void)setCourseScorecardDetailsResponse:(CourseScorecardDetailsResponse *)response {
    _courseScorecardDetailsResponseObject = response;
}

-(void)setCoursePinPositionsDetailsResponse:(CoursePinPositionDetailsResponse *)response {
    _coursePinPositionDetailsResponseObject = response;
}

-(void)setCourseElevationDataDetailsResponse:(CourseElevationDataDetailsResponse *)response {
    _courseElevationDataDetailsResponseObject = response;
}

-(void)setElevationData:(NSDictionary *)elevationData {
    _courseElevationDataDetails = elevationData;
}

- (void)setAreFrontBackMarkersDynamic:(BOOL)areFrontBackMarkersDynamic {
    _areFrontBackMarkersDynamic = areFrontBackMarkersDynamic;
}

- (void)setRotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged {
    _rotateHoleOnLocationChanged = rotateHoleOnLocationChanged;
}

- (void)setAutoAdvanceActive:(BOOL)autoAdvanceActive {
    _autoAdvanceActive = autoAdvanceActive;
}

- (void)setCutLayersByHoleBackground:(BOOL)cutLayersByHolePerimeter {
    _cutLayersByHolePerimeter = cutLayersByHolePerimeter;
}

- (void)setDraw3DCentralLine:(BOOL)draw3DCentralPath {
    _draw3DCentralPath = draw3DCentralPath;
}



-(CourseGPSVectorDetailsResponse *)getCourseGPSVectorDetailsResponse {
    return _courseGPSVectorDetailsResponseObject;
}

-(CourseGPSDetailsResponse *)getCourseGPSDetailsResponse {
    return _courseGPSDetailsResponseObject;
}

-(CourseScorecardDetailsResponse *)getCourseScorecardDetailsResponse {
    return _courseScorecardDetailsResponseObject;
}

-(CoursePinPositionDetailsResponse *)getCoursePinPositionsDetailsResponse {
    return _coursePinPositionDetailsResponseObject;
}

-(CourseElevationDataDetailsResponse *)getCourseElevationDataDetailsResponse {
    return _courseElevationDataDetailsResponseObject;
}

-(NSDictionary *)getElevationData {
   return _courseElevationDataDetails;
}

-(void)setLoadingView:(nullable UIView *)view {
    _loadingView = view;
}

-(void)setIsPreloaded:(BOOL)isPreloaded {
    _isPreloaded = isPreloaded;
}

-(void)setDrawDogLegMarker:(BOOL)drawDogLegMarker {
    _drawDogLegMarker = drawDogLegMarker;
}

- (void)setDrawCentralPathMarkers:(BOOL)drawCentralPathMarkers{
    _drawCentralPathMarkers = drawCentralPathMarkers;
}


-(UIView *)getLoadingView {
    return _loadingView;
}

-(NSDictionary *)courseGPSVectorDetailsResponse {
    return _courseGPSVectorDetailsResponseObject.dict;
}

-(NSDictionary *)courseGPSDetailsResponse {
    return _courseGPSDetailsResponseObject.dict;
}

-(NSDictionary *)courseScorecardDetailsResponse {
    return _courseScorecardDetailsResponseObject.dict;
}

-(NSDictionary *)coursePinPositionDetailsResponse {
    return _coursePinPositionDetailsResponseObject.dict;
}

-(NSDictionary *)courseElevationDataDetailsResponse {
    return _courseElevationDataDetailsResponseObject.dict;
}

-(NSDictionary *)courseElevationDataDetails {
    return _courseElevationDataDetails;
}

- (VEndpoint *)endpoint {
    return _endpoint;
}

- (BOOL)isPreloaded {
    return _isPreloaded;
}

-(NSString *)idCourse {
    return _idCourse;
}

- (void)setIsUserGenderMale:(BOOL)isUserGenderMale {
    _isUserGenderMale = isUserGenderMale;
}

- (BOOL)isUserGenderMale {
    return  _isUserGenderMale;
}

- (BOOL)areFrontBackMarkersDynamic {
    return _areFrontBackMarkersDynamic;
}
    
- (BOOL) drawDogLegMarker {
    return _drawDogLegMarker;
}

- (BOOL) drawCentralPathmarkers {
    return _drawCentralPathMarkers;
}

- (BOOL) rotateHoleOnLocationChanged {
    return _rotateHoleOnLocationChanged;
}

- (BOOL)autoAdvanceActive {
    return _autoAdvanceActive;;
}

- (BOOL)cutLayersByHoleBackground {
    return _cutLayersByHolePerimeter;
}

-(BOOL)draw3DCentralLine {
    return _draw3DCentralPath;
}

@end
