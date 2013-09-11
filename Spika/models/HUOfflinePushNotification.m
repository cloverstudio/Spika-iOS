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

#import "HUOfflinePushNotification.h"
#import "CSGraphics.h"
#import "UIColor+Aditions.h"
#import "UILabel+Extensions.h"

@implementation HUOfflinePushNotification

#pragma mark - Construction

-(UIView *) loadView:(CGRect)rect {
    
    UIView *contentView = [super loadView:rect];
    contentView.height = 36;
    
    UIView *colorView = [[UIView alloc] initWithFrame:contentView.bounds];
    colorView.backgroundColor = [[UIColor colorFromHexString:@"#e81757"] colorWithAlphaComponent:.81f];
    [contentView addSubview:colorView];
    
    UILabel *label = [UILabel labelWithText:NSLocalizedString(@"NO INTERNET CONNECTION", nil)];
    label.textColor = [UIColor whiteColor];
    label.center = CGPointShiftRight(contentView.center, 20);
    [contentView addSubview:label];
    
    UIImageView *imageView = [CSKit imageViewWithImageNamed:@"hu_alert_icon"];
    imageView.center = label.center;
    imageView.x = label.x - imageView.width;
    [contentView addSubview:imageView];
    
    return contentView;
}

#pragma mark - Datasource

-(BOOL) hasCancelButton {
    return NO;
}

@end
