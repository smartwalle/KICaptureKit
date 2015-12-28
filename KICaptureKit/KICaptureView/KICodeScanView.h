//
//  KICodeScanView.h
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIScanMaskView.h"
#import "KICapture.h"
#import "KICaptureDevice.h"

@interface KICodeScanView : UIView

- (instancetype)initWithFrame:(CGRect)frame scanRect:(CGRect)scanRect;

- (BOOL)prepareToScan;
- (void)startRunning;
- (void)stopRunning;

- (KICodeScanner *)codeScanner;

- (void)setScanMaskView:(UIView<KIScanMaskView> *)maskView;
- (UIView<KIScanMaskView> *)scanMaskView;

@end