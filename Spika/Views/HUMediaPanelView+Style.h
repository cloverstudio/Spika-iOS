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

#import "HUMediaPanelView.h"

@class CSPageControl;

@interface HUMediaPanelView (Style)

#pragma mark - UIViews
- (UIView *)newScrollEmotionViewContainer;

#pragma mark - UIScrollView
- (UIScrollView *)newScrollEmotionView;

#pragma mark - UIPageControll
- (CSPageControl *)newPageControll;

#pragma mark - UIButtons
- (UIButton *)newCameraBtn:(SEL)aSelector;
- (UIButton *)newVideoBtn:(SEL)aSelector;
- (UIButton *)newAlbumBtn:(SEL)aSelector;
- (UIButton *)newEmojiBtn:(SEL)aSelector;
- (UIButton *)newLocationBtn:(SEL)aSelector;
- (UIButton *)newVoiceButton:(SEL)aSelector;

#pragma mark - Frames
- (CGRect) frameForScrollEmotionContainerView;
- (CGRect) frameForScrollEmotionView;
- (CGRect) frameForPageControll:(CGSize)pageControllSize;
- (CGRect) frameForCameraButton;
- (CGRect) frameForVideoButton;
- (CGRect) frameForAlbumButton;
- (CGRect) frameForEmojiButton;
- (CGRect) frameForLocationButton;
- (CGRect) frameForVoiceButton;

#pragma mark - UIColors
- (UIColor *) colorForSelectedPageDot;
- (UIColor *) colorForOtherPageDot;

@end
