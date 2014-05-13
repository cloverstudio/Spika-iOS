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

#import "HUVoicePlayerControlBar.h"
#import "HUBaseViewController+Style.h"

#define CONTROL_BUTTONS_GAP 2

@interface HUVoicePlayerControlBar () {
    UIButton *_pauseButton;
    UIButton *_stopButton;
    UIButton *_playButton;
    UIView *_progressBar;
    AVAudioPlayer *_playerLocal;
    float _duration;
    NSTimer *_progressTimer;
    float _maxBarWidth;
}

@end

@implementation HUVoicePlayerControlBar

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInterface];        
    }
    return self;
}

- (void)setupInterface {
    
    self.backgroundColor = [UIColor whiteColor];
    
    
    _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _stopButton.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeDark];
    [_stopButton setImage:[UIImage imageNamed:@"hu_stop_button"] forState:UIControlStateNormal];
    _stopButton.frame = CGRectMake(0, 0, 50, self.size.height);
    [_stopButton addTarget:self action:@selector(stopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_stopButton];
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _pauseButton.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
    [_pauseButton setImage:[UIImage imageNamed:@"hu_pause_button"] forState:UIControlStateNormal];
    _pauseButton.frame = CGRectMake(_stopButton.frame.size.width + _stopButton.frame.origin.x + CONTROL_BUTTONS_GAP, 0, 50, self.size.height);
    [_pauseButton addTarget:self action:@selector(pauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _pauseButton.hidden = YES;
    [self addSubview:_pauseButton];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
    [_playButton setImage:[UIImage imageNamed:@"hu_play_button"] forState:UIControlStateNormal];
    _playButton.frame = _pauseButton.frame;
    [_playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];


    _progressBar = [[UIView alloc] init];
    _progressBar.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
    
    _maxBarWidth = self.frame.size.width - 2 * _pauseButton.frame.size.width - 2 * CONTROL_BUTTONS_GAP;
    
    CGRect progressFrame = CGRectMake(_pauseButton.frame.size.width + _pauseButton.frame.origin.x + CONTROL_BUTTONS_GAP, _pauseButton.frame.origin.y, _maxBarWidth , self.frame.size.height);
    _progressBar.frame = progressFrame;
    _progressBar.width = 0;
    
    UIView *backgroundBarView = [[UIView alloc] init];
    backgroundBarView.backgroundColor = [UIColor whiteColor];
    backgroundBarView.frame = progressFrame;
    [self addSubview:backgroundBarView];
    [self addSubview:_progressBar];
    
}



- (void)setDuration:(double)duration {
//    _progress 
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_progressTimer invalidate];
    _progressTimer = nil;
    CSLog(@"%@ deallocated!", NSStringFromClass([self class]));
}

#pragma mark Progress tracking methods

- (void)updateProgress {
    
    if (!_playerLocal || _playerLocal.duration <= 0) {        
        [self reset];
        return;
    }
    float progress = (float)_playerLocal.currentTime / (float)_playerLocal.duration;
    
    _progressBar.width = _maxBarWidth * progress;

}

#pragma mark AVAudioPlayer control methods

- (void)play {
    
    if(_voicePlayerPath == nil)
        return;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_voicePlayerPath];
    if(!fileExists)
        return;
    
    if (!_playerLocal) {

        NSError *error = nil;

        NSData* data = [NSData dataWithContentsOfFile:_voicePlayerPath];
        _playerLocal = [[AVAudioPlayer alloc] initWithData:data error:&error];
        if (error) {
            NSLog(@"AVAudioPlayer error:'%@'", [error description]);
        }
        
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                            error:&setCategoryError]) {
            // handle error
            NSLog(@"%@", setCategoryError);
        }
        
        _playerLocal.delegate = self;
        
    }
    
	[_playerLocal prepareToPlay];
    [_playerLocal play];

    if (!_progressTimer) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    
    _playButton.hidden = YES;
    _pauseButton.hidden = NO;
}

- (void)pause {
    _pauseButton.hidden = YES;
    _playButton.hidden = NO;
    [_playerLocal pause];
}

- (void)stop {
    [self reset];
}

- (void)reset {
    [_progressTimer invalidate];
    _progressTimer = nil;
    _pauseButton.hidden = YES;
    _playButton.hidden = NO;
    _progressBar.width = 0;
    _playerLocal = nil;
}

#pragma mark AVAudioPlayerDelegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
	__weak HUVoicePlayerControlBar *this = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [this reset];
    });
    
}

#pragma mark UIButton actions

- (void)stopButtonPressed:(UIButton *)sender {
    [self stop];
}

- (void)playButtonPressed:(UIButton *)sender {
    [self play];
}

- (void)pauseButtonPressed:(UIButton *)sender {
    [self pause];
}

@end
