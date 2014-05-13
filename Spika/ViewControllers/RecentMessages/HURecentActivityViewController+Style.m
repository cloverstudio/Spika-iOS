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

#import "HURecentActivityViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "UILabel+Extensions.h"
#import "HUActivityMessageCell.h"
#import "CSGraphics.h"

@implementation HURecentActivityViewController (Style)

-(UIView *) newTableHeaderViewWithTitle:(NSString *)title {
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [[self class] heightForHeaderView])];
	view.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
	
	UILabel *label = [UILabel labelWithText:title font:kFontArialMTOfSize(kFontSizeMiddium)];
	label.frame = CGRectMake(
        10,
        5,
        300,
        30
    );
    
	label.textColor = [UIColor whiteColor];

	[view addSubview:label];
	
	return view;
}

+(CGFloat) heightForHeaderView {
	return 32;
}

-(UILabel *)noItemsLabel
{
	UILabel *label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	label.text = NSLocalizedString(@"No Recent Activities", nil);
	label.font = [UIFont systemFontOfSize:kFontSizeSmall];
	CGSize size = [label.text sizeForBoundingSize:CGSizeMake(NSNotFound, NSNotFound) font:label.font];
	label.frame = CGRectMake(0, 110, size.width, size.height);
	label.textAlignment = NSTextAlignmentCenter;
	label.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, label.center.y);
	label.hidden = NO;
	return label;
}

@end
