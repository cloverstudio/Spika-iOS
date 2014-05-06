/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "HUGroupsTableViewCell.h"
#import "HUGroupsTableViewCell+Style.h"
#import "HUCounterBalloonView.h"
#import "ModelGroup.h"
#import "DatabaseManager.h"
#import "UserManager.h"
#import "HUSelectedTableViewCellVew.h"

@interface HUGroupsTableViewCell () {

    UIView                  *_backgroundView;
    UILabel                 *_groupNameLabel;
    UIButton                *_favouriteButton;
    
    UIImageView *_favoriteImageView;
    UIImageView *_massageIconView;

}

@end

@implementation HUGroupsTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.contentView.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [self aBackgroundView];
        [self.contentView addSubview:_backgroundView];
        
        _avatarImageView = [self anAvatarImageView];
        [self.contentView  addSubview:_avatarImageView];
        
        _groupNameLabel = [self groupNameLabel];
        [self.contentView  addSubview:_groupNameLabel];
        
        _favoriteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"not_in_favorites_icon"]];
        _massageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_messages_icon"]];
        
        _favoriteImageView.frame = [self frameForFavoriteIcon];
        _massageIconView.frame = [self frameForMessageOffIcon];
        
        [self.contentView addSubview:_favoriteImageView];
        [self.contentView addSubview:_massageIconView];
        
        
        self.selectedBackgroundView = [[HUSelectedTableViewCellVew alloc] initWithFrame:self.frame withHeight:77];
    }
    
    return self;
}

-(void) populateWithData:(ModelGroup *)group {
    
    _group = group;
    
    _backgroundView.frame = [HUGroupsTableViewCell frameForBackgroundView];
    
    _groupNameLabel.frame = [HUGroupsTableViewCell frameForGroupNameLabel];
    _groupNameLabel.text = _group.name;

    if([[DatabaseManager defaultManager].recentActivity numberOfActivitiesForTarget:_group] > 0){
        _massageIconView.image = [UIImage imageNamed:@"messages_icon"];
        _massageIconView.frame = [self frameForMessageOnIcon];
    }else{
        _massageIconView.image = [UIImage imageNamed:@"no_messages_icon"];
        _massageIconView.frame = [self frameForMessageOffIcon];

    }
    
    if([[[UserManager defaultManager] getLoginedUser]._id isEqualToString:_group.userId]){
        _favoriteImageView.image = [UIImage imageNamed:@"mine_icon"];
    } else if ([[[UserManager defaultManager] getLoginedUser] isInFavoriteGroups:_group]){
        _favoriteImageView.image = [UIImage imageNamed:@"favorites_icon"];
    } else{
        _favoriteImageView.image = [UIImage imageNamed:@"not_in_favorites_icon"];
        
    }

}



#pragma mark - Cell Height

+ (CGFloat) heightForCellWithGroup:(ModelGroup *)group {

    CGRect backgroundViewFrame = [HUGroupsTableViewCell frameForBackgroundView];
    
    return CGRectGetHeight(backgroundViewFrame) + 2;
}

@end
