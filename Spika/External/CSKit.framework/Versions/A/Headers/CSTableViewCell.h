//
//  CSTableViewCell.h
//  CSTableView
//
//  Created by Luka Fajl on 2.5.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSTableView.h"

@interface CSTableViewCell : UITableViewCell

#pragma mark - Initialization
-(id) initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
   tableOrientation:(CSTableViewOrientation)tableOrientation;

@end
