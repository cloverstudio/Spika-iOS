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

#import "HUImageUploadViewController.h"
#import "HUImageUploadViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"
#import "UIImage+Resize.h"
#import "UserManager.h"
#import "AppDelegate.h"
#import "CSGraphics.h"
#import "CSToast.h"

#define imageSideSize 640

@interface HUImageUploadViewController ()

@end

@implementation HUImageUploadViewController

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Preview", nil);
        
        self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(backButtonDidPress:)];
    }
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hp_wall_background_pattern"]];
    
    CGRect frame = self.frameForPreviewImage;
    
    UIView *whiteBackgroundView = [[UIView alloc] initWithFrame:CGRectExpand(frame, 5)];
    whiteBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteBackgroundView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = self.image;
    [self.view addSubview:imageView];
    
    UIButton *cancelButton = [self newCancelButtonWithSelector:@selector(backButtonDidPress:)];
    cancelButton.position = CGPointMake(0, self.view.height - cancelButton.height * 2);
    [self.view addSubview:cancelButton];
    
    UIButton *uploadButton = [self newUploadButtonWithSelector:@selector(uploadButtonDidPress:)];
    uploadButton.position = CGPointMake(self.view.width - uploadButton.width, self.view.height - uploadButton.height * 2);
    [self.view addSubview:uploadButton];
    
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

-(void) backButtonDidPress:(id)sender {
    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
}

-(void) uploadButtonDidPress:(id)sender {
    
    if (self.onUploadBlock) {
        [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Uploading image", nil)
											   message:@""];
        self.onUploadBlock(self);
    } else {
        [CSToast showToast:NSLocalizedString(@"ERROR: No onUploadBlock() has been provided", nil)
			  withDuration:2.0f];
    }
    
}

#pragma mark - Convenience method

-(UIImage *)fitImageSize:(UIImage *)avatarImage{
    
    avatarImage = [avatarImage resizeIfNeededToMaxDimension:imageSideSize];
    avatarImage = [UIImage imageWithImage:avatarImage croppedToSize:CGSizeMake(imageSideSize, imageSideSize)];
    
    return avatarImage;
    
}

@end

@implementation HUImageUploadViewController (Factory)

+(HUImageUploadViewController *) wallUploadViewControllerWithImage:(UIImage *)image {
    
    HUImageUploadViewController *uploadViewController = [HUImageUploadViewController new];
    uploadViewController.image = image;
    uploadViewController.onUploadBlock = ^(HUImageUploadViewController *this){
        
        this.image = [this fitImageSize:image];
        
        [[DatabaseManager defaultManager] sendImageMessage:this.targetUser
                                                   toGroup:this.targetGroup
                                                      from:[[UserManager defaultManager] getLoginedUser]
                                                     image:this.image
                                                   success:^(BOOL isSuccess,NSString *errStr){
                                                       
                                                       
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           [[AlertViewManager defaultManager] dismiss];
                                                           
                                                           if(isSuccess == YES){
                                                               
                                                               [CSToast showToast:NSLocalizedString(@"Message sent", nil)
																	 withDuration:3.0];
                                                               [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
                                                               
                                                           }else {
                                                               
                                                               [CSToast showToast:errStr withDuration:3.0];
                                                               
                                                           }
                                                           
                                                       });
                                                       
                                                   } error:^(NSString *errStr){
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [[AlertViewManager defaultManager] dismiss];
                                                       });
                                                       
                                                       
                                                   }]; // [[DatabaseManager defaultManager] sendImageMessage:_targetUser
    };
    
    return uploadViewController;
}

+(HUImageUploadViewController *) userAvatarUploadViewControllerWithImage:(UIImage *)image {
    
    HUImageUploadViewController *uploadViewController = [HUImageUploadViewController new];
    uploadViewController.image = image;
    uploadViewController.onUploadBlock = ^(HUImageUploadViewController *this){
        
        this.image = [this fitImageSize:image];
        
        [[DatabaseManager defaultManager] saveUserAvatarImage:this.targetUser
                                                    image:this.image
                                                  success:^(BOOL isSuccess, NSString *errStr){
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          
                                                          [[AlertViewManager defaultManager] dismiss];
                                                          
                                                          if ([(NSObject *)this.delegate respondsToSelector:@selector(imageUploadViewController:didUpdateObject:)]) {
                                                              [this.delegate imageUploadViewController:this didUpdateObject:this.targetUser];
                                                          }
                                                          
                                                          if(isSuccess == YES) {
                                                              
                                                              [CSToast showToast:NSLocalizedString(@"Avatar uploaded", nil)
																	withDuration:3.0];
                                                              [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
                                                          }
                                                          else {
                                                              
                                                              [CSToast showToast:errStr withDuration:3.0];
                                                          }
                                                      });
                                                  } error:^(NSString *errStr){
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [[AlertViewManager defaultManager] dismiss];
                                                          [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Error", nil)
																							   message:errStr];
                                                      });
        
                                                  }];
    };
    
    return uploadViewController;
}

+(HUImageUploadViewController *) groupAvatarUploadViewControllerWithImage:(UIImage *)image {
    
    HUImageUploadViewController *uploadViewController = [HUImageUploadViewController new];
    uploadViewController.image = image;
    uploadViewController.onUploadBlock = ^(HUImageUploadViewController *this){
        
        this.image = [this fitImageSize:image];
        
        [[DatabaseManager defaultManager] saveGroupAvatarImage:this.targetGroup image:image success:^(BOOL isSuccess, NSString *errStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[AlertViewManager defaultManager] dismiss];
                
                if ([(NSObject *)this.delegate respondsToSelector:@selector(imageUploadViewController:didUpdateObject:)]) {
                    [this.delegate imageUploadViewController:this didUpdateObject:this.targetGroup];
                }
                
                if(isSuccess == YES) {
                    
                    [CSToast showToast:NSLocalizedString(@"Avatar uploaded", nil)
						  withDuration:3.0];
                    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
                }
                else {
                    
                    [CSToast showToast:errStr withDuration:3.0];
                }
            });
        } error:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AlertViewManager defaultManager] dismiss];
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Error", nil)
													 message:errorString];
            });
        }];
        
    };
    
    return uploadViewController;
}

@end
