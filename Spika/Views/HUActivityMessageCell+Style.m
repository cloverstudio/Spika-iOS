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

#import "HUActivityMessageCell+Style.h"
#import "UILabel+Extensions.h"

@implementation HUActivityMessageCell (Style)

-(UIView *) newBackgroundView {
	
	UIView *view = [UIView new];
	view.backgroundColor = [UIColor whiteColor];
	
	return view;
}

-(UILabel *) newTextLabel {
	
	UILabel *textLabel = [UILabel new];
	textLabel.numberOfLines = 2;
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.font = [UIFont systemFontOfSize:kFontSizeMiddium];
	textLabel.backgroundColor = [UIColor clearColor];
    
	return textLabel;
}

-(UILabel *) newDateLabel {
	
	UILabel *textLabel = [UILabel new];
	textLabel.numberOfLines = 1;
	textLabel.font = [UIFont systemFontOfSize:kFontSizeSmall];
	textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor lightGrayColor];
    textLabel.textAlignment = NSTextAlignmentRight;
    
	return textLabel;
}

@end
