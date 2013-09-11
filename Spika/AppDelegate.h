//
//  AppDelegate.h
//  Bind
//
//  Created by Ken Yasue on 12/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Models.h"
#import "HUPushNotificationManager.h"


@class HUSideMenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,HUPushNotificationDatasource>{
    
    HUSideMenuViewController *_sideMenuView;
    
}

-(void) disableTouchInMainView;
-(void) enableTouchInMainView;

+(AppDelegate *)getInstance;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CSNavigationController *navigationController;

@end