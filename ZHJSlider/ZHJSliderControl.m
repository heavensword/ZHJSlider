//
//  ZHJSlider.m
//  ZHJSlider
//
//  Created by Sword on 6/3/15.
//  Copyright (c) 2015 Sword. All rights reserved.
//

#import "ZHJSliderControl.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define trackColor  RGBCOLOR(114, 202, 254)
#define trackHighlightColor  RGBACOLOR(114, 202, 254, 0.8)
#define TrackGradientHeight 8

@interface ZHJSliderControl()<UIGestureRecognizerDelegate>
{
    UIView  *_roundTrackView;
}
@end

@implementation ZHJSliderControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setValue:(CGFloat)value {
    _value = value;
    [self adjustValue];
    [self updateRoundCircieView];
}

- (CGFloat)radius {
    return CGRectGetHeight(self.bounds) / 2;
}

- (CGFloat)centerXAccordingToValue {
    CGFloat x = [self radius];
    x = ((_value - _minimumValue) / (_maximumValue - _minimumValue)) * (CGRectGetWidth(self.bounds) - 2 * [self radius]) + [self radius];
    return x;
}

- (CGFloat)intervalBetweenKeyPoints {
    CGFloat radius = [self radius];
    return (CGRectGetWidth(self.bounds) - 2 * radius) / (_keyValueNumber - 1);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [self drawTrackBar:context rect:rect];
    [self drawKeyValuePoints:context rect:rect];
//    [self drawRoundTrackCircle:context rect:rect];
    [self updateRoundCircieView];
    CGContextRestoreGState(context);
}

- (void)drawRoundTrackCircle:(CGContextRef)context rect:(CGRect)rect {
//    CGContextSaveGState(context);
//    CGFloat radius = [self radius];
//    CGFloat centerX = [self centerXAccordingToValue];
//    CGFloat centerY = CGRectGetHeight(rect) / 2;
//    CGContextSetFillColorWithColor(context, trackColor.CGColor);
//    
//    CGContextAddArc(context, centerX, centerY, radius, 0,  2 * M_PI, 0);
//    CGContextFillPath(context);
//    
//    CGContextRestoreGState(context);
}

- (void)drawTrackBar:(CGContextRef)context rect:(CGRect)rect {
    CGContextSaveGState(context);
    CGFloat radius = [self radius];
    CGFloat y = (CGRectGetHeight(rect) - TrackGradientHeight) / 2;
    CGRect gradientRect = CGRectMake(radius, y, CGRectGetWidth(rect) - 2 * radius, TrackGradientHeight);
    CGContextAddRect(context, gradientRect);
    CGContextClip(context);
    CGFloat locs[3] = {0.0, 0.5, 1.0};
    CGColorSpaceRef mySpace = CGColorSpaceCreateDeviceRGB();
    
    CFArrayRef colors = CFBridgingRetain(@[(id)RGBCOLOR(219, 220, 221).CGColor, (id)RGBCOLOR(237, 237, 239).CGColor, (id)RGBCOLOR(234, 234, 235).CGColor]) ;
    CGGradientRef gradientRef = CGGradientCreateWithColors(mySpace, colors, locs);
    CGPoint startPoint = CGPointMake(CGRectGetWidth(rect) / 2, 0);
    CGPoint endPoint = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect));
    CGContextDrawLinearGradient(context, gradientRef, startPoint, endPoint, 0);
    CGColorSpaceRelease(mySpace);
    CGGradientRelease(gradientRef);
    CGContextRestoreGState(context);
}

- (void)drawKeyValuePoints:(CGContextRef)context rect:(CGRect)rect {
    CGFloat radius = [self radius];
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, RGBCOLOR(233, 237, 239).CGColor);
    CGFloat centerX = radius;
    CGFloat centerY = CGRectGetHeight(rect) / 2;
    CGFloat interval = [self intervalBetweenKeyPoints];
    
    CGColorSpaceRef mySpace = CGColorSpaceCreateDeviceRGB();
    CFArrayRef colors = CFBridgingRetain(@[(id)RGBCOLOR(237, 237, 239).CGColor, (id)RGBCOLOR(218, 219, 220).CGColor]) ;
    CGFloat locs[2] = {0.0, 1.0};
    CGGradientRef gradientRef = CGGradientCreateWithColors(mySpace, colors, locs);
    CGColorSpaceRelease(mySpace);
    for (NSInteger i = 0; i < _keyValueNumber; i++) {
        CGContextAddArc(context, centerX, centerY, radius, 0,  2 * M_PI, 0);
        CGContextFillPath(context);
        CGContextDrawRadialGradient(context, gradientRef, CGPointMake(centerX, centerY), radius - 1, CGPointMake(centerX, centerY), radius, 0);
        centerX += interval;
    }
    CGGradientRelease(gradientRef);
    CGContextRestoreGState(context);
}

- (void)updateRoundCircieView {
    CGPoint center = _roundTrackView.center;
    center.x = [self centerXAccordingToValue];
    _roundTrackView.center = center;
}

- (void)updateValueWithX:(CGFloat)x {
    _value = (_maximumValue - _minimumValue) * (x / (CGRectGetWidth(self.bounds) - 2 * [self radius])) + _minimumValue;
    if (_value < _minimumValue) {
        _value = _minimumValue;
    }
    if (_value > _maximumValue) {
        _value = _maximumValue;
    }
   [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (BOOL)needAdjustValue {
    BOOL needAdjust = FALSE;
    CGFloat interval = (_maximumValue - _minimumValue) / (_keyValueNumber - 1);
    CGFloat minimunSpacing = CGFLOAT_MAX;
    CGFloat spacing;
    for (NSInteger i = 0; i < _keyValueNumber; i++) {
        spacing = fabs(_minimumValue + i * interval - _value);
        if (minimunSpacing > spacing) {
            minimunSpacing = fabs(_minimumValue + i * interval - _value);
            if (spacing > ([self radius] / (CGRectGetWidth(self.bounds))) * (_maximumValue - _minimumValue)) {
              needAdjust = TRUE;
            }
        }
    }
    return needAdjust;
}

- (void)adjustValue {
    CGFloat interval = (_maximumValue - _minimumValue) / (_keyValueNumber - 1);
    CGFloat keyPointValue = 0;
    CGFloat minimunSpacing = CGFLOAT_MAX;
    for (NSInteger i = 0; i < _keyValueNumber; i++) {
        if (minimunSpacing > fabs(_minimumValue + i * interval- _value)) {
            keyPointValue = _minimumValue + i * interval;
            minimunSpacing = fabs(_minimumValue + i * interval - _value);
        }
    }
    _value = keyPointValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setup {
    _minimumValue = 0;
    _maximumValue = 1.0;
    _keyValueNumber = 2;
    _value = 0;
    
    _roundTrackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * [self radius], 2 * [self radius])];
    _roundTrackView.backgroundColor = trackColor;
    _roundTrackView.layer.cornerRadius = [self radius];
    _roundTrackView.layer.masksToBounds = TRUE;
    [self addSubview:_roundTrackView];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_roundTrackView addGestureRecognizer:panGesture];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
    
}

- (void)handleTap:(UIPanGestureRecognizer*)gesture {
    CGFloat x = [self convertPoint:[gesture locationInView:_roundTrackView] fromView:_roundTrackView].x - [self radius];
    [self updateValueWithX:x];
    if ([self needAdjustValue]) {
        [self updateRoundCircieView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustValue];
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.1 options:0 animations:^{
                  [self updateRoundCircieView];
            } completion:nil];
        });
    }
    else {
        [self adjustValue];
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.1 options:0 animations:^{
            [self updateRoundCircieView];
        } completion:nil];
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)gesture {
    CGFloat x = [self convertPoint:[gesture locationInView:_roundTrackView] fromView:_roundTrackView].x - [self radius];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStatePossible:
            _roundTrackView.backgroundColor = trackHighlightColor;
            break;
        case UIGestureRecognizerStateChanged:
            [self updateValueWithX:x];
            [self updateRoundCircieView];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            _roundTrackView.backgroundColor = trackColor;
            [self updateValueWithX:x];
            [self adjustValue];
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.1 options:0 animations:^{
                [self updateRoundCircieView];
            } completion:nil];
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return TRUE;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
