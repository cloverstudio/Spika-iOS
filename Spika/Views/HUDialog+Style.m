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

#import "HUDialog+Style.h"
#import "CSGraphics.h"
#import "UIColor+Aditions.h"
#import "UIImage+Aditions.h"

#define DialogClass [self class]
#define kButtonCornerRadius 18

@implementation HUDialog (Style)

-(NSMutableArray *) newButtons {
    CGRect buttonFrame = CGRectMakeBoundsWithSize(self.buttonSize);
    
    NSMutableArray *buttons = [NSMutableArray new];
    
    NSInteger index = 0;
    for (NSString *string in self.otherTitles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.frame = buttonFrame;
        button.layer.cornerRadius = kButtonCornerRadius;
        [button.titleLabel setFont:kFontArialMTBoldOfSize(kFontSizeMiddium)];
        [button.titleLabel setUserInteractionEnabled:NO];
        [button setTitle:string forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[DialogClass otherButtonBackgroundColor] andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button setUserInteractionEnabled:YES];
        button.enabled = YES;
        button.clipsToBounds = YES;
        
        [buttons addObject:button];
        
        index++;
    }
    
    if (self.cancelTitle) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.frame = buttonFrame;
        button.layer.cornerRadius = kButtonCornerRadius;
        button.backgroundColor = [DialogClass cancelButtonBackgroundColor];
        [button.titleLabel setFont:kFontArialMTBoldOfSize(kFontSizeMiddium)];
        [button.titleLabel setUserInteractionEnabled:NO];
        [button setTitle:self.cancelTitle forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[DialogClass cancelButtonBackgroundColor] andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button setUserInteractionEnabled:YES];
        button.enabled = YES;
        button.clipsToBounds = YES;
        
        [buttons addObject:button];
    }
    
    return buttons;
}

#pragma mark - Style

-(CGPoint) validAnchorPointForPoint:(CGPoint)point {
    
    // X has priority
    if (point.x == 0.0f || point.x == 1.0f) {
        return point;
    } 
    
    return CGPointMake(point.x, roundf(point.y));
}

-(CGSize) buttonSize {
    return CGSizeMake(96, 34);
}

+(CGSize) minimumDialogSize {
    return CGSizeMake(220, 80);
}

+(CGSize) maximumDialogSize {
    return CGSizeMake(260, 200);
}

+(UIColor *) backgroundColor {
    return [UIColor whiteColor];
}

+(UIColor *) textColor {
    return [UIColor darkGrayColor];
}

+(UIColor *) cancelButtonBackgroundColor {
    return [UIColor colorWithIntegralRed:235 green:0 blue:86];
}

+(UIColor *) cancelButtonTextColor {
    return [UIColor whiteColor];
}

+(UIColor *) otherButtonBackgroundColor {
    return [UIColor colorWithIntegralRed:0 green:204 blue:123];
}

+(UIColor *) otherButtonTextColor {
    return [UIColor whiteColor];
}

@end
