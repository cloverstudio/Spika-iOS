//
//  CSTableView.h
//  CSTableView
//
//  Created by Luka Fajl on 2.5.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CSTableViewOrientation) {
    
    CSTableViewOrientationDefault = 0,
    CSTableViewOrientationUpsideDown,
    CSTableViewOrientationHorizontalLeft,
    CSTableViewOrientationHorizontalRight
};

@interface CSTableView : UITableView  

@property (nonatomic, readwrite) CGFloat rowWidth;
@property (nonatomic, readonly) CSTableViewOrientation orientation;

#pragma mark - Initialization
- (id) initWithFrame:(CGRect)frame
               style:(UITableViewStyle)style
    tableOrientation:(CSTableViewOrientation)tableOrientation;


#pragma mark - Table Actions
- (void) setNumberOfVisibleCells:(NSUInteger)numberOfCells;

#pragma mark - Getters
- (CSTableViewOrientation) tableOrientation;
- (CGFloat) cellSize;

@end
