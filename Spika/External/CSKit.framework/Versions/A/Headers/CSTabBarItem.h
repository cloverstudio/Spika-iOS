//
//  CSTabBarItem.h
//  CSTabBarController
//
//  Created by marko.hlebar on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTabBarItem : UITabBarItem
@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *selectedImage;

///images should be of size 64x49 (128x98 retina)
-(id) initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage*) selectedImage tag:(NSInteger)tag;

@end
