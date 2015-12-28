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
@property (nonatomic, copy)   UIImage *borderImage;

@property (nonatomic, assign) CGFloat scanLineHeight;
@property (nonatomic, copy)   UIColor *scanLineColor;
@property (nonatomic, copy)   UIImage *scanLineImage;

- (void)startAnimation;

- (void)stopAnimation;

@end
