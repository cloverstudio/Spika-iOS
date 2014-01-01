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
#import <AVFoundation/AVFoundation.h>

@class HUVoiceRecorderViewController, HUVoicePlayerControlBar;
@protocol HUVoiceRecorderViewControllerDelegate <NSObject>

- (void)voiceRecorderViewController:(HUVoiceRecorderViewController *)sender sendAudio:(NSURL *)url title:(NSString *)title;

@end

@interface HUVoiceRecorderViewController : HUBaseViewController <AVAudioRecorderDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<HUVoiceRecorderViewControllerDelegate> delegate;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *titleView;
@property (nonatomic, weak) UILabel *statusLabel;
@property (nonatomic, weak) UIButton *micButton;
@property (nonatomic, weak) HUVoicePlayerControlBar *controlBar;
@property (nonatomic, weak) UILabel *timerLabel;

@end
