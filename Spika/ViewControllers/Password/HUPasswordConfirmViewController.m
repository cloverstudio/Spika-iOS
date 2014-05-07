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

#import "HUPasswordConfirmViewController.h"

@interface HUPasswordConfirmViewController ()

@end

@implementation HUPasswordConfirmViewController

#pragma mark - Initialization

+(HUPasswordConfirmViewController *) passwordViewController:(HUPasswordInputBlock)resultBlock {
	return [HUPasswordConfirmViewController passwordViewController:^NSString *{
		return [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword];
	} resultBlock:resultBlock];
}

+(HUPasswordConfirmViewController *) passwordViewController:(HUPasswordProviderBlock)passwordBlock resultBlock:(HUPasswordInputBlock)resultBlock {
	
	return [HUPasswordConfirmViewController passwordViewController:passwordBlock
													   resultBlock:resultBlock
														  isForced:NO];
}

+(HUPasswordConfirmViewController *) forcePasswordViewController:(HUPasswordInputBlock)resultBlock {
	return [HUPasswordConfirmViewController forcePasswordViewController:^NSString *{
		return [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword];
	} resultBlock:resultBlock];
}

+(HUPasswordConfirmViewController *) forcePasswordViewController:(HUPasswordProviderBlock)passwordBlock resultBlock:(HUPasswordInputBlock)resultBlock {
	
	return [HUPasswordConfirmViewController passwordViewController:passwordBlock
													   resultBlock:resultBlock
														  isForced:YES];
}

+(HUPasswordConfirmViewController *) passwordViewController:(HUPasswordProviderBlock)passwordBlock resultBlock:(HUPasswordInputBlock)resultBlock isForced:(BOOL)isForced {
	
	HUPasswordConfirmViewController *controller = [HUPasswordConfirmViewController new];
	controller.passwordBlock = passwordBlock;
	controller.inputPasswordResultBlock = resultBlock;
	controller.datasource = controller;
	controller.delegate = controller;
	controller.isForcedPassword = isForced;
	
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

-(void) loadBackButtonForNavigationBar:(UINavigationBar *)navigationBar {
	if (!self.isForcedPassword) {
		[super loadBackButtonForNavigationBar:navigationBar];
	}
}

-(void) passwordViewControllerWillClose {
	[super passwordViewControllerWillClose];
	
	if (self.inputPasswordResultBlock) {
		self.inputPasswordResultBlock(self,NO);
	}
}

#pragma mark - Override

-(NSString *) title {
	return NSLocalizedString(@"Input password", nil);
}

-(void) processPassword:(NSString *)password success:(BOOL)isSuccess {
	
	[super processPassword:password success:isSuccess];
	
	if (isSuccess) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //call super to avoid cancel block callback
            [super passwordViewControllerWillClose];
        });
	}
    else {
	
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetInput];
        });
	}
}

-(NSString *) subtitle {
	return NSLocalizedString(@"PLEASE ENTER CURRENT PASSCODE", nil);
}

@end
