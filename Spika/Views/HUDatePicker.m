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

#import "HUDatePicker.h"
#import "HUBaseViewController+Style.h"

@implementation HUDatePicker{
    UIDatePicker *_datePicker;
}

@synthesize datePicker = _datePicker;

- (id)init
{
    
    self = [super init];
    
    if (self) {
        
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;

        _datePicker.frame = CGRectMake(
            0,kToolbarHeight,320,kUIPickerViewHeight
        );
        
        self.frame = CGRectMake(
            0,[[UIScreen mainScreen] bounds].size.height,320,kUIPickerViewHeight+kToolbarHeight
        );
        

        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *button = [self newDoneButtonWithSelector:@selector(done)];
        
        [self addSubview:_datePicker];
        [self addSubview:button];
    }
    
    return self;
    
}

- (UIButton *) newDoneButtonWithSelector:(SEL)aSelector {
    
    int buttonWidth = 100;
    
    CGRect buttonFrame = CGRectMake(
        self.width - buttonWidth,0,buttonWidth,kToolbarHeight
    );
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:kFontArialMTBoldOfSize(kFontSizeMiddium)];
    [button setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    
    [button addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void) done{
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(datePickerSelected)]){
        [self.delegate performSelector:@selector(datePickerSelected)];
    }
    
}

@end
