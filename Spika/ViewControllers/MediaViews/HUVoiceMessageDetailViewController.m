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

#import "HUVoiceMessageDetailViewController.h"
#import "HUVoicePlayerControlBar.h"
#import "HUBaseViewController+Style.h"
#import "HUVoicePlayerViewController+Style.h"
#import "CSToast.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"
#import "HUCachedImageLoader.h"

@interface HUVoiceMessageDetailViewController () {
    HUVoicePlayerControlBar *_controlBar;
    UILabel *_reportViolationBtn;
    ModelMessage *_message;
}

@end

@implementation HUVoiceMessageDetailViewController


- (void)viewDidLoad
{
    
    self.title = NSLocalizedString(@"Voice", nil);
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Downloading Video", nil)
										   message:@""];
    
    [[DatabaseManager defaultManager] loadVoice:self.message.voiceUrl success:^(NSData *data) {
        
        [[AlertViewManager defaultManager] dismiss];
        
        if (![data writeToFile:_controlBar.voicePlayerPath atomically:YES]) {
            [CSToast showToast:NSLocalizedString(@"Failed to save video locally", nil) withDuration:3.0];
        }
        
    } error:^(NSString *errorString) {
        
        [[AlertViewManager defaultManager] dismiss];
        
        [CSToast showToast:NSLocalizedString(@"Video download failed", nil) withDuration:3.0];
        
    }];
    
}

- (void)loadView {
    
    [super loadView];
    
    [self addBackButton];
    self.view.backgroundColor = [HUBaseViewController sharedViewBackgroundColor];
    [self loadControlBar];
    [self loadAvatarTitleView];
    
    CGRect titleRect = [self frameForAvatarTitleView];
    
    self.tableView.y = titleRect.origin.y + titleRect.size.height + 10;
    self.tableView.height = self.tableView.height - self.tableView.y;

    [self hideMediaPanel];

}

- (void)loadControlBar {
    _controlBar = [[HUVoicePlayerControlBar alloc] initWithFrame:[self frameForVoicePlayerBar]];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingFormat:@"/%@", MessageTypeVoiceRecievedFileName];
    
    _controlBar.voicePlayerPath = soundFilePath;
    
    _reportViolationBtn = [[UILabel alloc] init];
    _reportViolationBtn.text = NSLocalizedString(@"ReportViolation", nil);
    _reportViolationBtn.font = kFontArialMTOfSize(10);
    _reportViolationBtn.textAlignment = NSTextAlignmentRight;
    _reportViolationBtn.textColor = kHUColorLightGray;
    _reportViolationBtn.userInteractionEnabled = YES;
    _reportViolationBtn.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(report)];
    [_reportViolationBtn addGestureRecognizer:tap];

    _reportViolationBtn.frame = CGRectMake(
                                          _controlBar.x,
                                          _controlBar.y + _controlBar.height + 3,
                                          _controlBar.width,
                                          20
                                          );
    //[self.view addSubview:_controlBar];
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
        titleView.text = [NSString stringWithFormat:NSLocalizedString(@"NONAME TITLE VOICE", nil),self.message.from_user_name];
    }
    
    [mainView addSubview: titleView];
    
    [self.view addSubview:mainView];
}


-(MessageTypeBasicCell *) getMediaCellWithMessage:message indexPath:(NSIndexPath *) indexPath{
  
    _message = message;
    
    NSString *cellIdentifier = @"MessageTypeSoundDetailCell";
    
    MessageTypeBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        
        cell = [[MessageTypeBasicCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:cellIdentifier];
        
        [cell addSubview:_controlBar];
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
        return _controlBar.frame.size.height + 20 + 20;
    }
    else
    {
        return [message.tableViewCellClass cellHeightForMessage:message];
    }
}

#pragma mark -

-(void)onBack:(id)sender
{
	[_controlBar reset];
	
	[super onBack:sender];
}

-(void) report{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReportViolation object:_message];
}


@end
