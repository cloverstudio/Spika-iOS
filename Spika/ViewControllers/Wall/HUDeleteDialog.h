//
//  HUDeleteDialog.h
//  Spika
//
//  Created by Alex on 20.02.2014..
//
//

#import <UIKit/UIKit.h>
#import "HUBaseViewController.h"

@interface HUDeleteDialog : HUBaseViewController {
    IBOutlet UIImageView    *image;
    IBOutlet UIButton       *closeButton;
}

-(IBAction) onClose;

@end
