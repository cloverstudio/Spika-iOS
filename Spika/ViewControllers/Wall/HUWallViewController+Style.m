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

#import "HUWallViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "HPGrowingTextView.h"
#import "HUMediaPanelView.h"
#import "UIImage+Aditions.h"
#import "UIColor+Aditions.h"
#import "CSGraphics.h"

#define kHeightMessageInputContainer    36

@implementation HUWallViewController (Style)

#pragma mark - UIViews

- (UIView *) contentView {

    UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    contentView.autoresizingMask = self.view.autoresizingMask;
    
    return contentView;
}

- (UIView *) messageInputContainer {

    UIView *viewMessageInputHolder = [[UIView alloc] initWithFrame:[self frameForMessageInputContainer]];
    viewMessageInputHolder.backgroundColor = [self wallBackgroundColor];
    viewMessageInputHolder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    viewMessageInputHolder.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    viewMessageInputHolder.layer.borderWidth = 1.0;
    
    return viewMessageInputHolder;
}

#pragma mark - UITableView

- (UITableView *) messagesTableView {

    UITableView *tableView = [[UITableView alloc] initWithFrame:[self frameForMessagesTableView] style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [self wallBackgroundColor];
    tableView.autoresizingMask = self.view.autoresizingMask;

    return tableView;
}

#pragma mark - UIButtons

- (UIButton *) mediaButton {

    UIButton *mediaButton = [CSButton buttonWithFrame:[self frameForMediaButton]
                                             callback:nil];
    
    mediaButton.backgroundColor = [self wallBackgroundColor];
    
    UIImage *arrowImage = [UIImage imageWithBundleImage:@"hp_show_media_button"];
    
    UIImageView *arrowUpImageView = [CSKit imageViewWithImage:arrowImage
                                             highlightedImage:nil];
    arrowUpImageView.userInteractionEnabled = NO;
    [arrowUpImageView setFrame:CGRectMake(CGRectGetWidth(mediaButton.frame) / 2 - arrowImage.size.width / 2,
                                          CGRectGetHeight(mediaButton.frame) / 2 - arrowImage.size.height / 2,
                                          arrowImage.size.width,
                                          arrowImage.size.height)];
    [mediaButton addSubview:arrowUpImageView];
    
    return mediaButton;
}

- (UIButton *) sendButton {

    UIButton *sendButton = [CSButton buttonWithFrame:[self frameForSendButton]
                                   callback:nil];
    
    [sendButton setBackgroundColor:[self colorForSendButton]];
    [sendButton setTitleColor:[self titleColorForButtonState:UIControlStateNormal] forState:UIControlStateNormal];
    [sendButton setTitleColor:[self titleColorForButtonState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
    
    return sendButton;
}

#pragma mark - HPGrowingTextView

- (HPGrowingTextView *) messageInputTextField {

    HPGrowingTextView *messageInputTextField = [[HPGrowingTextView alloc] initWithFrame:[self frameForMessageInputTextField]];
    messageInputTextField.contentInset = UIEdgeInsetsMake(0, 5, 5, 0);
    messageInputTextField.font = [self fontForMessageInputTextField];
    messageInputTextField.maxNumberOfLines = 3;
    messageInputTextField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    messageInputTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    return messageInputTextField;
}

#pragma mark - HUMediaPanelView

- (HUMediaPanelView *) mediaPanelView {

    HUMediaPanelView *mediaPanelView = [[HUMediaPanelView alloc] initWithFrame:[self frameForMediaPanel]];
    return mediaPanelView;
}

#pragma mark - UIBarButtonItems NSArray

- (NSArray *) profileBarButtonItemsWithSelector:(SEL)aSelector {
    
    return [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"PROFILE", nil)
                                                  frame:[self frameForProfileButton]
                                        backgroundColor:[self colorForProfileButton]
                                                 target:self
                                               selector:aSelector];
}

#pragma mark - Shadows

-(void) setContentViewTopShadow:(UIView *)contentView {
 
    UIImageView *tableViewShadow = [CSKit imageViewWithImageNamed:@"hp_wall_tableview_top_shadow"];
    tableViewShadow.width = contentView.width;
    tableViewShadow.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [contentView addSubview:tableViewShadow];
}

-(void) setShadowOnTopOfInputView:(UIView *)inputView {
    
    UIImageView *inputViewShadow = [CSKit imageViewWithImageNamed:@"hp_wall_tableview_bottom_shadow"];
    inputViewShadow.width = inputView.width;
    inputViewShadow.y = -inputViewShadow.height;
    inputViewShadow.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [inputView addSubview:inputViewShadow];
}

#pragma mark - Frames

- (CGRect) frameForProfileButton {
    
    return [HUBaseViewController frameForBarButtonWithTitle:NSLocalizedString(@"PROFILE", @"")
                                                       font:[HUBaseViewController fontForBarButtonItems]];
}

- (CGRect) frameForContentView {

    return self.view.bounds;
}

- (CGRect) frameForMessagesTableView {

    return CGRectMake(0,
                      0,
                      CGRectGetWidth([self frameForContentView]),
                      CGRectGetHeight([self frameForContentView]) - CGRectGetHeight([self frameForMessageInputContainer]));

}

- (CGRect) frameForMessageInputContainer {
    
    return CGRectMake(0,
                      CGRectGetHeight(self.contentViewFrame) - kHeightMessageInputContainer,
                      CGRectGetWidth(self.contentViewFrame),
                      kHeightMessageInputContainer);
}

- (CGRect) frameForMediaButton {
    
    return CGRectMake(4, 0, 42, CGRectGetHeight([self frameForMessageInputContainer]));
}

- (CGRect) frameForSendButton {
    
    CGSize sendTitleSize = [NSLocalizedString(@"Send", @"") sizeForBoundingSize:CGSizeMake(NSNotFound, NSNotFound)
                                                                           font:[self fontForSendButton]];
    CGFloat width = sendTitleSize.width > 65 ? sendTitleSize.width : 65;
    
    CGRect messageInputContainerFrame = [self frameForMessageInputContainer];
    
    return CGRectMake(CGRectGetWidth(messageInputContainerFrame) - width,
                      0,
                      width,
                      CGRectGetHeight(messageInputContainerFrame));
}

- (CGRect) frameForMessageInputTextField {
    
    return CGRectMake(CGRectGetMaxX([self frameForMediaButton]),
                      0,
                      CGRectGetWidth([self frameForMessageInputContainer]) - CGRectGetMaxX([self frameForMediaButton]) - CGRectGetWidth([self frameForSendButton]),
                      CGRectGetHeight([self frameForMessageInputContainer]));
}

- (CGRect) frameForMediaPanel {
    
    return CGRectMake(0, CGRectGetMaxY([self frameForMessageInputContainer]), CGRectGetWidth([self frameForContentView]), 168);
}

#pragma mark - Colors

- (UIColor *) colorForProfileButton {

    return [HUBaseViewController sharedBarButtonItemColor];
}

- (UIColor *) wallBackgroundColor {

    return [HUBaseViewController sharedViewBackgroundColor];
}

- (UIColor *) colorForSendButton {

    return [HUBaseViewController sharedBarButtonItemColor];
//    return [UIColor colorWithIntegralRed:72 green:198 blue:208];
}

- (UIColor *) titleColorForButtonState:(UIControlState)state {

    return [HUBaseViewController titleColorForButtonState:state];
}

#pragma mark - Fonts

- (UIFont *) fontForSendButton {
    
    return kFontArialMTBoldOfSize(kFontSizeSmall);
}

- (UIFont *) fontForMessageInputTextField {

    return kFontArialMTOfSize(kFontSizeMiddium);
}

@end
