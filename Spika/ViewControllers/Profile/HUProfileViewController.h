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
#import "HUEditableLabelDelegate.h"

#define kLabelMarginLeft     60
#define kMargin              5

@class ModelUser,HUImageView;

@interface HUProfileViewController : HUBaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,HUEditableLabelDelegate,UIActionSheetDelegate>{
    
    IBOutlet UIButton    *_startConversationBtn;
    IBOutlet UILabel    *_nameLabel;
    IBOutlet UILabel    *_nameValueLabel;
    IBOutlet UILabel    *_lastLoginLabel;
    IBOutlet UILabel    *_lastLoginValueLabel;
    IBOutlet UILabel    *_aboutLabel;
    IBOutlet UILabel    *_aboutValueLabel;
    IBOutlet UILabel    *_birthdayLabel;
    IBOutlet UILabel    *_birthdayValueLabel;
    IBOutlet UILabel    *_genderLabel;
    IBOutlet UILabel    *_genderValueLabel;
    IBOutlet UILabel    *_statusLabel;
    IBOutlet UILabel    *_statusValueLabel;
    IBOutlet UIView     *_bottomElement;
    IBOutlet UIImageView    *_onlineStatusIconView;
    IBOutlet NSLayoutConstraint *_avatarImageViewHeightConstraint;
    IBOutlet NSLayoutConstraint *_aboutViewHeightConstraint;
    IBOutlet NSLayoutConstraint *_contentHeightConstraint;
    
}

@property (nonatomic, strong) ModelUser *user;
@property (nonatomic, strong) IBOutlet UIScrollView *contentView;
@property (nonatomic, strong) IBOutlet HUImageView *userAvatarImageView;

- (id)initWithUser:(ModelUser *) user;
- (id)initWithNibName:(NSString *)nibNameOrNil withUser:(ModelUser *)user;
- (IBAction)startConversation:(id)sender;

@end
