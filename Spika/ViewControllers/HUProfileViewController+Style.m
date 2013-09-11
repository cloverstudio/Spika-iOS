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

#import "HUProfileViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "UIColor+Aditions.h"

#define kLabelMarginLeft     60

@implementation HUProfileViewController (Style)


- (UIScrollView *) newContentView {
    
    UIScrollView *contentView = [CSKit scrollViewWithFrame:self.view.bounds
                                               contentSize:self.view.bounds.size
                                                  delegate:nil];
    contentView.showsVerticalScrollIndicator = NO;
    
    return contentView;
}

#pragma mark - Frames

- (CGRect) frameForUserAvatarImageView {
	
	return CGRectZero;
}

- (HUImageView *) newUserAvatarImageView {
    
    HUImageView *userAvatarImageView = CS_AUTORELEASE([[HUImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]);
    userAvatarImageView.backgroundColor = [UIColor clearColor];
    userAvatarImageView.image = [UIImage imageNamed:@"user_stub_large"];
    
    
    return userAvatarImageView;
}

#pragma mark - UILabels

- (UIButton *) startConversationButton {
    
    UIButton *startConversationButton = CS_AUTORELEASE([[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, kStartButtonHeight)]);
    startConversationButton.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
    [startConversationButton setTitle:NSLocalizedString(@"Start-Conversation", nil) forState:UIControlStateNormal];
    [startConversationButton setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen] andSize:CGSizeMake(1,1)] forState:UIControlStateNormal];
    [startConversationButton setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDarkGreen] andSize:CGSizeMake(1,1)] forState:UIControlStateHighlighted];
    
    return startConversationButton;
}


- (HUEditableLabelView *) getEditorLabelByTitle:(NSString *)title{
    HUEditableLabelView *label = [[HUEditableLabelView alloc] init];
    [label setTitle:title];
    [label setTitleColor:[self textColorForLabel]];
    [label setEditorColor:[self textColorForEditor]];
    [label setTitleFont:[self fontForTextFields]];
    [label setEditorFont:[self fontForTextFields]];
    
    return label;
}

#pragma mark - button

- (CGRect) frameForOkButton {
    
    CGSize textTitleSize = [NSLocalizedString(@"Save", @"") sizeWithFont:[self fontForButtons]
                                                       constrainedToSize:CGSizeMake(90, 20)];
    
    textTitleSize = CGSizeMake(textTitleSize.width < 90 ?
                               90 : textTitleSize.width + 10,
                               36);
    
    return CGRectMake(0,
                      0,
                      textTitleSize.width,
                      textTitleSize.height);
    
}

- (UIButton *) newSaveButtonWithSelector:(SEL)aSelector {
    
    CGRect buttonFrame = [self frameForOkButton];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[self fontForButtons]];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"Save", @"") forState:UIControlStateNormal];
    
    [button addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Colors

- (UIColor *) viewBackgroundColor {
    
    return [HUBaseViewController sharedViewBackgroundColor];
}

- (UIColor *) textColorForLabel {
    
    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDark];
}

- (UIColor *) textColorForEditor {
    
    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
}


#pragma mark - Font

- (UIFont *) fontForButtons {
    
    return kFontArialMTBoldOfSize(kFontSizeMiddium);
}


-(UIFont *)fontForTextFields{
    
    UIFont *font = kFontMyriadProOfSize(kFontSizeMiddium);
    
    return font;
}


- (UIFont *) fontForUsernameLabel {
    
    return kFontMyriadProOfSize(kFontSizeMiddium);
}


#pragma mark - Navigation

-(NSArray *) editProfileBarButtonItemWithSelector:(SEL)aSelector editing:(BOOL) editing{
    
    if(editing){
        return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                            backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                     target:self
                                                   selector:aSelector];
        
    }else{
        return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Edit", nil)
                                                      frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                            backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen]
                                                     target:self
                                                   selector:aSelector];
        
    }
}

-(UIButton *) newButtonWithText:(NSString *)text selector:(SEL)aSelector {
	
	return nil;
}


-(NSArray *) addContactBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Add-Contact", nil)
                                                  frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                        backgroundColor:[HUBaseViewController sharedBarButtonItemColor]
                                                 target:self
                                               selector:aSelector];
}

-(NSArray *) removeContactBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Remove-Contact", nil)
                                                  frame:CGRectMake(0, 0, BarButtonWidth, 44)
                                        backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                 target:self
                                               selector:aSelector];
}


@end
