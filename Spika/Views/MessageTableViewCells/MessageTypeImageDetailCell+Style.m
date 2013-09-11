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

#import "MessageTypeImageDetailCell+Style.h"

#define kIconImageViewHeight 52

@implementation MessageTypeImageDetailCell (Style)

+ (CGRect) frameForAvatarIconView:(ModelMessage *)message
{
    return CGRectMake(15, 220, kIconImageViewHeight, kIconImageViewHeight);
}

-(UIView *) newContainerView {
    
    UIView *containerView = [[UIView alloc] initWithFrame:[MessageCell frameForContainerView:nil]];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.opaque = YES;
    
    return containerView;
}

+(CGRect) frameForContainerView:(ModelMessage *)message {
    
    CGFloat width = 300;
    
    return CGRectMake(10,-10,width,width-13);
    
}

+ (CGRect) frameForInfoLabel:(CGRect)viewFrame {
    
    return  CGRectMake(115,205,190,40);
}

@end
