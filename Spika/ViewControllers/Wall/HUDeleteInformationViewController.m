//
//  HUDeleteDialog.m
//  Spika
//
//  Created by Alex on 20.02.2014..
//
//

#import "HUDeleteInformationViewController.h"

@implementation HUDeleteInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
