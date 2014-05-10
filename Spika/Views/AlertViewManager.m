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

#import "AlertViewManager.h"
#import "AppDelegate.h"
#import "StrManager.h"
#import "HUBaseViewController.h"
#import "HUBaseViewController+Style.h"
#import "UIImage+Aditions.h"
#import "HUDialog.h"

#define kSpinnerImageNames	@[ @"LoadingAnimation1", @"LoadingAnimation2", @"LoadingAnimation3", @"LoadingAnimation4", @"LoadingAnimation5" ]
#define	kSpinnerImageNamesCount	5

AlertViewManager *_AlertViewManager;

@interface AlertViewManager ()
{
	NSInteger _currentSpinnerImageIndex;
    NSTimer   *_timer;
}

@end

@implementation AlertViewManager

@synthesize alertView = _alertView;

+(AlertViewManager *)defaultManager
{
	@synchronized([AlertViewManager class])
	{
		if (!_AlertViewManager)
			_AlertViewManager = [[self alloc] init];
		
		return _AlertViewManager;
	}
	
	return nil;
}


-(id) init{
	
	if((self = [super init])){
		
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        window = appDelegate.window;
		activated = NO;

        holderView = [[UIView alloc] init];
        holderView.frame = appDelegate.window.frame;
        holderView.backgroundColor = [UIColor clearColor];
        holderView.alpha = 0.0;

        
        blackView = [[UIView alloc] init];
        blackView.frame = CGRectMake(0,0,holderView.frame.size.width,holderView.frame.size.height);
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.5;
        
        labelTitle = [[UILabel alloc] init];
        labelTitle.frame = CGRectMake(0,appDelegate.window.frame.size.height / 2 + 20,appDelegate.window.frame.size.width,30);
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.backgroundColor = [UIColor clearColor];
        
        labelMessage = [[UILabel alloc] init];
        labelMessage.frame = CGRectMake(0,appDelegate.window.frame.size.height / 2 + 55,appDelegate.window.frame.size.width,30);
        labelMessage.textAlignment = NSTextAlignmentCenter;
        labelMessage.textColor = [UIColor whiteColor];
        labelMessage.backgroundColor = [UIColor clearColor];

		_spinnerImageNames = kSpinnerImageNames;
		_spinnerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_spinnerImageNames[0]]];
		_spinnerImageView.center = CGPointMake(appDelegate.window.frame.size.width / 2,
											   appDelegate.window.frame.size.height / 2);
		_spinnerImageView.hidden = YES;
		
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        indicator.center = CGPointMake(appDelegate.window.frame.size.width / 2,appDelegate.window.frame.size.height / 2);
        indicator.hidden = YES;
		
        labelTitle.alpha = 0.0f;
        labelMessage.alpha = 0.0f;
        
        [holderView addSubview:blackView];
        [holderView addSubview:labelTitle];
        [holderView addSubview:labelMessage];
		[holderView addSubview:indicator];
		[holderView addSubview:_spinnerImageView];
    }
	
	return self;
}

-(void) showAlert:(NSString *)title{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HUDialog *dialog = [[HUDialog alloc] initWithText:title delegate:nil cancelTitle:NSLocalizedString(@"Close",nil) otherTitle:nil];
        [dialog show];
        
    });
    
}
-(void) showAlert:(NSString *)title message:(NSString *)message{
    [self showAlert:message];
}

-(void)changeSpinnerImage
{
	_currentSpinnerImageIndex %= kSpinnerImageNamesCount;
	_spinnerImageView.image = [UIImage imageNamed:_spinnerImageNames[_currentSpinnerImageIndex]];
	++_currentSpinnerImageIndex;
}

-(void) showWaiting:(NSString *)title message:(NSString *)message{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _currentSpinnerImageIndex = 0;
//        _alertTimer = [CADisplayLink displayLinkWithTarget:self
//                                                  selector:@selector(changeSpinnerImage)];
//        _alertTimer.frameInterval = 30;
//        [_alertTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        if (_alertTimer != nil) {
            return ;
        }
        _alertTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:[AlertViewManager defaultManager]
                                                     selector:@selector(changeSpinnerImage)
                                                     userInfo:nil repeats:YES];
        
        _spinnerImageView.hidden = NO;
        labelMessage.textColor = [UIColor whiteColor];
        labelTitle.textColor = [UIColor whiteColor];
        
        labelTitle.text = title;
        labelMessage.text = message;
        
        if(!activated){
            [window addSubview:holderView];
        
            activated = YES;
            
            [UIView animateWithDuration:0.3
                             animations:^
            {
                holderView.alpha = 1.0;
                blackView.alpha = 0.5;
            }
                             completion:nil];
        }

        [window bringSubviewToFront:holderView];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(stopWaiting) userInfo:nil repeats:NO];
        

        
    });
}

-(void) showInputPassword:(NSString *)title resultBlock:(HUStringBlock)successBlock{
    passwordResultBlock = successBlock;
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:title
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:[StrManager _:@"Cancel"]
                                            otherButtonTitles:[StrManager _:@"OK"], nil];
    
    [message setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        passwordResultBlock([alertView textFieldAtIndex:0].text);
    }

}

-(void)hideIndicators
{
	if (_spinnerImageView.hidden == NO) {
		_spinnerImageView.hidden = YES;
		if (_alertTimer != nil) {
			[_alertTimer invalidate];
            _alertTimer = nil;
		}
	}
	
	if (indicator.hidden == NO) {
		indicator.hidden = YES;
		[indicator stopAnimating];
	}
}

-(void) stopWaiting{
    [[AlertViewManager defaultManager] showAlert:NSLocalizedString(@"Loading-Error", nil)];
    [self dismiss];
}

-(void) dismiss{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_timer invalidate];
        _timer = nil;
        
        activated = NO;
        __weak AlertViewManager *that = [AlertViewManager defaultManager];
        
        [UIView animateWithDuration:0.3
                     animations:^{
                         holderView.alpha = 0.0;
                         blackView.alpha = 0.5;
                     } 
                     completion:^(BOOL finished){
                         [holderView removeFromSuperview];
                         [that hideIndicators];
                     }
         ];

    });
    
}

-(void) dismissNow{
    
    activated = NO;
    
    [holderView removeFromSuperview];
	[self hideIndicators];
}

-(void) showTutorial:(NSString *)message{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    window = appDelegate.window;
    activated = NO;
    
    _holderViewForTutorial = [[UIView alloc] init];
    _holderViewForTutorial.frame = CGRectMake(-320,0,appDelegate.window.frame.size.width,appDelegate.window.frame.size.height);
    
    _holderViewForTutorial.backgroundColor = [UIColor clearColor];
    _holderViewForTutorial.alpha = 1.0;

    UIView *blackViewT = [[UIView alloc] init];
    blackViewT.frame = CGRectMake(0,0,holderView.frame.size.width,holderView.frame.size.height);
    blackViewT.backgroundColor = [UIColor blackColor];
    blackViewT.alpha = 0.5;
    
    UIImageView *whiteWindow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_window"]];
    whiteWindow.frame = CGRectMake(25,-182,270,182);
    whiteWindow.userInteractionEnabled = YES;
    
    [_holderViewForTutorial addSubview:blackViewT];
    [_holderViewForTutorial addSubview:whiteWindow];
    
    
    CGRect buttonFrame = CGRectMake(85,140,100,30);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:buttonFrame];
    [button setBackgroundImage:[UIImage imageWithColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen] andSize:CGSizeMake(1, 1)]
                      forState:UIControlStateNormal];
    [[button titleLabel] setFont:kFontArialMTBoldOfSize(kFontSizeMiddium)];
    [[button layer] setCornerRadius:CGRectGetHeight(buttonFrame) / 2];
    [[button layer] setMasksToBounds:YES];
    [button setTitle:NSLocalizedString(@"Close", @"") forState:UIControlStateNormal];
    
    
    [button addTarget:self
                      action:@selector(onCloseTutorial)
            forControlEvents:UIControlEventTouchUpInside];
    
    button.isAccessibilityElement = YES;
    button.accessibilityLabel = NSLocalizedString(@"Close", @"");
    [whiteWindow addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15,15,240,125)];
    label.font = kFontArialMTBoldOfSize(kFontSizeMiddium);
    label.textColor = [UIColor blackColor];
    label.text = message;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.alpha = 0.0;
    
    [whiteWindow addSubview:label];
    [window addSubview:_holderViewForTutorial];
    
    [UIView animateWithDuration:0.5
         animations:^{
             _holderViewForTutorial.frame = CGRectMake(0,0,appDelegate.window.frame.size.width,appDelegate.window.frame.size.height);

         }
         completion:^(BOOL finished){

             
             [UIView animateWithDuration:0.5
                  animations:^{
                      whiteWindow.frame = CGRectMake(25,50,270,182);
                  }
                  completion:^(BOOL finished){
                      
                      [UIView animateWithDuration:0.5
                           animations:^{
                               label.alpha = 1.0;
                           }
                           completion:^(BOOL finished){
                               
                               
                               
                               
                           }
                       ];
                  }
              ];
         }
     ];
}

- (void) onCloseTutorial{
    
    [UIView animateWithDuration:0.5
         animations:^{
             _holderViewForTutorial.frame = CGRectMake(0,568,_holderViewForTutorial.width,_holderViewForTutorial.height);
         }
         completion:^(BOOL finished){
             [_holderViewForTutorial removeFromSuperview];
         }
     ];
    
}

@end
