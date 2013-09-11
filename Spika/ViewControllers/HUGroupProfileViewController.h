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

@class ModelGroup, HUImageView,HUEditableLabelView, HUPickerTableView,ModelUser;

@interface HUGroupProfileViewController : HUBaseViewController <UITextViewDelegate,UITableViewDataSource,HUEditableLabelDelegate>
{
    HUImageView *_avatarView;
    UIScrollView *_contentView;
    NSMutableArray *_views;
    HUEditableLabelView *_nameLabel;
    HUEditableLabelView *_passwordLabel;
    HUEditableLabelView *_aboutLabel;
    HUEditableLabelView *_categoryLabel;
    HUEditableLabelView *_groupOwnerLabel;
    ModelGroup *_group;
    ModelUser *_owner;
    UIButton *_startConversationBtn;

	BOOL                _keyboardShowing;
	NSString			*_selectedCategoryID;
}

@property (nonatomic, strong) HUPickerTableView *pickerTableView;
@property (nonatomic, weak) UITextView *activeTextView;
@property (nonatomic, strong) ModelGroup *group;

- (id)initWithGroup:(ModelGroup *) group;
- (void) layoutViews;
- (void) populateViews;
-(void) loadAvatar;

-(void)hideKeyboardFor:(UIView *)label;
-(void)resignActiveTextViewAndHideKeyboard;
-(void)hideStartConverstationBtn;
-(void)enablePassword;

@end
