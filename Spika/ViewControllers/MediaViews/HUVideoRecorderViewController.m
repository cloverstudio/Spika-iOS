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

#import "HUVideoRecorderViewController.h"
#import "HUBaseViewController+Style.h"
#import "UserManager.h"
#import "HUVideoRecorderViewController+Style.h"
#import "HUVideoPlayerView.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "HUCachedImageLoader.h"

@interface HUVideoRecorderViewController () {
    
    UIScrollView *_containerView;
    UITextField *_recordingsTitle;
    HUVideoPlayerView *_videoPlayer;
    NSURL *_fileURL;
}

@end

@implementation HUVideoRecorderViewController

#pragma mark - Initialization

- (id) initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self) {
        _fileURL = fileURL;
        
        _videoPlayer = [[HUVideoPlayerView alloc] init];
        [_videoPlayer play:fileURL];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [HUBaseViewController sharedViewBackgroundColor];
    
    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(50,0,100,40)];
    lbNavTitle.backgroundColor = [UIColor clearColor];
    lbNavTitle.textColor = [UIColor whiteColor];
    lbNavTitle.textAlignment = NSTextAlignmentCenter;
    lbNavTitle.font = [UIFont boldSystemFontOfSize:kFontSizeMiddium];
    lbNavTitle.text = NSLocalizedString(@"VIDEO TITLE",nil);
    self.navigationItem.titleView = lbNavTitle;
    
    _containerView = [[UIScrollView alloc] init];
    _containerView.frame = [self frameForContainerView];
    
    _videoPlayer.frame = [self frameForVideoPlayer:_videoPlayer.videoSize];
    _containerView.contentSize = CGSizeMake(_videoPlayer.size.width,_videoPlayer.frame.origin.y + _videoPlayer.frame.size.height);

    [self loadBackButton];
    [self loadSendButton];
    [self loadAddVoiceTitleView];
    [_containerView addSubview:_videoPlayer];
    [self.view addSubview:_containerView];
    
}

- (void)loadBackButton {
    self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(didPressBackButton:)];
}

- (void) loadSendButton
{
    self.navigationItem.rightBarButtonItems = [HUBaseViewController barButtonItemWithTitle:NSLocalizedString(@"Send", nil)
                                                                                     frame:[HUBaseViewController frameForBarButtonWithTitle:NSLocalizedString(@"Send", @"")
                                                                                                                                       font:[HUBaseViewController fontForBarButtonItems]]
                                                                           backgroundColor:[HUBaseViewController sharedBarButtonItemColor]
                                                                                    target:self
                                                                                  selector:@selector(didPressSendButton:)];
    
}

- (void)loadAddVoiceTitleView
{
    UIView * mainView = [[UIView alloc] initWithFrame:[self frameForAddTitleView]];
    mainView.backgroundColor = [UIColor darkGrayColor];
    
    ModelUser *user = [[[UserManager defaultManager] getLoginedUser] copy];
    
    UIImageView *usersAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 12, 52, 52)];
	usersAvatarImageView.image = [UIImage imageNamed:@"user_stub"];
    
    [HUCachedImageLoader imageFromUrl:user.imageUrl completionHandler:^(UIImage *image) {
        if(image)
            usersAvatarImageView.image = image;
    }];
    
    [mainView addSubview:usersAvatarImageView];
    
    _recordingsTitle = [[UITextField alloc] initWithFrame:CGRectMake(75, 45, 220, 25)];
    _recordingsTitle.placeholder = NSLocalizedString(@"Add video title",nil);
    _recordingsTitle.backgroundColor = [UIColor clearColor];
    _recordingsTitle.font = [UIFont systemFontOfSize:kFontSizeBig];
    _recordingsTitle.textColor = [UIColor lightGrayColor];
    _recordingsTitle.delegate = self;
    
    [mainView addSubview: _recordingsTitle];
    
    [self.view addSubview:mainView];
}

#pragma mark - button events 

- (void)didPressBackButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) didPressSendButton:(id) sender{
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending video", nil)
										   message:@""];
    
    [self.view endEditing:NO];
    
    [self convertVideo];
}

#pragma mark - Transcode method

-(void)convertVideo
{
	AVAsset *video = [AVAsset assetWithURL:_fileURL];
	AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPresetPassthrough];
	exportSession.shouldOptimizeForNetworkUse = YES;
	exportSession.outputFileType = AVFileTypeMPEG4;
	
    NSInteger count = 0;
	NSString *filePath = nil;
	do {
		NSString *extension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)exportSession.outputFileType, kUTTagClassFilenameExtension);
        NSString *fileNameNoExtension = [[_fileURL URLByDeletingPathExtension] lastPathComponent];
		NSString *fileName = [NSString stringWithFormat:@"%@-%d",fileNameNoExtension , count];
		filePath = NSTemporaryDirectory();
		filePath = [filePath stringByAppendingPathComponent:fileName];
		filePath = [filePath stringByAppendingPathExtension:extension];
        count++;
        
	} while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
	
	NSURL *outputURL = [NSURL fileURLWithPath:filePath];
	
	exportSession.outputURL = outputURL;
	__weak HUVideoRecorderViewController *this = self;
	[exportSession exportAsynchronouslyWithCompletionHandler:^{
		if (AVAssetExportSessionStatusCompleted == exportSession.status)
		{
			[this sendVideoAtUrl:exportSession.outputURL];
		} else {
			[[AlertViewManager defaultManager] dismiss];
			[CSToast showToast:NSLocalizedString(@"Video sending failed!", nil) withDuration:3.0];
		}
	}];
}

-(void)sendVideoAtUrl:(NSURL *)url
{
	[[DatabaseManager defaultManager] sendVideoMessage:_targetUser
                                               toGroup:_targetGroup
                                                  from:[[UserManager defaultManager] getLoginedUser]
                                               fileURL:url
                                                 title:_recordingsTitle.text
                                               success:^(BOOL isSuccess,NSString *errStr){
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       
                                                       [[AlertViewManager defaultManager] dismiss];
                                                       
                                                       if(isSuccess == YES){
                                                           
                                                           [CSToast showToast:NSLocalizedString(@"Video sent", nil) withDuration:3.0];
                                                           
                                                           
                                                       }else {
                                                           
                                                           [CSToast showToast:errStr withDuration:3.0];
                                                           
                                                       }
                                                       
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                       
                                                   });
                                                   
                                               } error:^(NSString *errStr){
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [[AlertViewManager defaultManager] dismiss];
                                                       [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Error", nil)
                                                                                            message:errStr];
                                                       
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   });
                                                   
                                                   
                                               }];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if ([string isEqualToString:@"\n"]) {
        [self.view endEditing:NO];
        return NO;
    }
    
    return YES;
}



@end
