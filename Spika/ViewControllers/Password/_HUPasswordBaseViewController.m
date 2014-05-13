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

#import "_HUPasswordBaseViewController.h"
#import "_HUPasswordBaseViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "HUSideMenuViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "CSGraphics.h"
#import "UILabel+Extensions.h"
#import "MAKVONotificationCenter.h"
#import <objc/runtime.h>

@interface _HUPasswordBaseViewController ()
@property (nonatomic, strong) HUPasswordDisplayView *displayView;
@property (nonatomic, strong) HUDigitInputViewController *inputView;
//@property (nonatomic, strong) UITextField *hiddenTextField;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) NSString *passwordText;
@end

@implementation _HUPasswordBaseViewController

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View llifecycle

-(void) loadView {
	
	[super loadView];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hp_wall_background_pattern"]];
	
	UINavigationBar *navBar = [HUSideMenuViewController newNavigationBarWithTitle:self.title];
	[self.view addSubview:navBar];
	
	[self loadBackButtonForNavigationBar:navBar];
    
	_displayView = [self newPasswordDisplayView];
	[self.view addSubview:_displayView];
	
	_subtitleLabel = [UILabel labelWithText:self.subtitle];
	_subtitleLabel.position = CGPointShiftUp(_displayView.position, _subtitleLabel.height * 1.5f);
	_subtitleLabel.width = self.view.width - _subtitleLabel.x;
	[self.view addSubview:_subtitleLabel];
	
	_inputView = [self newDigitInputViewController];
	_inputView.view.center = self.view.center;
	_inputView.view.y = _displayView.relativeHeight + 10;
	[self.view addSubview:_inputView.view];
	
	_okButton = [self newOkButtonWithSelector:@selector(okButtonDidPress:)];
	_okButton.center = CGRectGetCenter(self.view.bounds);
	_okButton.y = _inputView.view.relativeHeight + 10;
	[self.view addSubview:_okButton];
		
	__weak id this = self;
	_displayView.animationFinishedCallback = ^{
		[this setEditing:NO];
	};
    
    [self addKeyValueObservers];
    [self resetInput];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = nil;
}

-(void) loadBackButtonForNavigationBar:(UINavigationBar *)navigationBar {
	UIButton *backButton = (UIButton *)[[[self backBarButtonItemsWithSelector:@selector(passwordViewControllerWillClose)] lastObject] customView];
	[navigationBar addSubview:backButton];
}

-(void) addKeyValueObservers {
	
	__weak id displayView = _displayView;
	[self addObservationKeyPath:@"passwordText" options:0 block:^(MAKVONotification *notification) {
        [displayView layoutSubviews];
    }];
}

#pragma mark - View lifecycle

-(BOOL) shouldAnimateInputResult {
	return YES;
}

-(void) setNeedsDisplay {
	
	_subtitleLabel.text = self.subtitle;
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

#pragma mark - Selector

-(void) passwordViewControllerWillClose {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void) okButtonDidPress:(id)sender {
	
	if (_passwordText.length == HUPasswordLength) {

		self.editing = YES;
		BOOL isPasswordCorrect = [self isPasswordCorrect:_passwordText];
		
		if (self.shouldAnimateInputResult) {
			[_displayView showResult:isPasswordCorrect];
		} else {
			if (_displayView.animationFinishedCallback)
				_displayView.animationFinishedCallback();
		}
		
		[self processPassword:_passwordText success:isPasswordCorrect];
	}
}

-(BOOL) isPasswordCorrect:(NSString*) newPassword {
    NSString *password = [self requiredPasswordForPasswordViewController:self];
    return [password isEqualToString:newPassword];
}

-(void) resetInput {
    self.passwordText = @"";
}

#pragma mark - Override

-(NSString *) title {
	NSAssert(NO, @"Øverride this method!");
	return nil;
}

-(void) processPassword:(NSString *)password success:(BOOL)isSuccess {
	
	if ([self.delegate respondsToSelector:@selector(passwordViewController:inputSuccessful:)]) {
		[self.delegate passwordViewController:self inputSuccessful:isSuccess];
	}
	
}

-(NSString *) subtitle {
	NSAssert(NO, @"Øverride this method!");
	return nil;
}

#pragma mark - HUPasswordDisplayViewDatasource

-(NSUInteger) totalNumberOfDigitsForDisplayView:(HUPasswordDisplayView *)inputView {
	return HUPasswordLength;
}

-(NSUInteger) currentNumberOfDigitsForDisplayView:(HUPasswordDisplayView *)inputView {
	return _passwordText.length;
}

#pragma mark - HUPasswordInputViewDelegate

-(void) digitInput:(HUDigitInputViewController *)digitInput didPressDigit:(NSUInteger)digit {
	
	if (_passwordText.length >= HUPasswordLength) {
		return;
	}
    self.passwordText = [_passwordText stringByAppendingFormat:@"%i", digit];
}

- (void)digitInputDidPressDeleteButton:(HUDigitInputViewController *)digitInput {

}

-(void) displayViewDidPressDeleteButton:(HUPasswordDisplayView *)displayView {
	NSInteger length = _passwordText.length;
	if (length != 0) {
        self.passwordText = [_passwordText substringToIndex:length-1];
    }
}

@end

#pragma mark -
#pragma mark - HUPasswordViewController Blocks

@implementation _HUPasswordBaseViewController (Blocks)

@dynamic newPasswordResultBlock, inputPasswordResultBlock;

#pragma mark - HUPasswordDatasource

-(NSString *) requiredPasswordForPasswordViewController:(_HUPasswordBaseViewController *)passwordViewController {
	
	HUPasswordProviderBlock passwordBlock = passwordViewController.passwordBlock;
	
	NSString *result = nil;
	if (passwordBlock) {
		result = passwordBlock();
	}
	
	return result;
}

#pragma mark - HUPasswordDelegate

-(void) passwordViewController:(_HUPasswordBaseViewController *)passwordViewController didChangePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword {
	
	HUPasswordSetBlock newPassBlock = passwordViewController.newPasswordResultBlock;
	
	if (newPassBlock)
		newPassBlock(passwordViewController,newPassword,oldPassword);
}

-(void) passwordViewController:(_HUPasswordBaseViewController *)passwordViewController inputSuccessful:(BOOL)isInputSuccessful {
	
	HUPasswordInputBlock inputBlock = passwordViewController.inputPasswordResultBlock;
	
	if (inputBlock)
		inputBlock(passwordViewController,isInputSuccessful);
	
}

#pragma mark - Getter

-(HUPasswordSetBlock) newPasswordResultBlock {
	return objc_getAssociatedObject(self, @"_newPass");
}

-(HUPasswordInputBlock) inputPasswordResultBlock {
	return objc_getAssociatedObject(self, @"_inputPass");
}

-(HUPasswordProviderBlock) passwordBlock {
	return objc_getAssociatedObject(self, @"_pass");
}

#pragma mark - Setter

-(void) setNewPasswordResultBlock:(HUPasswordSetBlock)newPasswordResultBlock {
	objc_setAssociatedObject(self, @"_newPass", newPasswordResultBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void) setInputPasswordResultBlock:(HUPasswordInputBlock)inputPasswordResultBlock {
	objc_setAssociatedObject(self, @"_inputPass", inputPasswordResultBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void) setPasswordBlock:(HUPasswordProviderBlock)passwordBlock {
	objc_setAssociatedObject(self, @"_pass", passwordBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end