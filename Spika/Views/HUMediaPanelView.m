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

#import "HUMediaPanelView.h"
#import "HUMediaPanelView+Style.h"
#import "CSPageControl.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import "Utils.h"

#import "UIImage+NoCache.h"

@interface HUMediaPanelView () {

    UIView          *_scrollViewContainerView;
    CSPageControl   *_pageControll;
}

@end

@implementation HUMediaPanelView


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithBundleImage:@"hp_wall_background_pattern"]];
        [self buildViews];
    }
    
    return self;
}

- (void) buildViews {
        
    UIButton *cameraBtn = [self newCameraBtn:@selector(onCamera)];
    [self addSubview:cameraBtn];
    
    UIButton *videoBtn = [self newVideoBtn:@selector(onVideo)];
    [self addSubview:videoBtn];
    
    UIButton *albumBtn = [self newAlbumBtn:@selector(onAlbum)];
    [self addSubview:albumBtn];
    
    
    UIButton *emojiBtn = [self newEmojiBtn:@selector(onEmoji)];
    [self addSubview:emojiBtn];
    
    UIButton *locationBtn = [self newLocationBtn:@selector(onLocation)];
    [self addSubview:locationBtn];
    
    
    UIButton *voiceButton = [self newVoiceButton:@selector(onVoice)];
    [self addSubview:voiceButton];
    
    
    _scrollViewContainerView = [self newScrollEmotionViewContainer];
    
    _pageControll = [self newPageControll];
    [_scrollViewContainerView addSubview:_pageControll];
    
    _scrollViewEmoticons = [self newScrollEmotionView];
    _scrollViewEmoticons.delegate = self;
    [_scrollViewContainerView addSubview:_scrollViewEmoticons];
    
    [self loadEmoticons];
}

#pragma mark - Button Selectors

- (void) onCamera {

    if([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectCameraButton:)]){
        [_delegate mediaPanelView:self
            didSelectCameraButton:nil];
    }
}

- (void) onVideo {
    
    if ([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectVideoButton:)]) {
        [_delegate mediaPanelView:self
             didSelectVideoButton:nil];
    }
}

- (void) onAlbum {

    if([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectAlbumButton:)]){
        [_delegate mediaPanelView:self
             didSelectAlbumButton:nil];
    }
}

- (void) onEmoji {

    [self addSubview:_scrollViewContainerView];
}

- (void) onLocation {

    if ([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectLocationButton:)]) {
        [_delegate mediaPanelView:self
          didSelectLocationButton:nil];
    }
}

- (void) onVoice {

    if ([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectVoiceButton:)]) {
        [_delegate mediaPanelView:self
             didSelectVoiceButton:nil];
    }
}

#pragma mark - Data Loading

- (void) loadEmoticons {
    
    [[DatabaseManager defaultManager] loadEmoticons:^(NSArray *aryData){
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _emoticonMasterData = [[NSArray alloc] initWithArray:aryData];
            
            [self performSelectorOnMainThread:@selector(buildEmoticionButtons)
                                   withObject:nil
                                waitUntilDone:NO];
            
        });
    }error:^(NSString *errStr){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [CSToast showToast:errStr withDuration:3.0];
        });
    }];
}

#pragma mark - Actions

-(void) resetState {
    
    [_scrollViewContainerView removeFromSuperview];
}

-(void) buildEmoticionButtons {
    
    _dicEmoticions = [[NSMutableDictionary alloc] init];
    
    CSButton *lastEmoticonButton = nil;

    for(int i = 0 ; i < [_emoticonMasterData count] ; i++){
        
        NSDictionary *data = [[_emoticonMasterData objectAtIndex:i] objectForKey:@"value"];
        
        int xPos = (i / 2) * (MediaBtnWidth + 5) + 5;
        int yPos = (i % 2) * MediaBtnHeight + (i % 2 ? 1 : 0);
        
        
        CSButton *emoticonBtn = [CSButton buttonWithFrame:CGRectMake(xPos,
                                                                     yPos,
                                                                     MediaBtnWidth,
                                                                     MediaBtnHeight)
                                                 callback:nil];
        emoticonBtn.tag = [_dicEmoticions count] + 1;
        
        [self performSelector:@selector(setEmoticonCallback:)
                   withObject:emoticonBtn
                   afterDelay:0.5];
        
        
        [_dicEmoticions setObject:data
                           forKey:[NSString stringWithFormat:@"%d",emoticonBtn.tag]];
        
        NSString *imageUrl = [Utils generateEmoticonURL:data];
        
        [[DatabaseManager defaultManager] loadEmoticons:imageUrl
                                                  toBtn:emoticonBtn
                                                success:^(UIImage *image){
                                                    
                                                    [emoticonBtn setImage:image forState:UIControlStateNormal];
                                                    
                                                } error:^(NSString *errorString){
                                                    
                                                }];
        
        [_scrollViewEmoticons addSubview:emoticonBtn];
        
        lastEmoticonButton = emoticonBtn;
    }
        
    _pageControll.numberOfPages = [_emoticonMasterData count] / 8;
    
    CGSize pageControllSize = CGSizeMake([_emoticonMasterData count] * 15, 10);
    _pageControll.frame = [self frameForPageControll:pageControllSize];
    
    _scrollViewEmoticons.contentSize = CGSizeMake(CGRectGetMaxX(lastEmoticonButton.frame),
                                                  CGRectGetHeight(_scrollViewEmoticons.frame));
}

-(void) sendEmoticon:(NSString *)tag {

    if ([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectEmoticon:)]) {
        [_delegate mediaPanelView:self
                didSelectEmoticon:[_dicEmoticions objectForKey:tag]];
    }
}

-(void) setEmoticonCallback:(CSButton *)target {
    
    __weak CSButton *aTarget = target;
    
    [target setPressCallback:^{
        
        NSDictionary *data = [_dicEmoticions objectForKey:[NSString stringWithFormat:@"%d", aTarget.tag]];
        
        if ([(NSObject *)_delegate respondsToSelector:@selector(mediaPanelView:didSelectEmoticon:)]) {
           [_delegate mediaPanelView:self
                   didSelectEmoticon:data];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControll.currentPage = page;
}

@end
