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

#import "HUSideMenuViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "HUCounterBalloonView.h"
#import "UIImage+Aditions.h"
#import "UIColor+Aditions.h"
#import "UILabel+Extensions.h"
#import "CSGraphics.h"
#import "UIImage+Aditions.h"

@implementation HUSideMenuViewController (Style)

-(void) setSettingsViewStyle {
    
    self.tableView.separatorColor = kHUColorGrayMenuSeparator;//[UIColor colorWithIntegralRed:10 green:10 blue:10];
    self.tableView.backgroundColor = kHUColorGrayMenu;//[UIColor colorWithPatternImage:[UIImage imageWithBundleImage:@"hu_background_pattern"]];
    
    [self setShadow];
}

-(void) setShadow {
    UIImage *shadowImage = [UIImage imageWithBundleImage:@"hu_tableview_right_shadow"];
    
    UIImageView *shadowImageView = [CSKit imageViewWithImage:shadowImage highlightedImage:nil];
    shadowImageView.height = self.view.height;
    shadowImageView.x = self.view.width - shadowImageView.width;
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    shadowImageView.y = 44;
    
    [self.view addSubview:shadowImageView];
}

-(OrderedDictionary *) newTableItems {
    
    //key -> tableView section
    //value -> array for tableView rows
    
    OrderedDictionary *dictionary = [OrderedDictionary new];
  
    [dictionary setObject:@[@""] forKey:NSLocalizedString(@"NOTIFICATIONS", nil)];
    [dictionary setObject:@[NSLocalizedString(@"Users", nil),
                            NSLocalizedString(@"Groups", nil),
                            NSLocalizedString(@"Profile", nil),
                            NSLocalizedString(@"Information", nil),
                            NSLocalizedString(@"Settings", nil),
                            NSLocalizedString(@"User Support", nil),
                            NSLocalizedString(@"Logout", nil)]
                   forKey:NSLocalizedString(@"ACCOUNT", nil)];

    return dictionary;
    
}

+(UINavigationBar *) newNavigationBarWithTitle:(NSString *)title {
    
    UINavigationBar *navBar = [UINavigationBar new];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [navBar setTitleTextAttributes:@{
                NSFontAttributeName: kFontArialMTOfSize(kFontSizeSmall),
            NSForegroundColorAttributeName: kHUColorWhite
    }];
    [navBar setTitleVerticalPositionAdjustment:5.0f forBarMetrics:UIBarMetricsDefault];
    [navBar setBackgroundImage:[UIImage imageWithColor:kHUColorDarkDarkGray andSize:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
    [navBar setItems:@[[[UINavigationItem alloc] initWithTitle:title]]];
    [navBar sizeToFit];
    
    return navBar;
}

-(CGFloat) heightForTableViewAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 24;
    }
    
    return 49;
}

-(CGFloat) heightForTableViewHeader {
    
    return 35;
}

-(UIImage *) imageForTableViewCellAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *imageName = nil;
    if (indexPath.section == 0)
        return nil;
    
    switch (indexPath.row) {
        case 0:
            imageName = @"hu_users_icon.png";
            break;
        case 1:
            imageName = @"icon_groups";
            break;
        case 2:
            imageName = @"hu_profile_icon";
            break;
        case 3:
            imageName = @"hu_information_icon";
            break;
        case 4:
            imageName = @"icon_settings";
            break;
        case 5:
            imageName = @"hu_personalwall_icon";
            break;
        case 6:
            imageName = @"hu_logout_icon";
            break;
        default:
            NSAssert(NO, @"You have provided wrong row! In case you added more rows, you have to provide a valid image name for each new row!");
            break;
    }

    UIImage *image = [UIImage imageNamed:imageName];
    
    NSAssert(image, @"You must provide a valid image name. Check if you deleted images named in the switch case OR you provided a wrong image name!");
    
    return image;
}

- (UIView *) viewForTableViewHeaderWithText:(NSString *)text {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeBounds(self.view.width, self.heightForTableViewHeader)];
    view.backgroundColor = [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
  
    UILabel *label = [UILabel labelWithText:text];
    label.textColor = [UIColor whiteColor];
    label.center = view.center;
    label.x = 50;
    
    [view addSubview:label];
    
    return view;
}

@end

@implementation HUSettingsViewTableCell

-(void) layoutSubviews {
    
    [super layoutSubviews];
    self.textLabel.x = 70;
    self.textLabel.y = 4;
    self.textLabel.backgroundColor = [UIColor clearColor];
}

@end

@implementation HUSettingsViewTableCell (Style)

-(UITableViewCell *) setSettingsViewStyle {
    
    UIView *overlay = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.3f] andSize:CGSizeMake(320, 44)]];
    
    self.textLabel.textColor = [UIColor colorWithIntegralRed:153 green:153 blue:153];
    self.textLabel.font = kFontArialMTOfSize(kFontSizeMiddium);
    self.selectedBackgroundView = overlay;
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

@end