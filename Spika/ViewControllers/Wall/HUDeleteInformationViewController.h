//
//  HUDeleteDialog.h
//  Spika
//
//  Created by Alex on 20.02.2014..
//
//

#import <UIKit/UIKit.h>
#import "HUBaseViewController.h"
#import "ModelMessage.h"

@interface HUDeleteInformationViewController : HUBaseViewController {
    IBOutlet UILabel        *titleLabel;
    IBOutlet UILabel        *deleteTimeLabel;
    IBOutlet UIButton       *closeButton;
}

-(IBAction) onClose;

@property (nonatomic) ModelMessage *message;

@end
