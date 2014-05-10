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

@class ModelGroup, HUImageView,HUEditableLabelView, HUPickerTableView,ModelUser, HUTextView;

@interface HUGroupProfileViewController : HUBaseViewController <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
    IBOutlet UIScrollView *_contentView;
    IBOutlet NSLayoutConstraint *_contentHeightConstraint;
    
    IBOutlet HUImageView *_avatarView;
    IBOutlet NSLayoutConstraint *_avatarImageViewHeightConstraint;
    
    IBOutlet UILabel        *_categoryLabel;
    IBOutlet UITextField    *_categoryValueLabel;
    IBOutlet UIImageView    *_categoryIconView;
    
    IBOutlet UILabel        *_nameLabel;
    IBOutlet UITextField    *_nameValueLabel;
    IBOutlet UILabel        *_aboutLabel;
    IBOutlet HUTextView    *_aboutValueLabel;
    IBOutlet UILabel        *_passwordLabel;
    IBOutlet UITextField    *_passwordValueLabel;
    IBOutlet UILabel        *_groupOwnerLabel;
    IBOutlet UITextField    *_groupOwnerValueLabel;
    IBOutlet UILabel        *_memberLabel;
    
    IBOutlet NSLayoutConstraint *_aboutViewHeightConstraint;
    IBOutlet UIButton *_startConversationBtn;
    
    NSMutableArray *_views;

    ModelGroup *_group;
    ModelUser *_owner;
    
	BOOL                _keyboardShowing;
	NSString			*_selectedCategoryID;
    
    BOOL                _isEditing;
    
}

@property (nonatomic, strong) HUPickerTableView *pickerTableView;
@property (nonatomic, weak) UITextView *activeTextView;
@property (nonatomic, strong) ModelGroup *group;

- (id)initWithNibName:(NSString *)nibNameOrNil withGroup:(ModelGroup *) group;
- (id)initWithGroup:(ModelGroup *) group;
- (void) layoutViews;
- (void) populateViews;
-(void) loadAvatar;

-(void)hideKeyboardFor:(UIView *)label;

-(IBAction) startConversation;
-(IBAction) openOwner;
-(IBAction) viewMembers:(id)sender;

-(IBAction)onCategoryOpen;

@end
