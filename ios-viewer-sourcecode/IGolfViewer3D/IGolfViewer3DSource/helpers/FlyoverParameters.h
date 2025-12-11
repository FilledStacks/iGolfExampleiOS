//
//  FlyoverParameters.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "../IGolfViewer3DPrivateImports.h"

@interface FlyoverParameters : NSObject

-(id)initWithStartPostion:(Vector*)startPosition endPosition:(Vector*)endPosition defaultZoom:(double)defaultZoom startViewShift:(double)startViewShift endViewShift:(double)endViewShift endZoom:(double)endZoom holeAltitude:(double)holeAltitude;

-(Vector*)startPosition;
-(Vector*)endPosition;
-(double)defaultZoom;
-(double)startViewShift;
-(double)endViewShift;
-(double)endZoom;
-(double)holeAltitude;

@end
