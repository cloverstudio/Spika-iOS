//
//  CSSegmentedControl.h
//  CSSegmentedControl
//
//  Created by marko.hlebar on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSSegmentedControl : UIControl
{
    NSMutableArray *_imageViews;
}
@property (nonatomic, readwrite) NSInteger selectedSegmentIndex;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *imagesHighlighted;
@end
