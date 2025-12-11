//
//  CourseScorecardDetailsResponse.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseScorecardDetailsResponse.h"


@interface CourseScorecardDetailsResponse() {
    NSArray* _menParHole;
    NSArray* _wmnParHole;
}

@end

@implementation CourseScorecardDetailsResponse

-(instancetype)init:(NSData *)data {
    self = [super init:data];
    
    if (self) {
        
        NSError* error;
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            return nil;
        }
        
        NSArray* menList = [dict valueForKey:@"menScorecardList"];
        
        if (menList != nil && menList.count > 0) {
            NSDictionary* listDict = menList.firstObject;
            if (listDict != nil) {
                NSArray* parHole  = [listDict valueForKey:@"parHole"];
                if (parHole != nil) {
                    self->_menParHole = parHole;
                }
            }
        }
        
        NSArray* wmnList = [dict valueForKey:@"wmnScorecardList"];
        
        if (wmnList != nil && wmnList.count > 0) {
            NSDictionary* listDict = wmnList.firstObject;
            if (listDict != nil) {
                NSArray* parHole  = [listDict valueForKey:@"parHole"];
                if (parHole != nil) {
                    self->_wmnParHole = parHole;
                }
            }
        }
    }
    
    return self;
}

-(NSArray *)menParHole {
    return _menParHole;
}

-(NSArray *)wmnParHole {
    return _wmnParHole;
}

@end

