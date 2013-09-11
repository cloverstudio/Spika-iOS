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

#import "HUMyGroupProfileViewController+Style.h"
#import "HUGroupProfileViewController+Style.h"
#import "HUNewGroupViewController+Style.h"
#import "HUBaseViewController+Style.h"

@implementation HUMyGroupProfileViewController (Style)

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


- (CGRect) frameForButton {
    
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
    
    CGRect buttonFrame = [self frameForButton];
    
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

- (UIButton *) newDeleteButtonWithSelector:(SEL)aSelector {
    
    CGRect buttonFrame = [self frameForButton];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [[button titleLabel] setFont:[self fontForButtons]];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"Delete", @"") forState:UIControlStateNormal];
    
    [button addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


#pragma mark - Font

- (UIFont *) fontForButtons {
    
    return kFontArialMTBoldOfSize(kFontSizeMiddium);
}


@end
