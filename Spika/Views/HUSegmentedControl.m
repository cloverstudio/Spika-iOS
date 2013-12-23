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

#import "HUSegmentedControl.h"
#import "UIView+RoundedCorners.h"

@implementation HUSegmentedControl
{
    NSMutableArray *_views;
}

-(void) dealloc {
    [self removeObserver:self forKeyPath:@"items"];
    [self removeObserver:self forKeyPath:@"selectedSegmentIndex"];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:@"items" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"selectedSegmentIndex" options:0 context:NULL];
        
        _views = [NSMutableArray array];
        self.userInteractionEnabled = YES;
        self.normalColor = kHUColorLightGray;
        self.highlightedColor = kHUColorGreen;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self createViewsForItems:_items];
    } else if ([keyPath isEqualToString:@"selectedSegmentIndex"]) {
        [self updateViewHighlights];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void) updateViewHighlights {
    ///unhighligh all imageviews
    for (UIView *view in _views)
    {
        view.backgroundColor = self.normalColor;
    }
    
    if (_selectedSegmentIndex >= 0 && _selectedSegmentIndex < _views.count)
    {
        [[_views objectAtIndex:_selectedSegmentIndex] setBackgroundColor:self.highlightedColor];
    }
}

- (void)createViewsForItems:(NSArray *)items {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_views removeAllObjects];

    CGSize viewSize = CGSizeMake(self.frame.size.width / items.count - 1, self.frame.size.height);
    CGPoint origin = CGPointZero;
    for (NSString *string in items) {
        CGRect frame = { origin, viewSize };
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.userInteractionEnabled = NO;
        view.backgroundColor = self.normalColor;
        [self addSubview:view];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, viewSize.width, viewSize.height)];
        label.font = kFontArialMTOfSize(kFontSizeMiddium);
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        label.text = string;
        label.textColor = kHUColorWhite;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        [_views addObject:view];

        origin.x += viewSize.width + 1;
    }

    UIView *firstView = _views[0];
    CGFloat cornerRadius = firstView.height / 2;
    [firstView setRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                      withRadius:cornerRadius];

    UIView *lastView = [_views lastObject];
    [lastView setRoundedCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                     withRadius:cornerRadius];
    
    [self updateViewHighlights];
}

- (void)highlightSelectedIndexForLocation:(CGPoint)point select:(BOOL)select {
    BOOL hasHighlighted = NO;
    NSInteger lastHighlightedIndex = self.selectedSegmentIndex;
    for (UIView *view in _views) {
        if (CGRectContainsPoint(view.frame, point)) {
            view.backgroundColor = self.highlightedColor;

            if (select) {
                NSInteger index = [_views indexOfObject:view];
                self.selectedSegmentIndex = index;
            }
        } else {
            view.backgroundColor = self.normalColor;
        }

        if ([view.backgroundColor isEqual:self.highlightedColor]) {
            hasHighlighted = YES;
        }
    }

    ///if there are no highlighted tabs, highlight the last one used again.
    if (!hasHighlighted) {
        self.selectedSegmentIndex = lastHighlightedIndex;
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self highlightSelectedIndexForLocation:[touch locationInView:self] select:NO];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self highlightSelectedIndexForLocation:[touch locationInView:self] select:NO];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self highlightSelectedIndexForLocation:[touch locationInView:self] select:YES];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
}

@end
