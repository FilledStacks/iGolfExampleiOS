//
//  CentralPathCleaner.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "../IGolfViewer3DPrivateImports.h"

@class  Layer;

@interface CentralPathCleaner : NSObject

-(instancetype)initWithGreenView:(Layer*)greenViewLayer;
-(NSArray<Vector*>*)cleanCentralPath:(NSArray<Vector*>*)centralPath;
@end
