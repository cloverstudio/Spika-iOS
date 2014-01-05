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

#import "HUEULAViewController.h"
#import "HUSideMenuViewController.h"
#import "HUSideMenuViewController+Style.h"
#import "Utils.h"
#import "HUBaseViewController+Style.h"
#import "HUBaseViewController.h"
#import "Constants.h"
#import "AlertViewManager.h"

@implementation HUEULAViewController{
    UIButton *okButton;
}

-(void) loadView {
	
	[super loadView];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hp_wall_background_pattern"]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = kHUColorDarkDarkGray;
    titleLabel.textColor = kHUColorWhite;
    titleLabel.frame = CGRectMake(
                                  0,
                                  0,
                                  [Utils getDisplayWidth],
                                  40
                                  );
    
    titleLabel.text = NSLocalizedString(@"EULA-TITLE", nil);
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = kFontArialMTBoldOfSize(kFontSizeBig);
    
	okButton = [self newOkButtonWithSelector:@selector(okButtonDidPress:)];
    
    okButton.frame = CGRectMake(
                                0,
                                self.view.height - 36,
                                [Utils getDisplayWidth],
                                36
                                );
    
    okButton.hidden = YES;
    okButton.enabled = NO;
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = CGRectMake(
                               0,
                               titleLabel.y + titleLabel.height,
                               [Utils getDisplayWidth],
                               self.view.height - titleLabel.height - okButton.height
                               );
    
    NSString *htmlURL = [NSString stringWithFormat:@"%@/eula/%@",PageRootURL,NSLocalizedString(@"EULA_FILE", nil)];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:htmlURL]]];
    webView.delegate = self;
    
    [self.view addSubview:titleLabel];
	[self.view addSubview:webView];
	[self.view addSubview:okButton];
    
}
-(NSString *) title {
	return NSLocalizedString(@"Input password", nil);
}

-(UIButton *) newOkButtonWithSelector:(SEL)aSelector {
	UIButton *button = [HUBaseViewController buttonWithTitle:NSLocalizedString(@"EULA-AGREE", nil)
													   frame:CGRectMake(0,0,0,0)
											 backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
													  target:self
													selector:aSelector];
    
    
	return button;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    okButton.hidden = NO;
    okButton.alpha = 0.0;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         okButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         okButton.enabled = YES;
                         
                     }
     ];
}

- (void) okButtonDidPress:(id) sender{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"OK" forKey:EULAAgreed];
    [userDefault synchronize];
    
    [[AlertViewManager defaultManager] showTutorial:NSLocalizedString(@"tutorial-login",nil)];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
