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
#import "CAAnimation+Blocks.h"
#import "HUImageView+Style.h"
#import "DatabaseManager.h"

@interface HUImageView () {

    CSImageDownloadBlock        _downloadBlock;
    __block BOOL                _commitSpinnerAnimation;
}

@property (nonatomic, strong) __block UIImageView *spinnerImageView;
@property (nonatomic, strong) __block NSURL *currentUrl;

@end

@implementation HUImageView

#pragma mark - Memory Management

- (void)dealloc {
    //[self removeObserver:self
    //          forKeyPath:@"imageURL"];
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
		
		_downloadedImageSize = CGSizeZero;
        self.backgroundColor = [UIColor whiteColor];
        
        _spinnerImageView = [self createNewSpinnerImageView];
        _spinnerImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_spinnerImageView];
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
        [self startDownload:self.imageURL];
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
    }
    else {
		self.downloadedImageSize = CGSizeZero;
    }
}

#pragma mark - Override

- (void) layoutSubviews {

    [super layoutSubviews];
    _spinnerImageView.frame = [self frameForSpinnerImageView];
}

- (void) setFrame:(CGRect)frame {

    [super setFrame:frame];
    _spinnerImageView.frame = [self frameForSpinnerImageView];
}

#pragma mark - Image Download

- (void)startDownload:(NSURL *)url {
    
    if (!url) {
        self.image = nil;
        _downloadBlock = nil;
        return;
    }
    
    if ([url isEqual:_currentUrl]) { return; }
    else { self.image = nil; }
    
    _commitSpinnerAnimation = YES;
    [self startSpinnerAnimation];
    
    __weak HUImageView *this = self;
    void (^responseHandler)(UIImage *) = ^(UIImage *image) {
    
        if(image == nil) { return; }
        
        __strong HUImageView *strongThis = this;
        [strongThis imageDownloadDidFinish:image];
        strongThis.downloadedImageSize = image.size;
        strongThis.currentUrl = nil;
        [strongThis stopSpinnerAnimation];
        
        if([strongThis.delegate respondsToSelector:@selector(downloadSucceed:)]){
            [strongThis.delegate performSelector:@selector(downloadSucceed:) withObject:self];
        }
    };
    
    void (^errorHandler)(NSString *) = ^(NSString *error) {
    
        __strong HUImageView *strongThis = this;
        
        strongThis.downloadedImageSize = CGSizeZero;
        [strongThis stopSpinnerAnimation];
        
        if([strongThis.delegate respondsToSelector:@selector(downloadFailed:)]){
            [strongThis.delegate performSelector:@selector(downloadFailed:) withObject:self];
        }
    };
    
    [[DatabaseManager defaultManager] loadImage:[NSString stringWithFormat:@"%@",url]
                                        success:responseHandler
                                          error:errorHandler];
}

#pragma mark - Handling Download Response

- (void) imageDownloadDidFinish:(UIImage *)image {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (image) { [self setImage:image]; }
        else { [self setImage:nil];  }
        
        _downloadBlock = nil;
    });
}

@end
