//
//  KIScanMaskView.m
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KIScanMaskView.h"

@interface KIScanMaskView ()
@property (nonatomic, retain) UIImageView   *borderImageView;
@property (nonatomic, retain) UIImageView   *scanLine;
@end

@implementation KIScanMaskView

#pragma mark - Lifecycle
- (instancetype)init {
    if (self = [super init]) {
        [self setMaskColor:[UIColor blackColor]];
        [self setScanLineColor:[UIColor greenColor]];
        [self setScanLineHeight:1.0f];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:self.scanLine];
    [self addSubview:self.borderImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.borderImageView setImage:self.borderImage];
    [self.borderImageView setFrame:self.scanRect];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [self.maskColor colorWithAlphaComponent:0.5].CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    CGContextStrokeRectWithWidth(ctx, self.scanRect, self.borderWidth);
    
    CGContextClearRect(ctx, self.scanRect);
}

#pragma mark - Methods
- (void)startAnimation {
    [self.scanLine setHidden:NO];
    CGFloat x = CGRectGetMinX(self.scanRect);
    CGFloat y = CGRectGetMinY(self.scanRect);
    CGSize size = self.scanRect.size;
    [self.scanLine setFrame:CGRectMake(x, y + self.borderWidth - self.scanLineHeight * 0.5, size.width, self.scanLineHeight)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:1.5f];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeBackwards];
    [animation setRepeatCount:HUGE_VALF];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:self.scanLine.layer.position]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.scanLine.layer.position.x, y+size.height-self.borderWidth)]];
    
    [self.scanLine.layer addAnimation:animation forKey:@"KICodeScanMaskViewScanAnimation"];
}

- (void)stopAnimation {
    [self.scanLine.layer setHidden:YES];
    [self.scanLine.layer removeAnimationForKey:@"KICodeScanMaskViewScanAnimation"];
}

- (void)updateScanLineFrame {
    CGFloat x = CGRectGetMinX(self.scanRect);
    CGFloat y = CGRectGetMinY(self.scanRect) - self.scanLineHeight / 2;
    CGSize size = self.scanRect.size;
    [self.scanLine setFrame:CGRectMake(x, y, size.width, self.scanLineHeight)];
}

- (void)setScanLineDefaultStyle {
    [_scanLine setBackgroundColor:[self.scanLineColor colorWithAlphaComponent:0.5]];
    [_scanLine.layer setShadowColor:self.scanLineColor.CGColor];
    [_scanLine.layer setShadowOpacity:2];
    [_scanLine.layer setShadowRadius:6];
    [_scanLine.layer setShadowOffset:CGSizeMake(0, 0)];
}

#pragma mrak - Getters & Setters
- (UIImageView *)borderImageView {
    if (_borderImageView == nil) {
        _borderImageView = [[UIImageView alloc] init];
        [_borderImageView setBackgroundColor:[UIColor clearColor]];
    }
    return _borderImageView;
}

- (UIImageView *)scanLine {
    if (_scanLine == nil) {
        _scanLine = [[UIImageView alloc] init];
        [self setScanLineDefaultStyle];
        [_scanLine setHidden:YES];
    }
    return _scanLine;
}

- (void)setScanRect:(CGRect)scanRect {
    _scanRect = scanRect;
    [self setNeedsDisplay];
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = [maskColor copy];
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = [borderColor copy];
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

- (void)setBorderImage:(UIImage *)borderImage {
    _borderImage = [borderImage copy];
    [self setNeedsLayout];
}

- (void)setScanLineColor:(UIColor *)scanLineColor {
    _scanLineColor = [scanLineColor copy];
    [self.scanLine setBackgroundColor:[_scanLineColor colorWithAlphaComponent:0.5]];
    [self.scanLine.layer setShadowColor:self.scanLineColor.CGColor];
}

- (void)setScanLineHeight:(CGFloat)scanLineHeight {
    _scanLineHeight = scanLineHeight;
    [self updateScanLineFrame];
}

- (void)setScanLineImage:(UIImage *)scanLineImage {
    _scanLineImage = [scanLineImage copy];
    [self.scanLine setImage:_scanLineImage];
    
    if (_scanLineImage != nil) {
        [self.scanLine setBackgroundColor:[UIColor clearColor]];
        [self.scanLine.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.scanLine.layer setShadowOpacity:0];
        [self.scanLine.layer setShadowRadius:0];
        [self.scanLine.layer setShadowOffset:CGSizeMake(0, 0)];
    } else {
        [self setScanLineDefaultStyle];
    }
}

@end
