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

#import "HUExploreUsersView.h"
#import "HUSegmentedControl.h"
#import "HUDoubleSliderView.h"

@implementation HUExploreUsersView
{
    HUSegmentedControl *_segmentedControl;
    HUDoubleSliderView *_doubleSlider;
    NSArray *_genders;
}

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 100)];
    if (self) {
        // Initialization code
        
        _genders = @[HUGenderNone, HUGenderFemale, HUGenderMale];
        
        _segmentedControl = [[HUSegmentedControl alloc] initWithFrame:CGRectMake(6, 10, 200, 34)];
        _segmentedControl.items = @[NSLocalizedString(@"all", NULL) ,
                                    NSLocalizedString(@"female", NULL),
                                    NSLocalizedString(@"male", NULL)];
        [self addSubview:_segmentedControl];
        
        _doubleSlider = [[HUDoubleSliderView alloc] initWithFrame:CGRectMake(6, 54, 309, 34)];
        _doubleSlider.leftValueMax = 0;
        _doubleSlider.rightValueMax = 100;
        _doubleSlider.description = NSLocalizedString(@"Slide to pick age..." , NULL);
        [self addSubview:_doubleSlider];
        
        UIButton *button = [HUControls buttonWithCenter:CGPointMake(160, 95)
                                         localizedTitle:@"ExploreBtn"
                                        backgroundColor:kHUColorGreen
                                             titleColor:kHUColorWhite
                                                 target:self
                                               selector:@selector(search)];
        button.frame = CGRectMake(210, 10, 105, 34);
        [self addSubview:button];
    }
    return self;
}

-(void) search {
    [self.delegate exploreView:self
                 exploreGender:_genders[_segmentedControl.selectedSegmentIndex]
                       fromAge:_doubleSlider.leftValue
                         toAge:_doubleSlider.rightValue];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
