
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>

#import "NavigationMode.h"
#import "MeasurementSystem.h"
#import "MeasurementSystem.h"
#import "CalloutsDrawMode.h"
#import "TextureQuality.h"
#import "V3DShape.h"
#import "OpenGLESRenderView.h"

NS_ASSUME_NONNULL_BEGIN

@class IGolfPace;
@class CourseRenderViewLoader;
@class OpenGLESRenderView;

@protocol CourseRenderViewDataSource <NSObject>

-(NSArray<V3DShape*>*)renderViewShapesForHole:(NSUInteger)hole;

@end

@protocol CourseRenderViewDelegate <NSObject>

@optional

- (void)courseRenderViewFlyoverFinished;
- (void)courseRenderViewDidChangeNavigationMode:(NavigationMode)navigationMode;
- (void)courseRenderViewDidLoadCourseData;
- (void)courseRenderViewDidLoadHoleData;
- (void)courseRenderViewDidUpdateRoundTime:(NSTimeInterval)roundTime;
- (void)courseRenderViewDidUpdateFlagScreenPoint:(CGPoint)point;
- (void)courseRenderViewDidReceiveTapAtLocation:(CLLocation *)location;
- (void)courseRenderViewDidUpdateTotalRoundTime:(NSTimeInterval)roundTime;
- (void)courseRenderViewDidUpdateCurrentHole:(NSUInteger)currentHole;
- (void)courseRenderViewDidUpdateHoleWithin:(NSUInteger)holeWithin;
- (void)courseRenderViewDidUpdateDistancesToFrontGreen:(double)frontGreen
                                         toCenterGreen:(double)centerGreen
                                           toBackGreen:(double)backGreen;
- (void)courseRenderViewDidUpdateCurrentHole:(NSUInteger)currentHole holeWithin:(NSUInteger)holeWithin isWithinCourse:(BOOL)isWithinCourse;
- (void)courseRenderViewDidFailWithError:(NSError *)error;

@end

@interface CourseRenderView: OpenGLESRenderView<UIGestureRecognizerDelegate>

@property (class, readonly) NSNotification* navigationModeDidChangeNotification;
@property (class, readonly) NSNotification* flyoverFinishedNotification;
@property (class, readonly) NSNotification* didLoadCourseDataNotification;
@property (class, readonly) NSNotification* didLoadHoleDataNotification;
@property (class, readonly) NSNotification* courseRenderViewReleasedNotification;

@property (nonatomic, assign)   NSUInteger currentHole;
@property (nonatomic, readonly) NSUInteger numberOfHoles;
@property (nonatomic, readonly) NSUInteger holeWithin;
@property (nonatomic, readonly) NSTimeInterval roundTime;

@property (nonatomic, retain) CLLocation* currentLocation;

//@property (nonatomic, assign)   BOOL cutLayersByHoleBackground;
@property (nonatomic, assign)   BOOL draw3DCentralLine;
@property (nonatomic, assign)   BOOL drawDogLegMarker;
@property (nonatomic, assign)   BOOL drawCentralPathMarkers;
@property (nonatomic, assign)   BOOL areFrontBackMarkersDynamic;
@property (nonatomic, assign)   BOOL autoAdvanceActive;
@property (nonatomic, assign)   BOOL rotateHoleOnLocationChanged;
@property (nonatomic, assign)   BOOL showCalloutOverlay;
@property (nonatomic, assign)   BOOL showCartGpsPosition;
@property (nonatomic, assign)   BOOL autozoomActive;
@property (nonatomic, assign)   BOOL shouldSendFlagScreenPointCoordinate;
@property (nonatomic, readonly) BOOL usesOverridedPinPosition;


@property (nonatomic, readonly) CGPoint flagScreenPoint;

@property (nonatomic, assign)   MeasurementSystem measurementSystem;
@property (nonatomic, assign)   NavigationMode navigationMode;
@property (nonatomic, assign)   NavigationMode initialNavigationMode;
@property (nonatomic, assign)   CalloutsDrawMode calloutsDrawMode;

@property (nonatomic, assign)   double overallHoleViewAngle;
//@property (nonatomic, assign)   float renderViewWidthPercent;
@property (nonatomic, assign)   double flyoverViewAngle;
@property (nonatomic, assign)   double freeCamViewAngle;

@property (nonatomic, readonly) CLLocation* flagLocation;
@property (class, readonly) CourseRenderView* shared;
@property (nonatomic, weak) id <CourseRenderViewDelegate> delegate;
@property (nonatomic, weak) id <CourseRenderViewDataSource> dataSource;

- (void)loadWithLoader:(CourseRenderViewLoader *)loader;
- (void)setDrawingEnabled:(BOOL)isEnabled;
- (void)dataSourceChanged;
- (void)setPaceLibrary:(nullable IGolfPace *)paceLibrary;
- (void)setUserFirstName:(nullable NSString*)firstName lastName:(nullable NSString*)lastName email:(nullable NSString*)email idUser:(nullable NSNumber*)idUser;
- (void)setSimulatedLocation:(CLLocation *)simulatedLocation;
- (void)invalidate;

@end


//- (void)viewCartWithGpsVectorData:(NSDictionary *)gpsVectorData;
//- (void)addCartMarkerWithName:(NSString*)name andLocation:(CLLocation*)location andId:(int)cartId;
//- (void)updateCartMarkerWithId:(int)cartId newLocation:(CLLocation*)location;
//- (void)removeCartMarkerWithId:(int)cartId;


NS_ASSUME_NONNULL_END
