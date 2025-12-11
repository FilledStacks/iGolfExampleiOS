//
//  Triangulator.h
//  iOS3DCourseViewer
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@class TriangulatedDrawObject;

@interface Triangulator2 : NSObject

+ (NSArray<TriangulatedDrawObject*>*)triangulate:(NSArray*)pointList;

@end
