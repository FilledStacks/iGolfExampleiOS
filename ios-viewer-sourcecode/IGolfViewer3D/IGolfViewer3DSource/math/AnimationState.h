//
//  AnimationState.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#ifndef AnimationState_h
#define AnimationState_h

typedef NS_ENUM(NSUInteger, AnimationState) {
    AnimationStateWait,
    AnimationStateFlyToGreencenter,
    AnimationStateTiltGreencenter,
    AnimationStateWaitForFinish,
};


#endif /* AnimationState_h */
