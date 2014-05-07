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

#import "HUGroupsCategoryTableViewCell.h"
#import "HUGroupsCategoryTableViewCell+Style.h"
#import "HUSelectedTableViewCellVew.h"

@interface HUGroupsCategoryTableViewCell (){
    UIView                  *_backgroundView;
    UILabel                 *_groupNameLabel;
}

@end

@implementation HUGroupsCategoryTableViewCell

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
        
        self.selectedBackgroundView = [[HUSelectedTableViewCellVew alloc] initWithFrame:self.frame withHeight:77];

        
    }
    
    return self;
}

-(void) populateWithData:(ModelGroupCategory *)groupCategory {
    
    _groupCategory = groupCategory;    
    _backgroundView.frame = [HUGroupsCategoryTableViewCell frameForBackgroundView];
    _groupNameLabel.frame = [HUGroupsCategoryTableViewCell frameForGroupNameLabel];
    _groupNameLabel.text = _groupCategory.title;

}



#pragma mark - Cell Height

+ (CGFloat) heightForCellWithGroup:(ModelGroup *)group {
    
    CGRect backgroundViewFrame = [HUGroupsCategoryTableViewCell frameForBackgroundView];
    
    return CGRectGetHeight(backgroundViewFrame) + 2;
}
@end
