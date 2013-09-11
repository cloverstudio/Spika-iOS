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

#import "HUVoiceRecorderViewController+Style.h"
#import "HUVoicePlayerControlBar.h"

@implementation HUVoiceRecorderViewController (Style)

-(CGRect)frameForScrollView
{
	CGRect frame = CGRectMake(0, 0, self.view.width,
							  self.view.height -
							  [UIApplication sharedApplication].statusBarFrame.size.height
							  - self.navigationController.navigationBar.height);
	return frame;
}

-(CGSize)initialSizeOfScrollView
{
	return CGSizeMake(self.scrollView.width, self.controlBar.relativeHeight + self.controlBar.x);
}

-(CGRect)frameForAddTitleView
{
    CGRect frame = CGRectMake(0, 0, 320, 75);
    return frame;
}

-(CGRect)frameForStatusLabel
{
    CGRect frame = CGRectMake(30, self.titleView.relativeHeight + 10, 200, 25);
    return frame;
}

-(CGRect)frameForMicButtonWithSize:(CGSize)size
{
	return CGRectMake((self.view.width - size.width) / 2,
	self.statusLabel.relativeHeight + 5,
	size.width,
	size.height);
}

-(CGRect)frameForVoicePlayerBar
{
    return CGRectMake(5, self.micButton.relativeHeight + 15, 310, 40);;
}

-(CGRect)frameForTimerLabel
{
    return CGRectMake(5, self.micButton.relativeHeight + 15, 320, 60);;
}

@end
