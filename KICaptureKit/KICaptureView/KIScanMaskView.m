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
- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self setBackgroundColor:[UIColor clearColor]];
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
    [self.scanLine setFrame:CGRectMake(x, y, size.width, 2)];
    
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

#pragma mrak Getters & Setters
- (UIImageView *)scanLine {
    if (_scanLine == nil) {
        _scanLine = [[UIImageView alloc] init];
        [_scanLine setBackgroundColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:0.5]];
        [_scanLine.layer setShadowColor:[UIColor greenColor].CGColor];
        [_scanLine.layer setShadowOpacity:1];
        [_scanLine.layer setShadowRadius:6];
        [_scanLine.layer setShadowOffset:CGSizeMake(0, 0)];
        
        [self addSubview:_scanLine];
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

@end
