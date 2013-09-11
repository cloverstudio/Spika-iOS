//
//  CSBarButtonItem.h
//  CSKit
//
//  Created by Giga on 12/27/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Availability.h>

NS_CLASS_AVAILABLE_IOS(4_0) @interface CSBarButtonItem : UIBarButtonItem

///iOS 4.0
///Creates a custom CSBarButtonItem with UIActivityIndicatorView added as subview
+(CSBarButtonItem *) barButtonItemWithActivitiIndicator;

///iOS 4.0
///Creates a custom CSBarButtonItem
///@param UIActivityIndicatorViewStyle style of UIActivityIndicatorView
+(CSBarButtonItem *) barButtonItemWithActivitiIndicator:(UIActivityIndicatorViewStyle)indicatorStyle;

///iOS 4.0
///Creates a custom CSBarButtonItem
///@param CGFloat widht of fixed item
+(CSBarButtonItem *) barButtonItemWithFixedSpace:(CGFloat) width;

@end
