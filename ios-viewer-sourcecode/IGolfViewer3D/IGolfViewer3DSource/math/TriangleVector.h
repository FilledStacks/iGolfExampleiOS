//
//  TriangleVector.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@interface TriangleVector : NSObject

+ (float)dotWithU:(float*)u andV:(float*)v;
+ (void)minusWithU:(float*)u andV:(float*)v andOut:(float*)outVector;
+ (void)additionWithU:(float*)u andV:(float*)v andOut:(float*)outVector;
+ (void)scalarProductWithR:(float)r andU:(float*)u andOut:(float*)outVector;
+ (void)crossProductWithU:(float*)u andV:(float*)v andOut:(float*)outVector;
+ (float)lengthWithU:(float*)u;

@end
