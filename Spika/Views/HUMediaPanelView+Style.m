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

#import "HUMediaPanelView+Style.h"
#import "UIColor+Aditions.h"
#import "UILabel+Extensions.h"
#import "CSPageControl.h"
#import "CSGraphics.h"
#import "MAKVONotificationCenter.h"

#define kButtonImageWidth       99
#define kButtonImageHeight      76

#define kPaddingLeftFirst       8
#define kPaddingMiddle          4
#define kPaddingTopFirst        6
#define kPaddingSecondFirst     3

@implementation HUMediaPanelView (Style)

#pragma mark - UIViews

- (UIView *)newScrollEmotionViewContainer {

    UIView *view = [CSKit viewWithFrame:[self frameForScrollEmotionContainerView]];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}

#pragma mark - UIScrollView

- (UIScrollView *)newScrollEmotionView {

    CGRect scrollEmotionViewFrame = [self frameForScrollEmotionView];
    
    UIScrollView *scrollView = [CSKit scrollViewWithFrame:scrollEmotionViewFrame
                                              contentSize:CGSizeMake(CGRectGetWidth(scrollEmotionViewFrame),
                                                                     CGRectGetHeight(scrollEmotionViewFrame))
                                                 delegate:nil];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    
    return scrollView;
}

#pragma mark - UIPageControll

- (CSPageControl *)newPageControll {

    CSPageControl *pageControll = [[CSPageControl alloc] init];
    pageControll.backgroundColor = [UIColor clearColor];
    pageControll.dotColorCurrentPage = [self colorForSelectedPageDot];
    pageControll.dotColorOtherPage = [self colorForOtherPageDot];
    
    return pageControll;
}

#pragma mark - Style

-(void) stylizeButton:(UIButton *)button withTitle:(NSString *)title {
    
    button.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [UILabel labelWithText:title font:kFontArialMTOfSize(kFontSizeSmall)];
    label.center = CGPointShiftDown(CGRectGetCenter(button.bounds), 25);
    
    __block UILabel *_label = label;
    __block HUMediaPanelView *this = self;
    [button addObservationKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew block:^(MAKVONotification *notification) {
        UIButton *btn = [notification target];
        _label.textColor = btn.isHighlighted ? this.colorForSelectedPageDot : [UIColor blackColor];
    }];
    
    [button addSubview:label];
}

#pragma mark - UIButtons

- (UIButton *) newCameraBtn:(SEL)aSelector {

    UIButton *cameraBtn = [CSKit buttonWithNormalImageNamed:@"camera_more_icon"
                                           highlightedImage:@"camera_more_icon_active"
                                                     target:self
                                                   selector:aSelector
                                                     origin:CGPointZero];
    [cameraBtn setFrame:[self frameForCameraButton]];
    
    [self stylizeButton:cameraBtn withTitle:NSLocalizedString(@"Camera", nil)];
    
    return cameraBtn;
}

- (UIButton *) newVideoBtn:(SEL)aSelector {

    UIButton *videoBtn = [CSKit buttonWithNormalImageNamed:@"video_more_icon"
                                          highlightedImage:@"video_more_icon_active"
                                                    target:self
                                                  selector:aSelector
                                                    origin:CGPointZero];
    [videoBtn setFrame:[self frameForVideoButton]];
    
    [self stylizeButton:videoBtn withTitle:NSLocalizedString(@"Video", nil)];
    
    return videoBtn;
}

- (UIButton *) newAlbumBtn:(SEL)aSelector {

    UIButton *albumBtn = [CSKit buttonWithNormalImageNamed:@"albums_more_icon"
                                          highlightedImage:@"albums_more_icon_active"
                                                    target:self
                                                  selector:aSelector
                                                    origin:CGPointZero];
    [albumBtn setFrame:[self frameForAlbumButton]];
    
    [self stylizeButton:albumBtn withTitle:NSLocalizedString(@"Gallery", nil)];

    return albumBtn;
}

- (UIButton *) newEmojiBtn:(SEL)aSelector {

    UIButton *emojiBtn = [CSKit buttonWithNormalImageNamed:@"emoji_more_icon"
                                          highlightedImage:@"emoji_more_icon_active"
                                                    target:self
                                                  selector:aSelector
                                                    origin:CGPointZero];
    [emojiBtn setFrame:[self frameForEmojiButton]];
    
    [self stylizeButton:emojiBtn withTitle:NSLocalizedString(@"Emoji", nil)];
    
    return emojiBtn;
}

- (UIButton *) newLocationBtn:(SEL)aSelector {

    UIButton *locationBtn = [CSKit buttonWithNormalImageNamed:@"location_more_icon"
                                             highlightedImage:@"location_more_icon_active"
                                                       target:self
                                                     selector:aSelector
                                                       origin:CGPointZero];
    [locationBtn setFrame:[self frameForLocationButton]];
    
    [self stylizeButton:locationBtn withTitle:NSLocalizedString(@"Location", nil)];
    
    return locationBtn;
}

- (UIButton *) newVoiceButton:(SEL)aSelector {

    UIButton *voiceButton = [CSKit buttonWithNormalImageNamed:@"mic_voice_icon"
                                             highlightedImage:@"mic_voice_icon_active"
                                                       target:self
                                                     selector:aSelector
                                                       origin:CGPointZero];
    [voiceButton setFrame:[self frameForVoiceButton]];
    
    [self stylizeButton:voiceButton withTitle:NSLocalizedString(@"Record", nil)];
    
    return voiceButton;
}

#pragma mark - Frames

- (CGRect) frameForScrollEmotionContainerView {

    return CGRectMake(8, 8, 304, 152);
}

- (CGRect) frameForScrollEmotionView {

    return CGRectMake(0, 0, 304, 152);
}

- (CGRect) frameForPageControll:(CGSize)pageControllSize {

    CGRect scrollViewEmoticonsFrame = [self frameForScrollEmotionView];
    
    return CGRectMake(CGRectGetWidth(scrollViewEmoticonsFrame) / 2 - pageControllSize.width / 2,
                      CGRectGetHeight(scrollViewEmoticonsFrame) - (pageControllSize.height + 3),
                      pageControllSize.width,
                      pageControllSize.height);
}

- (CGRect) frameForCameraButton {
    
    return CGRectMake(kPaddingLeftFirst, kPaddingTopFirst, kButtonImageWidth, kButtonImageHeight);
}

- (CGRect) frameForAlbumButton {
    
    return CGRectMake(CGRectGetMaxX([self frameForCameraButton]) + kPaddingMiddle,
                      CGRectGetMinY([self frameForCameraButton]),
                      kButtonImageWidth,
                      kButtonImageHeight);
}

- (CGRect) frameForVideoButton {
    
    return CGRectMake(CGRectGetMaxX([self frameForAlbumButton]) + kPaddingMiddle,
                      CGRectGetMinY([self frameForCameraButton]),
                      kButtonImageWidth,
                      kButtonImageHeight);
}

- (CGRect) frameForEmojiButton {
    
    return CGRectMake(kPaddingLeftFirst,
                      CGRectGetMaxY([self frameForCameraButton]) + kPaddingSecondFirst,
                      kButtonImageWidth,
                      kButtonImageHeight);
}

- (CGRect) frameForLocationButton {
    
    return CGRectMake(CGRectGetMaxX([self frameForEmojiButton]) + kPaddingMiddle,
                      CGRectGetMinY([self frameForEmojiButton]),
                      kButtonImageWidth,
                      kButtonImageHeight);
}

- (CGRect) frameForVoiceButton {
    
    return CGRectMake(CGRectGetMaxX([self frameForLocationButton]) + kPaddingMiddle,
                      CGRectGetMinY([self frameForEmojiButton]),
                      kButtonImageWidth,
                      kButtonImageHeight);
}

#pragma mark - UIColors

- (UIColor *) colorForSelectedPageDot {

    return [UIColor colorWithIntegralRed:0 green:196 blue:207];
}

- (UIColor *) colorForOtherPageDot {

    return [UIColor colorWithIntegralRed:189 green:189 blue:189];
}

@end
