/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "HUDoubleSliderView.h"
#import "UIView+RoundedCorners.h"
#import <QuartzCore/QuartzCore.h>

@implementation HUDoubleSliderView
{
    CSLabel *_leftStatusView;
    CSLabel *_rightStatusView;
    CSLabel *_descriptionLabel;
    UIView *_barView;
    CGRect _maxBarRect;
}

-(void) dealloc {
    [self removeObserver:self forKeyPath:@"leftValue"];
    [self removeObserver:self forKeyPath:@"rightValue"];
    [self removeObserver:self forKeyPath:@"leftValueMax"];
    [self removeObserver:self forKeyPath:@"rightValueMax"];
    [self removeObserver:self forKeyPath:@"statusBarWidth"];
    [self removeObserver:self forKeyPath:@"barColor"];
    [self removeObserver:self forKeyPath:@"statusBarColor"];
    [self removeObserver:self forKeyPath:@"frame"];
    [self removeObserver:self forKeyPath:@"font"];
    [self removeObserver:self forKeyPath:@"textColor"];
    [self removeObserver:self forKeyPath:@"backgroundColor"];
    [self removeObserver:self forKeyPath:@"description"];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _leftValueMax = 0;
        _rightValueMax = 100;
        
        _leftValue = _leftValueMax;
        _rightValue = _rightValueMax;
        
        _statusBarWidth = 66;
        self.backgroundColor = kHUColorGreen;
        self.statusBarColor = kHUColorGreen;
        self.barColor = kHUColorWhite;
        self.textColor = kHUColorWhite;
        self.font = kFontArialMTOfSize(kFontSizeMiddium);
        
        [self addObserver:self forKeyPath:@"leftValue" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"rightValue" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"leftValueMax" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"rightValueMax" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"statusBarWidth" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"barColor" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"statusBarColor" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"frame" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"font" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"textColor" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"backgroundColor" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"description" options:0 context:NULL];
        [self loadView];
    }
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:@"leftValue"] || [keyPath isEqualToString:@"rightValue"] ||
       [keyPath isEqualToString:@"leftValueMax"] || [keyPath isEqualToString:@"rightValueMax"]) {
        [self updateText];
    }
    else if ([keyPath isEqualToString:@"statusBarWidth"]) {
        [self updateView];
    }
    else if ([keyPath isEqualToString:@"statusBarColor"]) {
        _leftStatusView.backgroundColor = self.statusBarColor;
        _rightStatusView.backgroundColor = self.statusBarColor;
    }
    else if ([keyPath isEqualToString:@"barColor"]) {
        _barView.backgroundColor = self.barColor;
    }
    else if ([keyPath isEqualToString:@"frame"]) {
        [self updateView];
    }
    else if ([keyPath isEqualToString:@"font"]) {
        [self updateFont];
    }
    else if ([keyPath isEqualToString:@"textColor"]) {
        [self updateTextColor];
    }
    else if ([keyPath isEqualToString:@"backgroundColor"]) {
        _descriptionLabel.textColor = self.backgroundColor;
    }
    else if ([keyPath isEqualToString:@"description"]) {
        _descriptionLabel.text = _description;
    }
}

-(void) loadView {
    
    CGFloat cornerRadius = self.height / 2;
    self.backgroundColor = self.backgroundColor;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(5, 0, 0, 10);
    
    _leftStatusView = [[CSLabel alloc] initWithFrame:CGRectMake(0, 0, _statusBarWidth, self.height)];
    _leftStatusView.userInteractionEnabled = NO;
    _leftStatusView.backgroundColor = self.statusBarColor;
    _leftStatusView.textAlignment = NSTextAlignmentRight;
    _leftStatusView.margin = insets;
    [self addSubview:_leftStatusView];
    
    insets.left = 10;
    _rightStatusView = [[CSLabel alloc] initWithFrame:CGRectMake(self.width - _statusBarWidth, 0, _statusBarWidth, self.height)];
    _rightStatusView.userInteractionEnabled = NO;
    _rightStatusView.backgroundColor = self.statusBarColor;
    _rightStatusView.textAlignment = NSTextAlignmentLeft;
    _rightStatusView.margin = insets;
    [self addSubview:_rightStatusView];
    
    CGFloat margin = 1;
    _maxBarRect = CGRectMake(_statusBarWidth + margin,
                             0,
                             self.width - 2 * (_statusBarWidth + margin),
                             self.height);
    _barView = [[UIView alloc] initWithFrame:_maxBarRect];
    _barView.backgroundColor = self.barColor;
    _barView.userInteractionEnabled = NO;
    [self addSubview:_barView];
    
    _descriptionLabel = [[CSLabel alloc] initWithFrame:_maxBarRect];
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionLabel.margin     = UIEdgeInsetsMake(5, 0, 0, 0);
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.textColor = self.backgroundColor;
    [self addSubview:_descriptionLabel];
    
    [self updateText];
    [self updateTextColor];
    [self updateFont];
}

-(void) updateView {
    _leftStatusView.frame = CGRectMake(0, 0, _statusBarWidth, self.height);
    _rightStatusView.frame = CGRectMake(self.width - _statusBarWidth, 0, _statusBarWidth, self.height);
}

-(void) updateFont {
    _leftStatusView.font = _font;
    _rightStatusView.font = _font;
    _descriptionLabel.font = _font;
}

-(void) updateTextColor {
    _leftStatusView.textColor = _textColor;
    _rightStatusView.textColor = _textColor;
}

-(void) updateText {
    _leftStatusView.text = [NSString stringWithFormat:@"%i", _leftValue];
    _rightStatusView.text = [NSString stringWithFormat:@"%i", _rightValue];
}

-(void) calculateValues {
    NSInteger valueRange = _rightValueMax - _leftValueMax;
    _leftValue = valueRange * (_barView.x - _maxBarRect.origin.x) / _maxBarRect.size.width;
    _rightValue = valueRange * ((_barView.x + _barView.width - _maxBarRect.origin.x) / _maxBarRect.size.width);
}

-(void) updateSliderWithTouch:(UITouch*) touch {
    CGPoint touchLocation = [touch locationInView:self];
    CGFloat minBarX = _maxBarRect.origin.x;
    CGFloat maxBarX = _maxBarRect.origin.x + _maxBarRect.size.width;

    if (touchLocation.x < minBarX) touchLocation.x = minBarX;
    else if (touchLocation.x > maxBarX) touchLocation.x = maxBarX;
    
    CGFloat barXLeft = _barView.x;
    CGFloat barXRight = _barView.x + _barView.width;
    
    CGFloat leftDistance = fabsf(barXLeft - touchLocation.x);
    CGFloat rightDistance = fabsf(barXRight - touchLocation.x);
    
    ///check distance to touch from left and right
    if (leftDistance < rightDistance) {
        ///move the left side of the graph
        [UIView animateWithDuration:0.2 animations:^{
            _barView.frame = CGRectMake(touchLocation.x, _barView.y, barXRight - touchLocation.x, _barView.height);
        }];
    }
    else {
        //move the right side of the graph
         [UIView animateWithDuration:0.2 animations:^{
             _barView.x = barXLeft;
             _barView.width = touchLocation.x - _barView.x;
         }];
    }
    
    [self calculateValues];
    [self updateText];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self updateSliderWithTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self updateSliderWithTouch:touch];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
}

@end
