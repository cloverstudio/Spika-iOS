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

#import "HUGroupsViewController+Style.h"
#import "HUBaseViewController+Style.h"

#define kWidthCancleSearchButton    43
#define kHeightSearchField          44

@implementation HUGroupsViewController (Style)

#pragma mark - UIViews
- (UIView *) newSearchFieldContainerView {

    UIView *view = [CSKit viewWithFrame:[self frameForSearchContainerView]];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *coloredView = [CSKit viewWithFrame:[self frameForSearchContainerColoredView]];
    coloredView.backgroundColor = [self colorForSearchFieldContainerView];
    [view addSubview:coloredView];
    
    return view;
}

#pragma mark - UITextField

- (CSTextField *) newSearchField {

    CSTextField *textField = [[CSTextField alloc] initWithFrame:[self frameForSearchField]];
    textField.font = [self fontForSearchTextField];
    textField.placeholder = NSLocalizedString(@"Search-Groups", @"");
    textField.placeholderTextColor = [UIColor whiteColor];
    textField.textColor = [UIColor whiteColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.returnKeyType = UIReturnKeySearch;
    textField.backgroundColor = [UIColor clearColor];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    return textField;
}

#pragma mark - UIButtons

- (UIButton *) newCancleSearchButton:(SEL)aSelector {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = [self frameForCancleSearchButton];
    button.adjustsImageWhenHighlighted = YES;
    
    [button addTarget:self
               action:aSelector
     forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *cancleSearchImageView = [CSKit imageViewWithImage:[UIImage imageWithBundleImage:@"hu_dismiss_button"]
                                                  highlightedImage:nil];
    
    cancleSearchImageView.frame = [self frameForCancleSearchButtonImageView];
//    cancleSearchImageView.userInteractionEnabled = NO;
    [button addSubview:cancleSearchImageView];
    
    return button;
}

- (UIButton *) newCommitSearchButton:(SEL)aSelector {

    UIButton *button = [CSKit buttonWithNormalImageNamed:@"hu_magnifying_glass"
                                        highlightedImage:nil];
    
    button.frame = [self frameForCommmitSearchButton];
    button.adjustsImageWhenHighlighted = YES;
    
    [button addTarget:self
               action:aSelector
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - UIBarButtonItems NSArray

- (NSArray *) addGroupBarButtonItemsWithSelector:(SEL)aSelector {

    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Add-Group", @"")
                                                  frame:[self frameForAddGroupButton]
                                        backgroundColor:[HUBaseViewController sharedBarButtonItemColor]
                                                 target:self
                                               selector:aSelector];
}

#pragma mark - Frames

- (CGRect) frameForAddGroupButton {

    return [HUBaseViewController frameForBarButtonWithTitle:NSLocalizedString(@"Add-Group", @"")
                                                       font:[HUBaseViewController fontForBarButtonItems]];
}

- (CGRect) frameForTableView {

    return CGRectMake(0,
                      0,
                      CGRectGetWidth(self.view.bounds),
                      CGRectGetHeight(self.view.bounds));
}

- (CGRect) frameForSearchContainerView {

    return CGRectMake(0, 1, CGRectGetWidth(self.view.bounds), kHeightSearchField);
}

- (CGRect) frameForSearchContainerColoredView {

    return CGRectMake(kWidthCancleSearchButton, 0, CGRectGetWidth([self frameForSearchContainerView]) - kWidthCancleSearchButton, kHeightSearchField);
}

- (CGRect) frameForCancleSearchButton {

    return CGRectMake(0, 0, kWidthCancleSearchButton, kHeightSearchField);
}

- (CGRect) frameForCancleSearchButtonImageView {

    return CGRectMake(kWidthCancleSearchButton / 2 - 18 / 2, 14, 18, 18);
}

- (CGRect) frameForCommmitSearchButton {

    UIImage *magnifyingImage = [UIImage imageWithBundleImage:@"hu_magnifying_glass"];
    
    CGRect searchContainerFrame = [self frameForSearchContainerView];
    
    return CGRectMake(CGRectGetWidth(searchContainerFrame) - magnifyingImage.size.width - 9,
                      CGRectGetHeight(searchContainerFrame) / 2 - magnifyingImage.size.height / 2,
                      magnifyingImage.size.width,
                      magnifyingImage.size.height);
}

- (CGRect) frameForSearchField {
    
    CGRect commitSearchButtonFrame = [self frameForCommmitSearchButton];

    return CGRectMake(kWidthCancleSearchButton + 5,
                      0,
                      CGRectGetMinX(commitSearchButtonFrame) - (kWidthCancleSearchButton + 15),
                      kHeightSearchField);
}

#pragma mark - Colors

- (UIColor *) colorForSearchFieldContainerView {
    
    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
}

- (UIColor *) textColorForSearchField {

    return [UIColor whiteColor];
}

#pragma mark - Fonts

- (UIFont *) fontForSearchTextField {
    
    return kFontArialMTOfSize(kFontSizeMiddium);
}

-(UILabel *)createNoGroupsLabel
{
	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.text = NSLocalizedString(@"No Groups", nil);
	label.font = [UIFont systemFontOfSize:kFontSizeSmall];
	CGSize size = [label.text sizeForBoundingSize:CGSizeMake(NSNotFound, NSNotFound)
                                             font:label.font];
    
	label.frame = CGRectMake(0, 110, size.width, size.height);
	label.textAlignment = NSTextAlignmentCenter;
	label.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, label.center.y);
	label.hidden = YES;
	return label;
}

@end
