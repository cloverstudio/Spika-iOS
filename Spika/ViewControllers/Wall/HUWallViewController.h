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

#import "HUBaseTableViewController.h"
#import "Models.h"
#import "HUMediaPanelView.h"
#import "CSLazyLoadController.h"
#import "MessageTypeBasicCell.h"
#import "MessageTypeImageCell.h"
#import "MessageTypeLocationCell.h"
#import "MessageTypeVideoCell.h"
#import "MessageTypeVoiceCell.h"
#import "HUVoiceRecorderViewController.h"
#import "ODRefreshControl.h"

#define ModeUser 1
#define ModeGroup 2

@class LoadingViewCell;

@interface HUWallViewController : HUBaseTableViewController <
        UITextViewDelegate,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate,
        HUMediaPanelViewDelegate,
        MessageCellDelegate,
        MessageImageCellDelegate,
        MessageLocationCellDelegate,
        MessageVideoCellDelegate,
        MessageVoiceCellDelegate,
        HUVoiceRecorderViewControllerDelegate> {
        
    int _targetMode;
    NSTimer *_reloadTimer;
    int _currentKeyboardHeight;
    
    LoadingViewCell *_loadingViewCell;
    
    int _currentPage;
    BOOL _loadingNewPage;
    BOOL _flgPullEnough;
    BOOL _flgLoadAll;
    BOOL _isLastPage;
}

@property (nonatomic, readonly) CGRect contentViewFrame;

#pragma mark - Initialization
- (id)initWithUser:(ModelUser *)user;
- (id)initWithGroup:(ModelGroup *)group;
- (void) hideMediaPanel;

#pragma mark - Override
- (void) reload;
- (void) reloadAll;
- (void) onSend;
- (void) sendMessage:(NSString *)messageText;
- (void) dropViewDidBeginRefreshing:(id)sender;

- (void) scrollToFirstRowInLastPage;

@end
