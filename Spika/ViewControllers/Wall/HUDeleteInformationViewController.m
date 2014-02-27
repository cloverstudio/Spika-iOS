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
    
    [titleLabel setText:NSLocalizedString(@"delete-info-title", nil)];
    
    if (_message.deleteType > 0) {
        deleteTimeLabel.text = [self getTimeAsStringForLabel:_message.deleteAt];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *) getTimeAsStringForLabel : (int) deleteAt {
    int now = [[NSDate date] timeIntervalSince1970];
    
    int seconds = deleteAt - now;
    
    NSLog(@"seconds: %d %d %d", now, deleteAt, deleteAt-now);
    
    int minutes = seconds / 60;
    int hours = minutes / 60;
    int days = hours / 24;
    
    if (days > 0) return [NSString stringWithFormat:@"in %d days", days];
    else if (hours > 0) return [NSString stringWithFormat:@"in %d hours", hours];
    else if (minutes > 0) return [NSString stringWithFormat:@"in %d minutes", minutes];
    else if (seconds > 0) return [NSString stringWithFormat:@"in %d seconds", seconds];
    else return @"after read";
}

@end
