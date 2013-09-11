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

#import "HUImageView+Style.h"

@implementation HUImageView (Style)

#pragma mark - UIImageView

- (UIImageView *)createNewSpinnerImageView {
    UIImageView *imageView = [CSKit imageViewWithImage:[HUImageView spinnerImage]
                                      highlightedImage:nil];

    imageView.frame = [self frameForSpinnerImageView];

    return imageView;
}

#pragma mark - Frames

- (CGRect)frameForSpinnerImageView {
    CGSize spinnerImageSize = [HUImageView spinnerImage].size;

    return CGRectMake(CGRectGetWidth(self.frame) / 2 - spinnerImageSize.width / 2,
                      CGRectGetHeight(self.frame) / 2 - spinnerImageSize.height / 2,
                      spinnerImageSize.width,
                      spinnerImageSize.height);
}

#pragma mark - Images

+ (UIImage *)spinnerImage {
    return [UIImage imageNamed:@"hu_loading_indicator.png"];
}

@end
