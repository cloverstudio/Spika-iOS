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

#import "HUImageUploadViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "CSGraphics.h"

#define kButtonFrame CGRectMakeBounds(140, 44)

@implementation HUImageUploadViewController (Style)

#pragma mark - Buttons

-(UIButton *) newCancelButtonWithSelector:(SEL)aSelector {
    
    UIButton *button = [HUBaseViewController buttonWithTitle:NSLocalizedString(@"Cancel", nil)
                                                       frame:kButtonFrame
                                             backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                      target:self
                                                    selector:aSelector];
    
    return button;
}

-(UIButton *) newUploadButtonWithSelector:(SEL)aSelector {
    
    UIButton *button = [HUBaseViewController buttonWithTitle:NSLocalizedString(@"Upload", nil)
                                                       frame:kButtonFrame
                                             backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen]
                                                      target:self
                                                    selector:aSelector];
    
    return button;
    
}

#pragma mark - Frame

-(CGRect) frameForPreviewImage {
    
    CGSize winSize = [CSKit frame].size;
    CGSize imageSize = CGSizeMake(300.0f, 0.0f);
    CGFloat offset = (winSize.width - imageSize.width) * 0.5f;
    
    CGFloat scaleFactor = imageSize.width / self.image.size.width;
    imageSize.height = self.image.size.height * scaleFactor;

    CGPoint offsetPoint = CGPointMake(offset, MAX(30, self.view.center.y - imageSize.height));
    
    return CGRectWithPointAndSize(offsetPoint, imageSize);
}

@end
