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

#import "UserListCell.h"
#import "StyleManupulator.h"
#import "DatabaseManager.h"
#import "HUCounterBalloonView.h"
#import "UserManager.h"
#import "HUSelectedTableViewCellVew.h"

#define AvatarMargin 10

@interface UserListCell ()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) ModelUser *user;
@end

@implementation UserListCell

#pragma mark - Initialization

-(id) initWithUser:(ModelUser *)user reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _user = user;
       
        _backView = [[UIView alloc] initWithFrame:[self frameForBackView]];
        _backView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_backView];
        
        _userAvatarImageView = [[UIImageView alloc] initWithFrame:[self frameForAvatarImage]];
		_userAvatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_userAvatarImageView];
        
        _label = [[UILabel alloc] initWithFrame:[self frameForLabel]];
        _label.font = kFontArialMTOfSize(16.0f);
        [self.contentView addSubview:_label];
        
        _contactImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"not_in_favorites_icon"]];
        _massageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_messages_icon"]];
        _userStatusIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_offline_icon"]];
        
        _contactImageView.frame = [self frameForFavoriteIcon];
        _massageIconView.frame = [self frameForMessageOffIcon];
        _userStatusIconView.frame = [self frameForUserStatusIcon];
        
        [self.contentView addSubview:_contactImageView];
        [self.contentView addSubview:_massageIconView];
        [self.contentView addSubview:_userStatusIconView];
        
        
        if([[DatabaseManager defaultManager].recentActivity numberOfActivitiesForTarget:user] > 0){
            _massageIconView.image = [UIImage imageNamed:@"messages_icon"];
            _massageIconView.frame = [self frameForMessageOnIcon];
        }

        
        if([[[UserManager defaultManager] getLoginedUser] isInContact:user]){
            _contactImageView.image = [UIImage imageNamed:@"favorites_icon"];
        }

        self.selectedBackgroundView = [[HUSelectedTableViewCellVew alloc] initWithFrame:self.frame withHeight:[UserListCell heightForCell]];

    }
    return self;
}

#pragma mark - View lifecycle

-(NSString *)userStatusIconViewImageNameForUserOnlineStatus:(NSString *)status
{
	if ([status isEqualToString:kUserOnlineStatusKey])
		return @"user_online_icon";
	else if ([status isEqualToString:kUserAwayStatusKey])
		return @"user_away_icon";
	else if ([status isEqualToString:kUserBusyStatusKey])
		return @"user_busy_icon";
	else 
		return @"user_offline_icon";
}

-(void) layoutSubviews {
    
    [super layoutSubviews];
    
    _backView.frame = [self frameForBackView];
    _userAvatarImageView.frame = [self frameForAvatarImage];
    _label.frame = [self frameForLabel];

}

-(void) populateWithData:(ModelUser *)user {
    
    NSAssert([user isKindOfClass:[ModelUser class]], @"Model you provided doesn't match ModelUser!");
    
    _user = user;
    _label.text = [user.name uppercaseString];
	_userStatusIconView.image = [UIImage imageNamed:[self userStatusIconViewImageNameForUserOnlineStatus:user.onlineStatus]];
    
    if([[DatabaseManager defaultManager].recentActivity numberOfActivitiesForTarget:user] > 0){
        _massageIconView.image = [UIImage imageNamed:@"messages_icon"];
        _massageIconView.frame = [self frameForMessageOnIcon];
    }else{
        _massageIconView.image = [UIImage imageNamed:@"no_messages_icon"];
        _massageIconView.frame = [self frameForMessageOffIcon];
    }
    
    if([[[UserManager defaultManager] getLoginedUser] isInContact:user]){
        _contactImageView.image = [UIImage imageNamed:@"favorites_icon"];
    }else{
        _contactImageView.image = [UIImage imageNamed:@"not_in_favorites_icon"];
        
    }
}

#pragma mark - Frame

-(CGRect) frameForBackView {
    return CGRectMake(6, 0, 314, 75);
}

-(CGRect) frameForAvatarImage {
	CGRect backViewFrame = [self frameForBackView];
    CGFloat height = backViewFrame.size.height - 5;
    return CGRectMake(backViewFrame.origin.x + 2.5f, backViewFrame.origin.y + 2.5f, height, height);
}

-(CGRect) frameForLabel {
    CGRect avatarImageFrame = [self frameForAvatarImage];
    return CGRectMake(CGRectGetMaxX(avatarImageFrame) + 10,
                      CGRectGetMinY(avatarImageFrame),
                      200, CGRectGetHeight(avatarImageFrame));
}

+(CGFloat) heightForCell {
    return 77;
}

-(CGRect) frameForFavoriteIcon {
    return CGRectMake(210, 55, 16.5, 14.5);
}

-(CGRect) frameForMessageOffIcon {
    return CGRectMake(250, 55, 16, 14.5);
}

-(CGRect) frameForMessageOnIcon {
    return CGRectMake(250, 48, 16, 22);
}

-(CGRect) frameForUserStatusIcon {
    return CGRectMake(290, 55, 16.5, 16.5);
}


/*

//------------------------------------------------------------------------------------------------------
#pragma mark private methods
//------------------------------------------------------------------------------------------------------

-(void) buildViews{
    
    _lblUserName = [[UILabel alloc] init];
    
    _lblUserName.frame = CGRectMake(
      AvatarThumbNailSize + AvatarMargin,
      0,
      self.frame.size.width - AvatarThumbNailSize - AvatarMargin,
      self.frame.size.height
    );
    
    
    
    _userAvatarImageView = [[UIImageView alloc] init];
    _userAvatarImageView.frame = CGRectMake(0,
                                            0,
                                            AvatarThumbNailSize,
                                            AvatarThumbNailSize);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    view.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:_userAvatarImageView];
    [self addSubview:_lblUserName];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

}
-(void) populateWithData:(ModelUser *)user{
    _user = user;
    _lblUserName.text = _user.name;
    
    [StyleManupulator attachDefaultCellBG:self];
    [StyleManupulator attachDefaultCellFont:_lblUserName];
    
//    [[DatabaseManager defaultManager] loadImage:_user.imageUrl
//
//      success:^(UIImage *image){
//          
//          dispatch_async(dispatch_get_main_queue(), ^{
//              
//              _ivAvatar.image = image;
//              
//          });
//          
//          
//      } error:^(NSString *errStr){
//          
//          
//      }];
    //[[DatabaseManager defaultManager] loadImage:_myModelUser.imageUrl
    
}
 
 */
@end
 
