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

#import "HUSearchBarController+Style.h"
#import "HUBaseViewController+Style.h"
#import "UILabel+Extensions.h"
#import "UIImage+NoCache.h"
#import "CSGraphics.h"
#import "HURadioButton.h"

@implementation HUSearchBarController (Style)

-(UIView *) headerViewForText:(NSString *)text {
    
    if (!text) {
        return nil;
    }
    
    UIView *containerView = [UIView new];
    
    UILabel *label = [UILabel labelWithText:text];
    label.textColor = [UIColor whiteColor];
    [containerView addSubview:label];
    
    UIImageView *magnifyingGlass = [CSKit imageViewWithImage:[UIImage imageWithBundleImage:@"hu_magnifying_glass"] highlightedImage:nil];
    magnifyingGlass.center = label.center;
    magnifyingGlass.x = label.relativeWidth;
    [containerView addSubview:magnifyingGlass];
    
    containerView.width = magnifyingGlass.relativeWidth;
    containerView.height = MAX(label.relativeHeight, magnifyingGlass.relativeHeight);
    
    return containerView;
}

-(UIView *) viewForModel:(HUSearchBarModel *)model {
    
    UIView *view = nil;
    
    switch (model.type) {
        case HUSearchBarModelTypeTextField:
            view = [self textBoxForModel:model];
            break;
        case HUSearchBarModelTypeSelection:
            view = [self selectionForModel:model];
            break;
        default:
            view = [UIView new];
            break;
    }
    
    return view;
}

-(UIView *) textBoxForModel:(HUSearchBarModel *)model {
    
    HUSearchBarCellView *containerView = [[HUSearchBarCellView alloc] initWithFrame:[HUSearchBarController frameForTextBoxContainerView]];
    containerView.backgroundColor = [UIColor whiteColor];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectContract(containerView.bounds, 12)];
    textField.placeholder = model.text;
    textField.keyboardType = model.keyboardType;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [containerView addSubview:textField];
    
    __block UITextField *_textField = textField;
    model.callback = ^id{
        return _textField.text ? _textField.text : @"";
    };
    
    return containerView;
}

-(UIView *) selectionForModel:(HUSearchBarModel *)model {
    
    HUSearchBarCellView *containerView = [[HUSearchBarCellView alloc] initWithFrame:[HUSearchBarController frameForSelectionContainerView]];
    
    UILabel *label = [self labelWithText:model.text];
    label.center = CGRectGetCenter(containerView.bounds);
    label.x = 20;
    [containerView addSubview:label];
    
    UILabel *firstValue = [self labelWithText:model.firstValue];
    label.textColor = [UIColor whiteColor];
    firstValue.center = CGRectGetCenter(containerView.bounds);
    firstValue.x = label.relativeWidth + 40;
    [containerView addSubview:firstValue];
    
    UILabel *secondValue = [self labelWithText:model.secondValue];
    secondValue.center = CGRectGetCenter(containerView.bounds);
    secondValue.x = firstValue.relativeWidth + 40;
    [containerView addSubview:secondValue];
    
    UIImage *normalImage = [UIImage imageWithBundleImage:@"hu_button_off@2x"];
    UIImage *selectedImage = [UIImage imageWithBundleImage:@"hu_button_on@2x"];
    
    HURadioButton *firstButton = [HURadioButton buttonWithImage:normalImage selectedImage:selectedImage];
    firstButton.center = firstValue.center;
    firstButton.x = firstValue.relativeWidth + 2;
    [containerView addSubview:firstButton];
    
    HURadioButton *secondButton = [HURadioButton buttonWithImage:normalImage selectedImage:selectedImage];
    secondButton.center = secondValue.center;
    secondButton.x = secondValue.relativeWidth + 2;
    [containerView addSubview:secondButton];
    
    [HURadioButton linkButtons:firstButton, secondButton, nil];
    
    [firstButton setSelected:YES];
    
    __block HURadioButton *button = firstButton;
    
    model.callback = ^id{
        return button.selected ? @(YES) : @(NO);
    };
    
    return containerView;
}

-(UIButton *) searchButtonWithSelector:(SEL)aSelector {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Search" forState:UIControlStateNormal];
    [button setTitleColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen] forState:UIControlStateNormal];
    [button setFrame:[HUSearchBarController frameForSearchButton]];
    
    [button addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

-(UILabel *) labelWithText:(NSString *)text {
    UILabel *label = [UILabel labelWithText:text];
    label.textColor = [UIColor whiteColor];
    return label;
}

+(CGRect) frameForTextBoxContainerView {
    return CGRectMakeBounds(264, 55);
}

+(CGRect) frameForSelectionContainerView {
    return CGRectMakeBounds(264, 35);
}

+(CGRect) frameForSearchButton {
    return CGRectMakeBounds(180, 44);
}

@end
