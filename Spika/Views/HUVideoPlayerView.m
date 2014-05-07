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

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "HUVideoPlayerView.h"

@interface HUVideoPlayerView (){
    MPMoviePlayerController *_player;
    NSURL                   *_urlToPlay;
}
@end


@implementation HUVideoPlayerView

@synthesize player = _player;

+ (NSString *) videoPlayerPath{
    
    NSString *path;
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    path = [docsDir stringByAppendingFormat:@"/%@", MessageTypeVideoFileName];
    path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    return path;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(loadStateChanged:)
                                                     name: MPMoviePlayerLoadStateDidChangeNotification
                                                   object: _player];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(playBackStateChanged:)
                                                     name: MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object: _player];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(playerDidFinish:)
                                                     name: MPMoviePlayerPlaybackDidFinishNotification
                                                   object: _player];
        
        //fileURL = [NSURL URLWithString:@"http://hookup.clover-studio.com/Video/Video.mov"];
        
                
        self.frame = CGRectMake(10,0,300,300);
        
        
    }
    return self;
}

- (void) play:(NSURL *)file{
    
    NSString *videoURL = [NSString stringWithFormat:@"%@",file];
    if([videoURL rangeOfString:@"php"].location != NSNotFound){
        file = [NSURL URLWithString:[NSString stringWithFormat:@"%@.mov",file]];
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:file options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CGSize mediaSize = track.naturalSize;
    
    UIInterfaceOrientation orientation = [HUVideoPlayerView orientationForTrack:asset];
    
    self.videoSize = CGSizeMake(mediaSize.width,mediaSize.height);
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortrait){
        self.videoSize = CGSizeMake(mediaSize.height,mediaSize.width);
    }
    
    _urlToPlay = file;

    _player = [[MPMoviePlayerController alloc] init];
    [_player setContentURL:_urlToPlay];
    _player.scalingMode = MPMovieScalingModeAspectFit;
    _player.shouldAutoplay = NO;
    
    _player.view.frame = CGRectMake(
                                    0,
                                    0,
                                    self.width,
                                    self.height
                                    );
    
    _player.controlStyle = MPMovieControlStyleEmbedded;
    
    [self addSubview:_player.view];
    [_player prepareToPlay];
    [_player pause];
    
}

-(void) dealloc{
    [_player stop];
    _player = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MPMoviePlayer Notifications

-(void)playBackStateChanged:(NSNotification*)notification
{
    MPMoviePlaybackState playbackState = [_player playbackState];
    //NSLog(@"%d",playbackState);

    switch (playbackState) {
            
        case MPMoviePlaybackStateStopped :
            break;
            
        case MPMoviePlaybackStatePlaying :
            break;
            
        case MPMoviePlaybackStateInterrupted :
            break;
    }
    
}

-(void)loadStateChanged:(NSNotification*)notification
{
}

-(void)playerDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        //movie finished playin
    }else if (reason == MPMovieFinishReasonUserExited) {
        //user hit the done button
    }else if (reason == MPMovieFinishReasonPlaybackError) {
       
        NSError *error = [[notification userInfo] objectForKey:@"error"];
        if (error) {
        }
        
    }
    
}

+ (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

@end
