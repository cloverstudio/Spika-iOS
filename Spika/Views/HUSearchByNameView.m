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

#import "HUSearchByNameView.h"
#import "NSString+Extensions.h"

@interface HUSearchByNameView ()
@property (nonatomic, weak) CSTextField *searchField;
@end

@implementation HUSearchByNameView

-(NSString*) placeholderString {
    return NSLocalizedString(@"Type name...", NULL);
}

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 60)];
    if (self) {        
        CGRect frame = CGRectMake(6, 5, 200, 44);
        CSTextField *textField = [[CSTextField alloc] initWithFrame:frame];
        textField.font = kFontArialMTOfSize(kFontSizeSmall);
        textField.textInset = CGPointMake(4, 0);
        textField.placeholderInset = CGPointMake(4, 0);
        textField.borderStyle = UITextBorderStyleNone;
        textField.returnKeyType = UIReturnKeySearch;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.backgroundColor = kHUColorWhite;
        textField.delegate = self;
        [self addSubview:textField];
        self.searchField = textField;
        
        UIButton *button = [HUControls buttonWithCenter:CGPointMake(160, 95)
                                         localizedTitle:@"Search"
                                        backgroundColor:kHUColorGreen
                                             titleColor:kHUColorWhite
                                                 target:self
                                               selector:@selector(search)];
        button.frame = CGRectMake(210, 10, 105, 34);
        [self addSubview:button];
    }
    return self;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self search];
    return YES;
}

-(void) search {
    [self.delegate searchView:self searchText:_searchField.text];
    [self endEditing:YES];
}

@end
