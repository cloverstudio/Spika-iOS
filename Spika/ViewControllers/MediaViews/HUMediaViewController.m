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

#import "HUMediaViewController.h"


#import "HUPhotoDetailViewController.h"
#import "HUBaseViewController+Style.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "CSToast.h"
#import "MessageTypeImageDetailCell.h"
#import "AlertViewManager.h"
#import "HUDialog.h"

@interface HUMediaViewController (){
    NSMutableArray *_comments;
    id _observer;
}

@end

@implementation HUMediaViewController

#pragma mark - Initialization

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_observer name:NotificationReportViolation object:nil];
}


-(id) initWithMessage:(ModelMessage *)message {
    
    if (self = [super init]) {
        
        [self setMessage:message];
        
        _currentPage = 0;
    }
    
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];
    
    self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(backButtonDidPress:)];
    
    __weak HUMediaViewController *this = self;
    
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:NotificationReportViolation
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
          HUDialog *dialog = [[HUDialog alloc] initWithText:NSLocalizedString(@"ReportViolationConfirm", nil)
                                                   delegate:this
                                                cancelTitle:NSLocalizedString(@"NO", nil)
                                                 otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"YES", nil),nil]];
          [dialog show];
                                                      
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItems = nil;
}

- (void) viewDidDisappear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override

-(void) reload {
    
    [[DatabaseManager defaultManager]
     reloadMessage:self.message
     success:^(ModelMessage *model){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if(model == nil)
                 return;
             
             self.message = model;
             
             [self reloadComments];
             
         });
         
     } error:^(NSString *errStr){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [CSToast showToast:errStr withDuration:3.0];
             
         });
         
     }];
    
}

-(void) sendMessage:(NSString *)messageText {
    
    ModelMessage *newMessage = [_message copy];
    
    [[DatabaseManager defaultManager]
     postImageComment:newMessage
     byUser:[[UserManager defaultManager] getLoginedUser]
     comment:messageText
     success:^(BOOL isSuccess,NSDictionary *result){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if(isSuccess == NO){
                 [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Failed to post comment", nil)];
                 return;
             }
             
             [self reload];
             
         });
         
     } error:^(NSString *errStr){
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [CSToast showToast:errStr withDuration:3.0];
             
         });
         
         
     }];
    
}

#pragma mark - Selectors

-(void) backButtonDidPress:(UIButton *)button {
    
    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Private methods
-(void) reloadComments{
    
    void(^successBlock)(void) = ^{
        
        NSMutableArray *items = [NSMutableArray new];
        [items addObject:_message];
        
        for (ModelComment *comment in _comments) {
            ModelMessage *commentMessage = [ModelMessage messageWithCommentDictionary:comment];
            [items addObject:commentMessage];
        }
        
        [self setTableItems:items];
        
        
        NSInteger section = [self numberOfSectionsInTableView:self.tableView] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:items.count - 1 inSection:section];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition: UITableViewScrollPositionTop
                                      animated: YES];
        
        
    };
    
    [[DatabaseManager defaultManager] getCommentsByMessage:_message
                                                      page:0
                                                   success:^(NSArray *aryComments){
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           _comments = [[NSMutableArray alloc] initWithArray:[self filterComments:aryComments]];
                                                           successBlock();
                                                           
                                                           [self setViewType:HUViewTypeLoading];
                                                           
                                                       });
                                                       
                                                   } error:^(NSString *errStr){
                                                       
                                                       [CSToast showToast:errStr withDuration:3.0];
                                                       
                                                   }];
    
}

-(void) getPage:(int) page{
    
//    self.tableView.scrollEnabled = NO;
    
    void(^successBlock)(void) = ^{
        
        NSMutableArray *items = [NSMutableArray new];
        [items addObject:_message];
        
        for (ModelComment *comment in _comments) {
            ModelMessage *commentMessage = [ModelMessage messageWithCommentDictionary:comment];
            [items addObject:commentMessage];
        }
        
        [self setTableItems:items];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        });
        
        self.tableView.scrollEnabled = YES;
    };
    
    [[DatabaseManager defaultManager] getCommentsByMessage:_message
                                                      page:page
                                                   success:^(NSArray *aryComments){
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           if(aryComments.count < PagingMessageFetchNum)
                                                               _isLastPage = YES;

                                                           _comments = [[NSMutableArray alloc] initWithArray:[self filterComments:aryComments]];
                                                           successBlock();
                                                           
                                                           _loadingNewPage = NO;

                                                           [[AlertViewManager defaultManager] dismiss];
                                                           [self setViewType:HUViewTypeLoading];
                                                           
                                                           [self scrollToFirstRowInLastPage];
                                                           
                                                       });
                                                       
                                                   } error:^(NSString *errStr){
                                                       
                                                       [[AlertViewManager defaultManager] dismiss];
                                                       [CSToast showToast:errStr withDuration:3.0];
                                                       
                                                   }];
    
    
}
-(void) setMessage:(ModelMessage *)message {
    
    if (_message) {
        return;
    }
    
    _message = message;
    
}

#pragma mark -

-(MessageTypeBasicCell *) getMediaCellWithMessage:_message indexPath:(NSIndexPath *) indexPath
{
	NSAssert(NO, @"Øverride this method!");
	return nil;
}

#pragma mark - UITableViewDatasource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //since we inherit HUWallViewController, which has 2 sections (first reserved for
    //LoadingViewCell) we have to send the last section as parameter in order for
    //superclass to reuse proper cells. Sending section 0 will result in dequeueing
    //the LoadingViewCell
    
    NSInteger section = [super numberOfSectionsInTableView:tableView];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:section];
    
    if (indexPath.row == 0 && section == 1) {
        
        MessageTypeBasicCell *cell = [self getMediaCellWithMessage:_message indexPath:indexPath];

        return cell;

    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
}

-(MessageTypeBasicCell *) getMediaCellWithMessage:_message{
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [_message.tableViewCellClass cellHeightForMessage:_message];
    
}


-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //override this
    return [UIView new];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - MessageCellDelegate

#pragma mark - MessageImageCellDelegate

-(void) messageImageCell:(MessageTypeImageCell *)messageImageCell didTapPhotoView:(ModelMessage *)message {
    
    //    HUPhotoDetailViewController *viewController = [[HUPhotoDetailViewController alloc] initWithMessage:message];
    //    [[AppDelegate getInstance].navigationController pushViewController:viewController animated:YES];
}

#pragma mark - MessageVideoCellDelegate

-(void) messageVideoCell:(MessageTypeVideoCell *)messageVideoCell didTapVideoMessage:(ModelMessage *)message {
    
    //    VideoDetailVC *vc = [[VideoDetailVC alloc] initWithMessage:message];
    //    [[AppDelegate getInstance].navigationController pushViewController:vc animated:YES];
}

#pragma mark - MessageVoiceCellDelegate

-(void) messageVoiceCell:(MessageTypeVoiceCell *)messageVoiceCell didTapVoiceMessage:(ModelMessage *)message {
    
}
#pragma mark - MessageLocationCellDelegate

-(void) messageLocationCell:(MessageTypeLocationCell *)messageLocationCell didTapLocationMessage:(ModelMessage *)message {
    
    //    LocationViewController *vc = [[LocationViewController alloc] initWithMessage:message];
    //    [[AppDelegate getInstance].navigationController pushViewController:vc animated:YES];
}

- (void) dropViewDidBeginRefreshing:(id)sender{
    
    [super dropViewDidBeginRefreshing:sender];
    
//    _currentPage++;
//    [self getPage:_currentPage];
    
}


- (NSArray *) filterComments:(NSArray *) newComments{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    for(ModelComment *comment in _comments){
        
        BOOL isExists = NO;
        
        for(ModelComment *comment2 in resultArray) {
            
            if([comment2._id isEqualToString:comment._id]){
                isExists = YES;
                continue;
            }
            
        }
        
        if(!isExists)
            [resultArray addObject:comment];
    }
    
    for(ModelComment *comment in newComments){

        BOOL isExists = NO;
        
        for(ModelComment *comment2 in resultArray) {
            
            if([comment2._id isEqualToString:comment._id]){
                isExists = YES;
                continue;
            }
            
        }
        
        if(!isExists)
            [resultArray addObject:comment];

        
    }
    
    
    NSArray *sortedAry = [resultArray sortedArrayUsingComparator:^NSComparisonResult(ModelMessage *a, ModelMessage *b) {
        return a.created> b.created;
    }];

    return sortedAry;
    
}

-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index{
    
    if(index == 0) {
        
        [[AlertViewManager defaultManager] showWaiting:@"" message:@""];

        [[DatabaseManager defaultManager] report:_message success:^(id result) {
            
            [[AlertViewManager defaultManager] dismiss];
            [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Violation Reported", nil)];
        }];
    }
}

- (void)dialogDidPressCancel:(HUDialog *)dialog {

}

@end
