//
//  HUUserListCell.m
//  Spika
//
//  Created by Dao Xuan Cuong on 3/19/14.
//
//

#import "HUUserListCell.h"

@implementation HUUserListCell

- (void)awakeFromNib
{
    // Initialization code
    self.usernameLabel.font = kFontArialMTOfSize(17);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSString *) reuseIdentifier
{
    return @"HUUserListCell";
}

- (IBAction)favoriteAction:(id)sender {
}

- (IBAction)messageAction:(id)sender {
}
@end
