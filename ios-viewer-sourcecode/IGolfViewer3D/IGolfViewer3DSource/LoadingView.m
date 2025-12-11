//
//  LoadingView.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "LoadingView.h"

@interface LoadingView() {
    BOOL _isFrontShown;
    
    UIView* _viewHolder;
    
    UIView* _frontView;
    UIView* _backView;
}

@end

@implementation LoadingView

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self addObserver:self forKeyPath:@"bounds" options:0 context:nil];
        
    }
    
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, 0, 100, 100);
    
    self.frame = frame;
    
    self.center = self.superview.center;
    
    NSString* logoPath = [[NSBundle mainBundle] pathForResource:@"iGolfLogoWhite" ofType:@"png"];
    UIImage* logo = [UIImage imageWithContentsOfFile:logoPath];
    UIImageView* logoImageView1 = [[UIImageView alloc] initWithFrame:frame];
    logoImageView1.image = logo;
    logoImageView1.contentMode = UIViewContentModeScaleAspectFit;
    _frontView = logoImageView1;

    NSString* logoPath2 = [[NSBundle mainBundle] pathForResource:@"iGolfLogoWhiteMirror" ofType:@"png"];
    UIImage* logo2 = [UIImage imageWithContentsOfFile:logoPath2];
    
    UIImageView* logoImageView2 = [[UIImageView alloc] initWithFrame:frame];
    logoImageView2.image = logo2;
    logoImageView2.contentMode = UIViewContentModeScaleAspectFit;
    _backView = logoImageView2;
    
   
    _viewHolder = [[UIView alloc] initWithFrame: frame];
    [_viewHolder addSubview:_frontView];
    
    [self addSubview:_viewHolder];
    
    [self animate];
}

- (BOOL)isFrontShown {
    return _isFrontShown;
}

- (void)setIsFrontShown:(BOOL)isFrontShown {
    _isFrontShown = isFrontShown;
}

- (UIView *)frontView {
    return _frontView;
}

- (UIView *)backView {
    return _backView;
}

- (void)animate {

    __weak LoadingView* weakSelf = self;
    
    if ([weakSelf isFrontShown]) {
        [UIView transitionFromView:[weakSelf frontView] toView:[weakSelf backView] duration:1.2 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            if (finished == true) {
                [weakSelf setIsFrontShown:![weakSelf isFrontShown]];
                [weakSelf animate];
            }
        }];
    } else {
        [UIView transitionFromView:[weakSelf backView] toView:[weakSelf frontView] duration:1.2 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            if (finished == true) {
                [weakSelf setIsFrontShown:![weakSelf isFrontShown]];
                [weakSelf animate];
            }
        }];
    }
}



@end
