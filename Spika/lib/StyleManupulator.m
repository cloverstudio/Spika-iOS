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

#import <QuartzCore/QuartzCore.h>
#import "StyleManupulator.h"

@implementation StyleManupulator

+(UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];

}

+(void) attachNavigationBarStyle:(UINavigationBar *)navBar{
    navBar.tintColor = [UIColor darkGrayColor];
}

+(void) attachDefaultButton:(UIButton *)view{

    view.backgroundColor = [self colorWithHexString:@"8A8A7B"];
    [view.layer setCornerRadius:3.0f];
    
    view.titleLabel.textColor = [UIColor whiteColor];
    
    
}

+(void) attachDefaultTextField:(UIView *)view{
    
    view.layer.borderColor = [self colorWithHexString:@"555555"].CGColor;
    view.layer.borderWidth = 1.0f;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[self colorWithHexString:@"F5F5F0"]CGColor], (id)[[self colorWithHexString:@"FFFFFF"]CGColor], nil];
    [view.layer addSublayer:gradient];
    
}

+(void) attachDefaultTextView:(UIView *)view{
    
    view.layer.borderColor = [self colorWithHexString:@"555555"].CGColor;
    view.layer.borderWidth = 1.0f;

    view.backgroundColor = [self colorWithHexString:@"F5F5F0"];
}

+(void) attachDefaultBG:(UIView *)view{
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[self colorWithHexString:@"DFDFD0"]CGColor], (id)[[self colorWithHexString:@"FFFFFF"]CGColor], nil];
    [view.layer addSublayer:gradient];
    
}

+(void) attachSideMenuBG:(UIView *)view{
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[self colorWithHexString:@"000000"] CGColor], (id)[[self colorWithHexString:@"000000"] CGColor], nil];
    
    [view.layer addSublayer:gradient];
    
}

+(void) attachSideMenuCellBGBig:(UITableViewCell *)cell{
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:
                   (id)[[self colorWithHexString:@"000000"] CGColor], (id)[[self colorWithHexString:@"000000"] CGColor], nil];
    
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    
    CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = cell.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:
                           (id)[[self colorWithHexString:@"151515"] CGColor], (id)[[self colorWithHexString:@"252525"] CGColor], nil];
    
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];
    
    [cell.textLabel setTextColor: [UIColor whiteColor]];
    cell.textLabel.font = [UIFont systemFontOfSize:kFontSizeSmall];
    
}

+(void) attachDefaultCellBG:(UITableViewCell *)cell{
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:
                   (id)[[self colorWithHexString:@"F5F5F0"]CGColor], (id)[[self colorWithHexString:@"FFFFFF"]CGColor], nil];
    
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    
    CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = cell.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:
                           (id)[[self colorWithHexString:@"151515"] CGColor], (id)[[self colorWithHexString:@"252525"] CGColor], nil];
    
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];
    
    [cell.textLabel setTextColor: [UIColor darkGrayColor]];
    cell.textLabel.font = [UIFont systemFontOfSize:kFontSizeSmall];
    
    
}

+(void) attachDefaultCellFont:(UILabel *)label{
    
    label.backgroundColor = [UIColor clearColor];
    [label setTextColor: [UIColor darkGrayColor]];
    label.font = [UIFont systemFontOfSize:kFontSizeSmall];
    
}


+(void) attachWallTextViewBG:(UIView *)view{
    

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[self colorWithHexString:@"F8F8F9"] CGColor], (id)[[self colorWithHexString:@"BEC0C3"] CGColor], nil];
    [view.layer addSublayer:gradient];

    
}


+(void) attachWallTextView:(UIView *)view{
    
    view.backgroundColor = [UIColor whiteColor];

    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
   
    view.layer.borderColor = [self colorWithHexString:@"9C9DA1"].CGColor;
    view.layer.borderWidth = 1.0f;
}

+(void) attachWallButtons:(UIButton *)view{
    
    view.backgroundColor = [self colorWithHexString:@"757A84"];
    view.titleLabel.textColor = [UIColor whiteColor];
    view.titleLabel.font = [UIFont fontWithName:@"Arial" size:12];
    
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 5;


}

+(void) attachTextMessageCell:(MessageTypeTextCell *)cell{
    
    
    
}

+(void) attachTextMessageHolderBG:(UIView *)view{
    
    view.backgroundColor = [self colorWithHexString:@"F5F5F0"];

    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 3;
    view.layer.shadowOffset = CGSizeMake(1, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 0.5;
    
}

+(void) attachTextMessageLabel:(UILabel *)label{
    
    label.backgroundColor = [UIColor clearColor];
    label.font = MessageBodyFont;
}

+(void) attachTextMessageInfoLabel:(UILabel *)label{
    
    label.backgroundColor = [UIColor clearColor];
    label.font = MessageInfoFont;
    label.textColor = [UIColor lightGrayColor];
    
}

+(void) attachMediaButtonStyle:(UIButton *)button{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = button.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[self colorWithHexString:@"101010"] CGColor], (id)[[self colorWithHexString:@"202020"] CGColor], nil];
    
    [button.layer addSublayer:gradient];
    
    button.titleLabel.textColor = [UIColor whiteColor];
}

+(void) attachImagePreviewStyle:(UIView *)view{

    view.layer.borderColor = [self colorWithHexString:@"ffffff"].CGColor;
    view.layer.borderWidth = 2.0f;
    
}

+(void) attachMessageImageViewFrameStyle:(UIView *)view{
    
    view.backgroundColor = [UIColor whiteColor];
    
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 3;
    view.layer.shadowOffset = CGSizeMake(1, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 0.5;

}

+(void) attachMessageVideoViewFrameStyle:(UIView *)view{
    
    view.backgroundColor = [UIColor blackColor];
    
}


+(void) attachCommentNumLabelStyle:(UILabel *)label{

    label.backgroundColor = [self colorWithHexString:@"CC0000"];
    

    label.layer.borderColor = [self colorWithHexString:@"000000"].CGColor;
    label.layer.borderWidth = 2.0f;

    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 10;

    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
}

+(void) attachLoadingRowStyle:(UIView *)view{
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[self colorWithHexString:@"F8F8F9"] CGColor], (id)[[self colorWithHexString:@"F8F8F9"] CGColor], nil];
    
    [view.layer addSublayer:gradient];

}

+(void) attachDefaultLabel:(UILabel *)label{

    label.backgroundColor = [UIColor clearColor];

    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    label.textColor = [UIColor grayColor];

    
}

+(void) attachMessageVideoViewFrameStylePlayLabel:(UILabel *)label{
    label.backgroundColor = [UIColor clearColor];
    label.font = GeneralBoldFont;
    label.textColor = [UIColor whiteColor];

    label.textAlignment = NSTextAlignmentCenter;
}

+(void) attachMessageLocationViewFrameStylePlayLabel:(UILabel *)label{
    label.backgroundColor = [UIColor clearColor];
    label.font = GeneralBoldFont;
    label.textColor = [UIColor whiteColor];
    
    label.textAlignment = NSTextAlignmentCenter;
}
@end
