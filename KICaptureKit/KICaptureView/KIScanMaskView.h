//
//  KIScanMaskView.h
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KIScanMaskView <NSObject>
@required
- (void)startAnimation;
- (void)stopAnimation;
- (void)setScanRect:(CGRect)scanRect;
- (CGRect)scanRect;
@end

@interface KIScanMaskView : UIView <KIScanMaskView>

@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, copy) UIColor *maskColor;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, copy)   UIColor *borderColor;

@property (nonatomic, assign) CGFloat scanLineHeight;
@property (nonatomic, copy)   UIColor *scanLineColor;

- (void)startAnimation;

- (void)stopAnimation;

@end
