//
//  OpenGLESRenderView.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <UIKit/UIKit.h>

@class EAGLContext;

@interface OpenGLESRenderView : UIView

@property (nonatomic, retain) EAGLContext* context;
- (void)tearDown;
- (void)initializeDymamicWidth:(float) renderViewWidthPercent;
- (void)normalizeBuffers:(BOOL) usePercentageWidth;
- (void)updateViewportSize:(BOOL) usePercentageWidth;

-(GLint) getCurrentOffset:(BOOL)usePercentageWidth;
-(GLint) getCurrentWidth:(BOOL)usePercentageWidth;
-(GLint) getCurrentHeight;
@end
