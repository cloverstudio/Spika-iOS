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

#import "_HUPasswordBaseViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "CSGraphics.h"

@implementation _HUPasswordBaseViewController (Style)

-(HUDigitInputViewController *) newDigitInputViewController {
	CGFloat height = floorf([CSKit frame].size.height * 0.5458f);
	HUDigitInputViewController *viewController = [[HUDigitInputViewController alloc] initWithFrame:CGRectMakeBounds(274, height)];
	viewController.delegate = self;

	return viewController;
}

-(HUPasswordDisplayView *) newPasswordDisplayView {
	HUPasswordDisplayView *view = [[HUPasswordDisplayView alloc] initWithFrame:CGRectMake(23, 80, 274, 45)];
	view.datasource = self;
	view.delegate = self;
	
	return view;
}

-(UIButton *) newOkButtonWithSelector:(SEL)aSelector {
	UIButton *button = [HUBaseViewController buttonWithTitle:@"OK"
													   frame:CGRectMakeBounds(139, 36)
											 backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
													  target:self
													selector:aSelector];
	button.layer.cornerRadius = 18;
	return button;
}

@end
