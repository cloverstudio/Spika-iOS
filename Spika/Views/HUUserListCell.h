//
//  HUUserListCell.h
//  Spika
//
//  Created by Dao Xuan Cuong on 3/19/14.
//
//

#import <UIKit/UIKit.h>
#import "HUImageView.h"

@interface HUUserListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet HUImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *statusButton;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)messageAction:(id)sender;
@end
