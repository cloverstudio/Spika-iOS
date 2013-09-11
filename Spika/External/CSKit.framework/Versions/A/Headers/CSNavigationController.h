//
//  CSNavigationController.h
//  CSNavigationController
//
//  Created by marko.hlebar on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSNavigationController : UINavigationController

///sets the background image
///@param navImageName name of image to be used as background
-(void) setBackgroundImageName:(NSString *)navImageName;
//TODO: this gives a warning for some reason __attribute__((deprecated("use setBackgroundImage: instead")));

///sets the background image
///@param image image to be used as background
-(void) setBackgroundImage:(UIImage*) image;
@end
