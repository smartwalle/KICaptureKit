//
//  KICodeScanView.m
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KICodeScanView.h"
#import "KIScanMaskView.h"

@interface KICodeScanView ()
@property (nonatomic, strong) KICapture      *capture;
@property (nonatomic, strong) KICodeScanner  *codeScanner;
@property (nonatomic, assign) CGRect         scanRect;
@property (nonatomic, strong) KIScanMaskView *maskView;
@property (nonatomic, weak)   CALayer        *previewLayer;
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
    [self addSubview:self.maskView];
    [self.previewLayer setFrame:self.bounds];
    [self.maskView setFrame:self.bounds];
}

- (BOOL)prepareToScan {
    [self.capture addDevice:self.codeScanner];
    [self setPreviewLayer:self.codeScanner.previewLayer];
    return YES;
}

- (void)startRunning {
    [self.capture startRunning];
    [self.maskView startAnimation];
}

- (void)stopRunning {
    [self.capture stopRunning];
    [self.maskView stopAnimation];
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

- (KIScanMaskView *)maskView {
    if (_maskView == nil) {
        _maskView = [[KIScanMaskView alloc] init];
        [_maskView setMaskColor:[UIColor blackColor]];
    }
    return _maskView;
}

- (void)setScanRect:(CGRect)scanRect {
    [self.maskView setScanRect:scanRect];
    [self setNeedsLayout];
}

- (CGRect)scanRect {
    return [self.maskView scanRect];
}

- (void)setPreviewLayer:(CALayer *)previewLayer {
    _previewLayer = previewLayer;
    [previewLayer setFrame:self.bounds];
    [self.layer addSublayer:previewLayer];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self.maskView setBorderColor:borderColor];
}

- (UIColor *)borderColor {
    return self.maskView.borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    [self.maskView setBorderWidth:borderWidth];
}

- (CGFloat)borderWidth {
    return self.maskView.borderWidth;
}

@end
