//
//  KICodeScanView.m
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KICodeScanView.h"

@interface KICodeScanView ()
@property (nonatomic, strong) KICapture      *capture;
@property (nonatomic, strong) KICodeScanner  *codeScanner;
@property (nonatomic, assign) CGRect         scanRect;
@property (nonatomic, weak)   CALayer        *previewLayer;
@property (nonatomic, strong) UIView<KIScanMaskView> *scanMaskView;
@end

@implementation KICodeScanView

- (instancetype)initWithFrame:(CGRect)frame scanRect:(CGRect)scanRect {
    if (self = [super initWithFrame:frame]) {
        [self setScanRect:scanRect];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:self.scanMaskView];
    [self.previewLayer setFrame:self.bounds];
    [self.scanMaskView setFrame:self.bounds];
}

- (BOOL)prepareToScan {
    [self.capture addDevice:self.codeScanner];
    [self setPreviewLayer:self.codeScanner.previewLayer];
    return YES;
}

- (void)startRunning {
    [self.capture startRunning];
    [self.scanMaskView startAnimation];
}

- (void)stopRunning {
    [self.capture stopRunning];
    [self.scanMaskView stopAnimation];
}

#pragma mark Getters & Setters
- (KICapture *)capture {
    if (_capture == nil) {
        _capture = [[KICapture alloc] init];
    }
    return _capture;
}

- (KICodeScanner *)codeScanner {
    if (_codeScanner == nil) {
        _codeScanner = [[KICodeScanner alloc] initWithPosition:KICameraPositionBack];
        [_codeScanner setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    return _codeScanner;
}

- (void)setScanRect:(CGRect)scanRect {
    [self setNeedsLayout];
}

- (void)setPreviewLayer:(CALayer *)previewLayer {
    _previewLayer = previewLayer;
    [previewLayer setFrame:self.bounds];
    [self.layer addSublayer:previewLayer];
}

@end
