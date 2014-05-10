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

#import "HUPasswordSetNewViewController.h"

typedef enum {
	HUPasswordConfirmStageInputNew	= 1,
	HUPasswordConfirmStageConfirm	= 2
} HUPasswordConfirmStage;

@interface HUPasswordSetNewViewController ()
@property (nonatomic) HUPasswordConfirmStage stage;
@end

@implementation HUPasswordSetNewViewController

#pragma mark - Initialization

+(HUPasswordSetNewViewController *) passwordViewController:(HUPasswordSetBlock)resultBlock {
	
	return [HUPasswordSetNewViewController passwordViewController:^NSString *{
		return [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword];
	} resultBlock:resultBlock];
}

+(HUPasswordSetNewViewController *) passwordViewController:(HUPasswordProviderBlock)passwordBlock resultBlock:(HUPasswordSetBlock)resultBlock {
	
	HUPasswordSetNewViewController *controller = [HUPasswordSetNewViewController new];
	controller.passwordBlock = passwordBlock;
	controller.newPasswordResultBlock = resultBlock;
	controller.datasource = controller;
	controller.delegate = controller;
	controller.oldPassword = passwordBlock();
	
	controller.stage = HUPasswordConfirmStageInputNew;
	
	return controller;
}

#pragma mark - View lifecycle

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

-(void) passwordViewControllerWillClose {
	[super passwordViewControllerWillClose];
	
	if (self.newPasswordResultBlock) {
		self.newPasswordResultBlock(self,nil,NO);
	}
}

-(void) setStage:(HUPasswordConfirmStage)stage {
	
	_stage = stage;
	
	[self resetInput];
	[self setNeedsDisplay];
}

#pragma mark - Override

-(NSString *) title {
	
	return NSLocalizedString(@"New Password", nil);
}

-(void) processPassword:(NSString *)password success:(BOOL)isSuccess {

	//[super processPassword:password success:isSuccess];
	if (self.stage == HUPasswordConfirmStageInputNew) {
		[self setStage:HUPasswordConfirmStageConfirm];
		self.oldPassword = password;
		return;
	}
	
	if (isSuccess) {
		if ([self.delegate respondsToSelector:@selector(passwordViewController:didChangePassword:oldPassword:)]) {
			[self.delegate passwordViewController:self didChangePassword:password oldPassword:_oldPassword];
		}
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //call super to avoid cancel callback
			[super passwordViewControllerWillClose];
        });
	}
    else {
		[self setStage:HUPasswordConfirmStageInputNew];
		[super processPassword:password success:isSuccess];
	}
	
}

-(NSString *) subtitle {
	NSString *text = NSLocalizedString(@"PLEASE ENTER NEW PASSCODE",nil);
	if (self.stage == HUPasswordConfirmStageConfirm) {
		text = NSLocalizedString(@"PLEASE ENTER NEW PASSCODE AGAIN",nil);
	}
	return NSLocalizedString(text, nil);
}

-(BOOL) shouldAnimateInputResult {
	return self.stage == HUPasswordConfirmStageInputNew ? NO : YES;
}

#pragma mark - HUPasswordInputDelegate

-(NSString *) requiredPasswordForPasswordViewController:(_HUPasswordBaseViewController *)passwordViewController {
	return self.oldPassword;
}

@end
