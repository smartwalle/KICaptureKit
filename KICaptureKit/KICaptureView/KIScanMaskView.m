//
//  KIScanMaskView.m
//  KICaptureKit
//
//  Created by apple on 15/12/11.
//  Copyright (c) 2015年 smartwalle. All rights reserved.
//

#import "KIScanMaskView.h"

@interface KIScanMaskView ()
@property (nonatomic, retain) UIImageView   *scanLine;
@end

@implementation KIScanMaskView

#pragma mark Lifecycle
- (instancetype)init {
    if (self = [super init]) {
        [self setScanLineColor:[UIColor greenColor]];
        [self setScanLineHeight:1.0f];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.scanLine];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [self.maskColor colorWithAlphaComponent:0.5].CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    CGContextStrokeRectWithWidth(ctx, self.scanRect, self.borderWidth);
    
    CGContextClearRect(ctx, self.scanRect);
}

#pragma mark Methods
- (void)startAnimation {
    [self.scanLine setHidden:NO];
    CGFloat x = CGRectGetMinX(self.scanRect);
    CGFloat y = CGRectGetMinY(self.scanRect);
    CGSize size = self.scanRect.size;
    [self.scanLine setFrame:CGRectMake(x, y, size.width, self.scanLineHeight)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:1.5f];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeBackwards];
    [animation setRepeatCount:HUGE_VALF];
    [animation setFromValue:[NSValue valueWithCGPoint:self.scanLine.layer.position]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.scanLine.layer.position.x, y+size.height-self.borderWidth)]];
    
    [self.scanLine.layer addAnimation:animation forKey:@"KICodeScanMaskViewScanAnimation"];
}

- (void)stopAnimation {
    [self.scanLine.layer setHidden:YES];
    [self.scanLine.layer removeAnimationForKey:@"KICodeScanMaskViewScanAnimation"];
}

#pragma mark Methods
- (void)updateScanLineFrame {
    CGFloat x = CGRectGetMinX(self.scanRect);
    CGFloat y = CGRectGetMinY(self.scanRect);
    CGSize size = self.scanRect.size;
    [self.scanLine setFrame:CGRectMake(x, y, size.width, self.scanLineHeight)];
}

#pragma mrak Getters & Setters
- (UIImageView *)scanLine {
    if (_scanLine == nil) {
        _scanLine = [[UIImageView alloc] init];
        [_scanLine setBackgroundColor:[self.scanLineColor colorWithAlphaComponent:0.5]];
        [_scanLine.layer setShadowColor:self.scanLineColor.CGColor];
        [_scanLine.layer setShadowOpacity:2];
        [_scanLine.layer setShadowRadius:6];
        [_scanLine.layer setShadowOffset:CGSizeMake(0, 0)];
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

- (void)setScanLineColor:(UIColor *)scanLineColor {
    _scanLineColor = [scanLineColor copy];
    [self.scanLine setBackgroundColor:[_scanLineColor colorWithAlphaComponent:0.5]];
    [self.scanLine.layer setShadowColor:self.scanLineColor.CGColor];
}

- (void)setScanLineHeight:(CGFloat)scanLineHeight {
    _scanLineHeight = scanLineHeight;
    [self updateScanLineFrame];
}

@end
