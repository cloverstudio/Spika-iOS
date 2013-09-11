//
//  CSTabBarController.h
//  CSTabBarController
//
//  Created by marko.hlebar on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTabBarController : UITabBarController <UITabBarControllerDelegate>
{
    NSMutableArray *_tabImageViews;
    id <UITabBarControllerDelegate> _overrideDelegate;
}
@end
