//
//  HUInformationViewController.m
//  Spika
//
//  Created by Ken Yasue on 16/02/14.
//
//

#import "HUInformationViewController.h"
#import "UserManager.h"

@implementation HUInformationViewController

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
	
	[super loadView];
    
    [self addSlideButtonItem];
    
	self.title = NSLocalizedString(@"Information", nil);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",InformationPageTopURL,[[UserManager defaultManager] getLoginedUser].token];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

}


@end
