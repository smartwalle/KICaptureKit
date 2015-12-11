//
//  KIScanMaskView.h
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIScanMaskView : UIView

@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, copy) UIColor *maskColor;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, copy)   UIColor *borderColor;

- (void)startAnimation;

- (void)stopAnimation;

@end
