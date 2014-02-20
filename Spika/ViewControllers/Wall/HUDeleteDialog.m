//
//  HUDeleteDialog.m
//  Spika
//
//  Created by Alex on 20.02.2014..
//
//

#import "HUDeleteDialog.h"

@implementation HUDeleteDialog

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
    }
    return self;
}

-(void) onClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
