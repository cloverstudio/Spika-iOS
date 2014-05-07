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

#import "HUImageView.h"
#import <CSUtils/CSWebServicesManager.h>
#import "CAAnimation+Blocks.h"
#import "HUImageView+Style.h"
#import "DatabaseManager.h"

@interface HUImageView () {

    CSImageDownloadBlock        _downloadBlock;
    __block BOOL                _commitSpinnerAnimation;
}

@property (nonatomic, weak) __block UIImageView *spinnerImageView;
@property (nonatomic, weak) __block NSURL *currentUrl;

@end

@implementation HUImageView

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
		
		_downloadedImageSize = CGSizeZero;
        self.backgroundColor = [UIColor whiteColor];
        
        _spinnerImageView = [self createNewSpinnerImageView];
        _spinnerImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_spinnerImageView];
        
        //_commitSpinnerAnimation = YES;
        //[self startSpinnerAnimation];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
		
		_downloadedImageSize = CGSizeZero;
        self.backgroundColor = [UIColor whiteColor];
        
        _spinnerImageView = [self createNewSpinnerImageView];
        _spinnerImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_spinnerImageView];
    
    
        [self addObserver:self
               forKeyPath:@"imageURL"
                  options:0
                  context:NULL];
        
//        [self addObserver:self
//               forKeyPath:@"image"
//                  options:0
//                  context:NULL];
        
        //_commitSpinnerAnimation = YES;
        //[self startSpinnerAnimation];
    }
    
    return self;
}

#pragma mark - Animations

- (void) startSpinnerAnimation {

    [_spinnerImageView setHidden:NO];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [rotateAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    rotateAnimation.cumulative = YES;
    rotateAnimation.duration = 2.0;
    rotateAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotateAnimation.repeatCount = 5 * 60 / 2.0; // max 5min
    
    [_spinnerImageView.layer addAnimation:rotateAnimation forKey:@"spinAnimation"];
}

- (void) stopSpinnerAnimation {

    _commitSpinnerAnimation = NO;
    [_spinnerImageView setHidden:YES];
    [_spinnerImageView.layer removeAnimationForKey:@"spinAnimation"];
}

#pragma mark - Observing

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {

    if ([keyPath isEqualToString:@"imageURL"]) {

        [self loadImageUrl:_imageURL];
    }
    else if ([keyPath isEqualToString:@"image"]) {
    
        [_spinnerImageView setHidden:YES];
    }
}

- (void) setImage:(UIImage *)image {

    [super setImage:image];
    
    if (image) {
		self.downloadedImageSize = image.size;
        [self stopSpinnerAnimation];
    } else
		self.downloadedImageSize = CGSizeZero;
}

#pragma mark - Override

- (void) layoutSubviews {

    _spinnerImageView.frame = [self frameForSpinnerImageView];
}

- (void) setFrame:(CGRect)frame {

    [super setFrame:frame];

    _spinnerImageView.frame = [self frameForSpinnerImageView];
}

#pragma mark - Images Download

- (void) loadImageUrl:(NSURL *)url {
    
    if(!url) {
        _downloadBlock = nil;
        self.image = nil;
        return;
    }
    
    if ([url isEqual:_currentUrl]) {
        return;
    }
    else {
        self.image = nil;
    }
    
    _currentUrl = url;

    [[CSWebServicesManager webServicesManager] cachedImageWithUrl:url
       completion:^(NSURL *imageURL, UIImage *image) {
                                                                                       
           if (!image && [imageURL isEqual:_currentUrl]) {
               
               _currentUrl = imageURL;
               [self startDownload:url];
           }
           else {
               
               _currentUrl = nil;
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self setImage:image];
               });
               
           }
    }];
    
}

- (void)startDownload:(NSURL *)url {
    
    __weak HUImageView *me = self;
    
    _commitSpinnerAnimation = YES;
    [self startSpinnerAnimation];
    
    
    [[DatabaseManager defaultManager] loadImage:[NSString stringWithFormat:@"%@",url]
        success:^(UIImage *image){
            
            if(image == nil)
                return;
            
            [me imageDownloadDidFinish:image];
			me.downloadedImageSize = image.size;
            me.currentUrl = nil;
            [me stopSpinnerAnimation];

            if([self.delegate respondsToSelector:@selector(downloadSucceed:)]){
                [self.delegate performSelector:@selector(downloadSucceed:) withObject:self];
            }
            
        }error:^(NSString *error) {
            
			me.downloadedImageSize = CGSizeZero;
            [me stopSpinnerAnimation];

            if([self.delegate respondsToSelector:@selector(downloadFailed:)]){
                [self.delegate performSelector:@selector(downloadFailed:) withObject:self];
            }

    }];

}

#pragma mark - Handling Download Response

- (void) imageDownloadDidFinish:(UIImage *)image {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (image) {
            [self setImage:image];
        }
        else {
            [self setImage:nil];
        }
        
        _downloadBlock = nil;
    });
}

@end
