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

#import "HUVoiceRecorderViewController.h"
#import "HUBaseViewController+Style.h"
#import "HUVoiceRecorderViewController+Style.h"
#import "HUVoicePlayerControlBar.h"
#import <CoreAudio/CoreAudioTypes.h>
#import "DatabaseManager.h"
#import "AlertViewManager.h"
#import "UserManager.h"
#import "HUCachedImageLoader.h"

#define fadeIn_fadOut_animation_duration	0.5f
#define kTimerUpdateInterval				1.0f

typedef enum {
    HUVoiceRecorderViewControllerStateRecordingStart,
    HUVoiceRecorderViewControllerStateRecordingInProgress,
    HUVoiceRecorderViewControllerStateRecordingDone
} HUVoiceRecorderViewControllerState;

@interface HUVoiceRecorderViewController () {
    HUVoiceRecorderViewControllerState _state;
    AVAudioRecorder *_recorder;
    NSTimer *_timer;
    UITextField *_recordingsTitle;
	double _recordingLength;
	UIAlertView *_errorAlertView;
    BOOL        _blockSend;
}

-(void)updateStatusLabelText:(NSString *)text controlBarAlpha:(CGFloat)alpha1 timerLabelAlpha:(CGFloat)alpha2;

@end


@implementation HUVoiceRecorderViewController


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
    [super loadView];
    
    _blockSend = NO;
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [HUBaseViewController sharedViewBackgroundColor];
    
    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:CGRectMake(50,0,100,40)];
    lbNavTitle.backgroundColor = [UIColor clearColor];
    lbNavTitle.textColor = [UIColor whiteColor];
    lbNavTitle.textAlignment = NSTextAlignmentCenter;
    lbNavTitle.font = [UIFont boldSystemFontOfSize:kFontSizeMiddium];
    lbNavTitle.text = NSLocalizedString(@"VOICE TITLE",nil);
    self.navigationItem.titleView = lbNavTitle;
    
    [self loadBackButton];
    [self loadSendButton];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[self frameForScrollView]];
	scrollView.bounces = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.scrollsToTop = NO;
	[self.view addSubview:scrollView];
	_scrollView = scrollView;
	
    [self loadAddVoiceTitleView];
    [self loadStatusLabel];
    [self loadMicButton];
    [self loadControlBar];
    [self loadSendButton];
    [self loadTimerLabel];
	
	_scrollView.contentSize = [self initialSizeOfScrollView];
	_scrollView.scrollEnabled = NO;
    
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
    _recordingsTitle.placeholder = NSLocalizedString(@"Add voice title","nil");
    _recordingsTitle.backgroundColor = [UIColor clearColor];
    _recordingsTitle.font = [UIFont systemFontOfSize:kFontSizeBig];
    _recordingsTitle.textColor = [UIColor lightGrayColor];
    _recordingsTitle.delegate = self;
    
    [mainView addSubview: _recordingsTitle];
	_titleView = mainView;
    
    [_scrollView addSubview:mainView];
}

-(void)loadStatusLabel
{
	UILabel *statusLabel = [[UILabel alloc] initWithFrame:[self frameForStatusLabel]];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.font =kFontArialMTOfSize(kFontSizeBig);
    statusLabel.textColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDark];
    statusLabel.text = NSLocalizedString(@"TAP AND RECORD", nil);
    [_scrollView addSubview:statusLabel];
	_statusLabel = statusLabel;
}

-(void)loadMicButton
{
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
    [micButton setImage:[UIImage imageNamed:@"hu_mic_button_new"] forState:UIControlStateNormal];
    [micButton setImage:[UIImage imageNamed:@"hu_mic_button_new_recording"] forState:UIControlStateSelected];
    
    micButton.frame = [self frameForMicButtonWithSize:micButton.imageView.image.size];
    
    [micButton addTarget:self action:@selector(didPressMicButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:micButton];
	_micButton = micButton;
}

-(void)loadControlBar
{
    HUVoicePlayerControlBar *controlBar = [[HUVoicePlayerControlBar alloc] initWithFrame:[self frameForVoicePlayerBar]];
    controlBar.alpha = 0;
    [_scrollView addSubview:controlBar];
	_controlBar = controlBar;

    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingFormat:@"/%@", MessageTypeVoiceFileName];

    _controlBar.voicePlayerPath = soundFilePath;
}

-(void)loadTimerLabel
{
    UILabel *timerLabel = [[UILabel alloc] initWithFrame:[self frameForTimerLabel]];
    timerLabel.center = CGPointMake(self.view.center.x, timerLabel.center.y);
    timerLabel.textAlignment = NSTextAlignmentCenter;
    timerLabel.font = kFontArialMTOfSize(kFontSizeExtraBig);
    timerLabel.text = @"00:00";
    timerLabel.textColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed];
    timerLabel.alpha = 0;
    timerLabel.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:timerLabel];
	_timerLabel = timerLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Wall", nil);
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingFormat:@"/%@", MessageTypeVoiceFileName];
    soundFilePath = [soundFilePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:8], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:22050.0], AVSampleRateKey,
                                    nil];
    
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    _recorder.delegate = self;
    
    AVAudioSession *audioSession =[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    if(error) {
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Microphon-device-busy",nil)];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	if (_timer != nil)
		[_timer invalidate];
    _timer = nil;    
    [_controlBar stop];
}

#pragma mark State

- (void)initializeStateMachine {
    _state = HUVoiceRecorderViewControllerStateRecordingStart;
}

- (void)switchState {
    
    _micButton.selected = !_micButton.selected;
    
    switch (_state) {
        case HUVoiceRecorderViewControllerStateRecordingStart:
            [self setState:HUVoiceRecorderViewControllerStateRecordingInProgress];
            
            break;
            
        case HUVoiceRecorderViewControllerStateRecordingInProgress:
            [self setState:HUVoiceRecorderViewControllerStateRecordingDone];
            
            break;
        
        case HUVoiceRecorderViewControllerStateRecordingDone:
            [self setState:HUVoiceRecorderViewControllerStateRecordingInProgress];
            
            break;
            
        default:
            break;
    }
}

- (void)setState:(HUVoiceRecorderViewControllerState)newState {    
    
    switch (newState) {
        case HUVoiceRecorderViewControllerStateRecordingStart:
            break;
            
        case HUVoiceRecorderViewControllerStateRecordingInProgress:
        {
			[_controlBar stop];

			if ([UIApplication sharedApplication].idleTimerDisabled == NO)
				[UIApplication sharedApplication].idleTimerDisabled = YES;
            
            if([_recorder record]){
                [self startCounting];
                [self updateStatusLabelText:NSLocalizedString(@"RECORDING", nil)
                            controlBarAlpha:0 timerLabelAlpha:1];
                
                [_controlBar reset];
                
            }else{
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Microphon-device-busy",nil)];
                _blockSend = YES;
            }
        }
            break;
            
        case HUVoiceRecorderViewControllerStateRecordingDone:
        {
			if ([UIApplication sharedApplication].idleTimerDisabled == YES)
				[UIApplication sharedApplication].idleTimerDisabled = NO;
			_recordingLength = _recorder.currentTime;
			[_recorder stop];
        }
            break;
            
        default:
            break;
    }
    
    _state = newState;
}

#pragma mark - Counting methods

- (void)startCounting {
    [_timerLabel setText:@"00:00"];
    if((!_timer) || !(_timer.isValid)) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerUpdateInterval target:self selector:@selector(updateTimeLabel:) userInfo:nil repeats:YES];
    }
}

- (void)updateTimeLabel: (id) sender {
    
    _recordingLength = _recorder.currentTime;
    
    if(_recordingLength > kAudioMaxLength && _state == HUVoiceRecorderViewControllerStateRecordingInProgress){
        [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Audio-Time-Too-Long", nil)];
        [self switchState];
        return;
    }
    
    NSInteger secs = (NSInteger) _recorder.currentTime  % 60;
    NSInteger mins = (NSInteger) _recorder.currentTime  / 60;
    
    _timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", mins, secs];
}

#pragma mark Button Selectors

//- (void)didPressListenButton:(UIButton *)sender {
//}

- (void)didPressSendButton:(UIButton *)sender {
    
    [self.view endEditing:NO];
    
    if(_blockSend)
        return;
    
    if(_state == HUVoiceRecorderViewControllerStateRecordingInProgress)
        [self switchState];
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending voice", nil)
										   message:@""];
    [self.delegate voiceRecorderViewController:self sendAudio:_recorder.url title:_recordingsTitle.text];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPressMicButton:(UIButton *)sender {
	[self switchState];
}

- (void)didPressBackButton:(UIButton *)sender {
    [_recorder stop];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AVAudioRecorderDelegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [_timer invalidate];
	_timer = nil;
	
    [self updateStatusLabelText:NSLocalizedString(@"RECORDING DONE", nil)
                controlBarAlpha:1 timerLabelAlpha:0];
}

-(void)resetRecordingUI
{
	[_controlBar reset];
	[self updateStatusLabelText:NSLocalizedString(@"TAP AND RECORD", nil)
				controlBarAlpha:0 timerLabelAlpha:0];
}

-(void)updateStatusLabelText:(NSString *)text controlBarAlpha:(CGFloat)alpha1 timerLabelAlpha:(CGFloat)alpha2
{
	_statusLabel.text = text;
	
	CGFloat offsetY = 0.0f;
	CGFloat height = [self initialSizeOfScrollView].height;
	if (self.view.height < _scrollView.contentSize.height) {
		if ((NSInteger)alpha2 == 1)
			height = self.view.height + _titleView.height;
		if ((NSInteger)alpha1 != 0 || (NSInteger)alpha2 != 0)
			offsetY = height - self.view.height;
		_scrollView.scrollEnabled = (offsetY == 0.0f) ? NO : YES;
	}
	
	[UIView animateWithDuration:fadeIn_fadOut_animation_duration animations:^{
		self.controlBar.alpha = alpha1;
		self.timerLabel.alpha = alpha2;
		_scrollView.contentSize = CGSizeMake(_scrollView.width, height);
		self.scrollView.contentOffset = CGPointMake(0, offsetY);
	}];
}

#pragma mark - UIAlertViewDelegate Methods

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView == _errorAlertView) {
		[self resetRecordingUI];
		_errorAlertView.delegate = nil;
		_errorAlertView = nil;
	}
}

#pragma mark -

-(void)onBack:(id)sender
{
	[_controlBar reset];
	
	[super onBack:sender];
}

#pragma mark - Check Recording Length


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        [self.view endEditing:NO];
        return NO;
    }
    
    return YES;
}


@end
