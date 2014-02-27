//
//  HUDeleteViewController.h
//  Spika
//
//  Created by Alex on 21.02.2014..
//
//

#import <UIKit/UIKit.h>
#import "HUBaseViewController.h"
#import "ModelMessage.h"

@interface HUDeleteViewController : HUBaseViewController {
    IBOutlet UILabel        *titleLabel;
    IBOutlet UIButton       *deleteDontButton;
    IBOutlet UIButton       *deleteNowButton;
    IBOutlet UIButton       *deleteIn5MinButton;
    IBOutlet UIButton       *deleteAfterDayButton;
    IBOutlet UIButton       *deleteAfterWeekButton;
    IBOutlet UIButton       *deleteAfterReadButton;
    IBOutlet UIButton       *closeButton;
}

-(IBAction) onClick:(id)sender;
-(IBAction) onClose;

@property (nonatomic) ModelMessage *message;

@end
