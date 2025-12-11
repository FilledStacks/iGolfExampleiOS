//
//  CourseDataLoader.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "NavigationMode.h"
#import "TextureQuality.h"
#import "CalloutsDrawMode.h"
#import "MeasurementSystem.h"
#import "CourseRenderView.h"
#import "VEndpoint.h"


NS_ASSUME_NONNULL_BEGIN

@class CourseRenderView;

@interface CourseRenderViewLoader : NSObject

@property (nonatomic, readonly) NSString* idCourse;
@property (nonatomic, readonly) NSDictionary* courseGPSVectorDetailsResponse;
@property (nonatomic, readonly) NSDictionary* courseGPSDetailsResponse;
@property (nonatomic, readonly) NSDictionary* courseScorecardDetailsResponse;
@property (nonatomic, readonly) NSDictionary* coursePinPositionDetailsResponse;
@property (nonatomic, readonly) NSDictionary* courseElevationDataDetailsResponse;
@property (nonatomic, readonly) NSDictionary* courseElevationDataDetails;
@property (nonatomic, assign) NSUInteger hole;
@property (nonatomic, readonly) VEndpoint* endpoint;
@property (nonatomic, readonly) BOOL isPreloaded;
@property (nonatomic, assign) BOOL showCalloutOverlay;
@property (nonatomic, assign) BOOL isCartGPSPositionVisible;
@property (nonatomic, assign) BOOL isUserGenderMale;
@property (nonatomic, assign) BOOL drawDogLegMarker;
@property (nonatomic, assign) BOOL drawCentralPathMarkers;
@property (nonatomic, assign) BOOL areFrontBackMarkersDynamic;
@property (nonatomic, assign) BOOL autoAdvanceActive;
@property (nonatomic, assign) BOOL rotateHoleOnLocationChanged;
@property (nonatomic, assign) BOOL cutLayersByHoleBackground;
@property (nonatomic, assign) BOOL draw3DCentralLine;
@property (nonatomic, assign) NavigationMode initialNavigationMode;
@property (nonatomic, assign) TextureQuality textureQuality;
@property (nonatomic, assign) CalloutsDrawMode calloutsDrawMode;
@property (nonatomic, assign) MeasurementSystem measurementSystem;



-(id)initWithApplicationAPIKey:(NSString *)applicationAPIKey
          applicationSecretKey:(NSString *)applicationSecretKey
                      idCourse:(NSString *)idCourse;

-(id)initLoaderWithEndpont:(VEndpoint *)endpoint
                               idCourse:(NSString *)idCourse;

-(void)preloadWithCompletionHandler:(void (^)())completionHandler
                       errorHandler:(void (^)(NSError * _Nullable error))errorHandler;

-(void)setLoadingView:(nullable UIView *)view;

-(UIView*)getLoadingView;


@end

NS_ASSUME_NONNULL_END
