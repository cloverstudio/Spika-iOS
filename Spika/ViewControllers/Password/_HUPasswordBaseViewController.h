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

#import "HUBaseViewController.h"
#import "HUPasswordDisplayView.h"
#import "HUDigitInputViewController.h"

@protocol HUPasswordDelegate, HUPasswordDatasource;

#pragma mark HUPasswordViewController

@interface _HUPasswordBaseViewController : HUBaseViewController <HUPasswordDisplayViewDatasource, HUDigitInputDelegate,HUPasswordDisplayViewDelegate>

@property (nonatomic, weak) id<HUPasswordDelegate> delegate;
@property (nonatomic, weak) id<HUPasswordDatasource> datasource;

-(void) loadBackButtonForNavigationBar:(UINavigationBar *)navigationBar;
-(void) processPassword:(NSString *)password success:(BOOL)isSuccess;

-(void) passwordViewControllerWillClose;
-(void) resetInput;

-(void) setNeedsDisplay;

-(BOOL) shouldAnimateInputResult;
-(NSString *) subtitle;

@end

#pragma mark -
#pragma mark - HUPasswordProtocols

@protocol HUPasswordDatasource <NSObject>

@required
-(NSString *) requiredPasswordForPasswordViewController:(_HUPasswordBaseViewController *)passwordViewController;

@optional
-(NSUInteger) numberOfDigitsRequiredForPasswordViewController:(_HUPasswordBaseViewController *)passwordViewController;

@end

@protocol HUPasswordDelegate <NSObject>

-(void) passwordViewController:(_HUPasswordBaseViewController *)passwordViewController didChangePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword;
-(void) passwordViewController:(_HUPasswordBaseViewController *)passwordViewController inputSuccessful:(BOOL)isInputSuccessful;

@end

#pragma mark -
#pragma mark - HUPasswordViewController blocks category

typedef NSString*(^HUPasswordProviderBlock)(void);
typedef void(^HUPasswordSetBlock)(id controller, NSString *newPassword, BOOL isSuccess);
typedef void(^HUPasswordInputBlock)(id controller, BOOL isSuccess);

@interface _HUPasswordBaseViewController (Blocks) <HUPasswordDatasource, HUPasswordDelegate>

@property (nonatomic, copy) HUPasswordProviderBlock passwordBlock;
@property (nonatomic, copy) HUPasswordSetBlock newPasswordResultBlock;
@property (nonatomic, copy) HUPasswordInputBlock inputPasswordResultBlock;

@end
