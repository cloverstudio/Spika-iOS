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

#import "VideoDetailVC.h"
#import "StyleManupulator.h"
#import "HUVideoPlayerView.h"
#import "Utils.h"
#import "StdTextView.h"
#import "StrManager.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "CSToast.h"
#import "ImageMessageCommentRow.h"
#import "HUBaseViewController+Style.h"
#import "AlertViewManager.h"
#import "HUCachedImageLoader.h"

@interface VideoDetailVC (){
    HUVideoPlayerView *_videoPlayerView;
    UILabel *_reportViolationBtn;
    ModelMessage *_message;

}
@end

@implementation VideoDetailVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Video", nil);
}

- (void)loadView {
    [super loadView];
    [self addBackButton];
    self.view.backgroundColor = [HUBaseViewController sharedViewBackgroundColor];
    [self loadControlBar];
    [self loadAvatarTitleView];
    
    _videoPlayerView = [[HUVideoPlayerView alloc] init];

    CGRect titleRect = [self frameForAvatarTitleView];
    
    self.tableView.frame = CGRectMake(
                                      self.tableView.x,
                                      self.tableView.y + titleRect.size.height,
                                      self.tableView.width,
                                      self.tableView.height - titleRect.size.height
                                      );
    
    [self hideMediaPanel];
}


- (void)loadControlBar {
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Downloading video", nil)
										   message:@""];
    
    [[DatabaseManager defaultManager] loadVideo:self.message.videoUrl success:^(NSData *data) {
        
        [[AlertViewManager defaultManager] dismiss];
        
        if (![data writeToFile:[HUVideoPlayerView videoPlayerPath] atomically:YES]) {
            [CSToast showToast:NSLocalizedString(@"Failed to save video locally", nil) withDuration:3.0];
        }else{
            [_videoPlayerView play:[NSURL fileURLWithPath:[HUVideoPlayerView videoPlayerPath]]];
            
            _reportViolationBtn.frame = CGRectMake(
                                                   _videoPlayerView.x,
                                                   _videoPlayerView.y + _videoPlayerView.height + 3,
                                                   _videoPlayerView.width,
                                                   20
                                                   );

            
        }
        
        
    } error:^(NSString *errorString) {
        
        [[AlertViewManager defaultManager] dismiss];
        [CSToast showToast:NSLocalizedString(@"Video download failed", nil) withDuration:3.0];
        
    }];

    _reportViolationBtn = [[UILabel alloc] init];
    _reportViolationBtn.text = NSLocalizedString(@"ReportViolation", nil);
    _reportViolationBtn.font = kFontArialMTOfSize(10);
    _reportViolationBtn.textAlignment = NSTextAlignmentRight;
    _reportViolationBtn.textColor = kHUColorLightGray;
    _reportViolationBtn.backgroundColor = [UIColor clearColor];
    _reportViolationBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(report)];
    [_reportViolationBtn addGestureRecognizer:tap];
    
    _reportViolationBtn.frame = CGRectMake(
                                           _videoPlayerView.x,
                                           _videoPlayerView.y + _videoPlayerView.height + 3,
                                           _videoPlayerView.width,
                                           20
                                           );
 
    
}

- (void) loadAvatarTitleView
{
    UIView * mainView = [[UIView alloc] initWithFrame:[self frameForAvatarTitleView]];
    mainView.backgroundColor = [UIColor darkGrayColor];
    
    UIImageView *usersAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 12, 52, 52)];
	usersAvatarImageView.image = [UIImage imageNamed:@"user_stub"];
    [HUCachedImageLoader thumbnailFromUserId:self.message.from_user_id completionHandler:^(UIImage *image) {
        if(image)
            usersAvatarImageView.image = image;
    }];
    
    [mainView addSubview:usersAvatarImageView];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(75, 45, 220, 25)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont systemFontOfSize:kFontSizeBig];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = self.message.body;
    if(self.message.body.length == 0){
        titleView.text = [NSString stringWithFormat:NSLocalizedString(@"NONAME TITLE VIDEO", nil),self.message.from_user_name];
    }

    
    [mainView addSubview: titleView];
    
    [self.view addSubview:mainView];
}

- (CGRect)frameForAvatarTitleView{
    CGRect frame = CGRectMake(0, 0, 320, 75);
    return frame;
}

-(MessageTypeBasicCell *) getMediaCellWithMessage:message indexPath:(NSIndexPath *) indexPath{
    
    _message = message;
    
    NSString *cellIdentifier = @"MessageTypeVideoDetailCell";
    
    MessageTypeBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        
        cell = [[MessageTypeBasicCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellIdentifier];
        
        [cell addSubview:_videoPlayerView];
        [cell addSubview:_reportViolationBtn];

    }
    
    return cell;
    
}

-(void) reload {
    
    [super reload];
    
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ModelMessage *message = [self.items objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        return _videoPlayerView.frame.size.height + 20 + 20;
    }
    else
    {
        return [message.tableViewCellClass cellHeightForMessage:message];
    }
}

-(void) report{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReportViolation object:_message];
}


@end
