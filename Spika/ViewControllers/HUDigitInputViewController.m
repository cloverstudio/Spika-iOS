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

#import "HUDigitInputViewController.h"
#import "CSGraphics.h"
#import "UIImage+Aditions.h"

@interface HUDigitInputViewController ()
@property (nonatomic) CGRect viewFrame;
@end

@implementation HUDigitInputViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        // Custom initialization
		self.viewFrame = frame;
    }
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
	
	[super loadView];
	
	self.view.frame = self.viewFrame;
	
	CGRect buttonFrame = CGRectMakeBoundsWithSize(self.buttonSize);
	
	for (int i = 1; i < 12; i++) {
		
		UIButton *button = [self buttonWithDigit:i];
		button.frame = CGRectContract(buttonFrame, 2);
		[self.view addSubview:button];
		
		buttonFrame.origin.x += CGRectGetWidth(buttonFrame);
		if (buttonFrame.origin.x >= self.view.width) {
			buttonFrame.origin.x = 0;
			buttonFrame.origin.y += CGRectGetHeight(buttonFrame);
		}
		
	}
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Construction

-(CGSize) buttonSize {
	return CGSizeMake(self.view.width / 3, self.view.height / 4);
}

-(UIButton *) buttonWithDigit:(NSUInteger)number {
	
	if (number == 10)
		return nil;
	
	if (number == 11) {
		number = 0;
	}
	
	UIButton *button = nil;
	
	if (number < 10) {
		button = [self buttonWithString:[NSString stringWithFormat:@"%i",number]];
		button.tag = number;
		[button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
	}
	/*
	if (number == 12) {
		button = [self buttonWithString:@"DEL"];
		[button addTarget:self action:@selector(deleteButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
	}
	 */
	
	return button;
}

-(UIButton *) buttonWithString:(NSString *)string {
	
	CGSize buttonSize = self.buttonSize;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.size = buttonSize;
	
	[button setTitle:string forState:UIControlStateNormal];
	[button setTitle:string forState:UIControlStateHighlighted];
	
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	
	[button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] andSize:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
	
	return button;
}

#pragma mark - Selector

-(void) buttonDidTap:(UIButton *)sender {
	
	if ([_delegate respondsToSelector:@selector(digitInput:didPressDigit:)]) {
		[_delegate digitInput:self didPressDigit:sender.tag];
	}
	
}

-(void) deleteButtonDidTap:(UIButton *)sender {
	
	if ([_delegate respondsToSelector:@selector(digitInputDidPressDeleteButton:)]) {
		[_delegate digitInputDidPressDeleteButton:self];
	}
}

@end
