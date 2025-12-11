//
//  CourseDataLoader.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@class CourseRenderView;

NS_ASSUME_NONNULL_BEGIN

@interface CourseRenderViewLoader : NSObject

-(id)initWithApplicationAPIKey:(NSString *)applicationAPIKey
          applicationSecretKey:(NSString *)applicationSecretKey
                      idCourse:(NSString *)idCourse;

-(void)loadForRenderView:(CourseRenderView*)renderView
        withErrorHandler:(void (^)(NSError * _Nullable error))errorHandler;

@end

NS_ASSUME_NONNULL_END
