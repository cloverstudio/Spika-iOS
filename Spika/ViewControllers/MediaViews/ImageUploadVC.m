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

#import "ImageUploadVC.h"
#import "StyleManupulator.h"
#import "Utils.h"
#import "Constants.h"
#import "StrManager.h"
#import "AppDelegate.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "CSToast.h"
#import "UIImage+Resize.h"

#define btnWidth 150
#define btnHeight 50
#define btnMargin 5
#define imageViewWidth 300.0f

@implementation ImageUploadVC

@synthesize targetGroup = _targetGroup;
@synthesize targetUser = _targetUser;

-(id) initWithImage:(UIImage *)image uploadType:(ImageUploadType) uploadType
{
    self = [super init];
    if (self) {
        
        _image = image;
        _uploadType = uploadType;
        
        self.title = NSLocalizedString(@"Preview", nil);
        
        [self buildViews];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self hideMenuBtn];
    
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

//------------------------------------------------------------------------------------------------------
#pragma mark private methods
//------------------------------------------------------------------------------------------------------

- (void)buildViews{
    
    [StyleManupulator attachSideMenuBG:self.view];
    
    int yPos = self.view.frame.size.height - btnMargin -btnHeight - HeaderHeight;
    
    CSButton *cancelBtn = [CSButton buttonWithFrame:CGRectMake(btnMargin,yPos,btnWidth,btnHeight) callback:^{
        [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
    }];
    
    [cancelBtn setTitle:[StrManager _:@"Cancel"] forState:UIControlStateNormal];
    [StyleManupulator attachDefaultButton:cancelBtn];

    
    int xPos = self.view.frame.size.width - btnMargin - btnWidth;
    CSButton *uploadBtn = [CSButton buttonWithFrame:CGRectMake(xPos,yPos,btnWidth,btnHeight) callback:^{
        
        [[AlertViewManager defaultManager] showWaiting:[StrManager _:NSLocalizedString(@"Uploading image", nil)]
											   message:@""];
        
        if(_uploadType == UploadTypeUploadToWall){
            [self uploadToWall];
        }
        
        if(_uploadType == UploadTypeUploadAsUserAvatar){
            [self uploadAsUserAvatar];
        }
        
    }];
    
    [uploadBtn setTitle:[StrManager _:@"Upload"] forState:UIControlStateNormal];
    [StyleManupulator attachDefaultButton:uploadBtn];

    [self.view addSubview:cancelBtn];
    [self.view addSubview:uploadBtn];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    float scale = imageViewWidth / _image.size.width;
    float height = _image.size.height * scale;
    
    xPos = (self.view.frame.size.width - imageViewWidth) / 2;
    imageView.frame = CGRectMake(xPos,10,imageViewWidth,height);
    imageView.image = _image;
    
    [StyleManupulator attachImagePreviewStyle:imageView];
    [self.view addSubview:imageView];
}

-(void) uploadAsUserAvatar{
    
    _image = [self fitImageSize:_image];
    
    [[DatabaseManager defaultManager] saveUserAvatarImage:_targetUser
                                                image:_image
                                              success:^(BOOL isSuccess, NSString *errStr){
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      [[AlertViewManager defaultManager] dismiss];
                                                      
//                                                      if ([(NSObject *)_delegate respondsToSelector:@selector(imageUploadViewController:didUpdateObject:)]) {
//                                                          [_delegate imageUploadViewController:self
//                                                                               didUpdateObject:_targetUser];
//                                                      }
                                                      
                                                      if(isSuccess == YES) {
                                                          
                                                          [CSToast showToast:NSLocalizedString(@"Avatar uploaded", nil) withDuration:3.0];
                                                          [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
                                                      }
                                                      else {
                                                          
                                                          [CSToast showToast:errStr withDuration:3.0];
                                                      }
                                                  });
                                              } error:^(NSString *errStr){

                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [[AlertViewManager defaultManager] dismiss];
                                                      [[AlertViewManager defaultManager] showAlert:[StrManager _:NSLocalizedString(@"Error", nil)]
																						   message:errStr];
                                                  });
    }];
}

-(void) uploadToWall{
    
    
    _image = [self fitImageSize:_image];

    
    [[DatabaseManager defaultManager] sendImageMessage:_targetUser
        toGroup:_targetGroup
        from:[[UserManager defaultManager] getLoginedUser]
        image:_image
        success:^(BOOL isSuccess,NSString *errStr){



            dispatch_async(dispatch_get_main_queue(), ^{

                [[AlertViewManager defaultManager] dismiss];

                if(isSuccess == YES){

                    [CSToast showToast:[StrManager _:NSLocalizedString(@"Message sent", nil)] withDuration:3.0];
                    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];

                }else {

                    [CSToast showToast:errStr withDuration:3.0];

                }

            });

        } error:^(NSString *errStr){

            dispatch_async(dispatch_get_main_queue(), ^{
                [[AlertViewManager defaultManager] dismiss];
                [[AlertViewManager defaultManager] showAlert:[StrManager _:NSLocalizedString(@"Error", nil)]
													 message:errStr];
            });


        }]; // [[DatabaseManager defaultManager] sendImageMessage:_targetUser

}



#pragma mark  - set uploaded image size

-(UIImage *)fitImageSize:(UIImage *)avatarImage{
    
    
    if (avatarImage.size.height != AvatarSize || avatarImage.size.height != AvatarSize) {
        
        if (avatarImage.size.height == avatarImage.size.width) {
            
            //RESIZE
            avatarImage = [UIImage imageWithImage:avatarImage scaledToSize:CGSizeMake(AvatarSize, AvatarSize)];
            
        }else{
            
            //CROP & RESIZE
            avatarImage = [UIImage imageWithImage:avatarImage resizedToSize:CGSizeMake(AvatarSize, AvatarSize) croppedToSize:CGSizeMake(AvatarSize, AvatarSize)];
            
        }
        
    }
    
    return avatarImage;
    
}


@end
