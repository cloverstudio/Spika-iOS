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

#import "SideMenuView.h"
#import "StyleManupulator.h"
#import "Utils.h"



#define SideBarRightMargin 60
#define MarginTop 22

@implementation SideMenuView

@synthesize width = _width;

- (id)init
{
    self = [super init];
    if (self) {
        
        _width = [Utils getDisplayWidth] - SideBarRightMargin;
        
        self.frame = CGRectMake(
            0 - _width,
            0,
            _width,
            [Utils getDisplayHeight]
        );
        
        [StyleManupulator attachSideMenuBG:self];

        
        _menuTable = [[UITableView alloc] init];

        _menuTable.backgroundColor = [UIColor clearColor];
        _menuTable.opaque = NO;
        _menuTable.backgroundView = nil;
        

        _menuTable.dataSource = self;
        _menuTable.delegate = self;
        _menuTable.separatorColor = [UIColor clearColor];
        _menuTable.frame = CGRectMake(
            0,
            MarginTop,
            self.frame.size.width,
            self.frame.size.height - MarginTop  
        );
        
        [self addSubview:_menuTable];
        

        
    }
    return self;
}




//------------------------------------------------------------------------------------------------------
#pragma mark UITableViewDataSource methods
//------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
        return 5;
}

//------------------------------------------------------------------------------------------------------
#pragma mark UITableViewDelegate methods
//------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Identifier for retrieving reusable cells.
    static NSString *cellIdentifier = @"MyCellIdentifier";
    
    // Attempt to request the reusable cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // No cell available - create one.
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row == 0){
        cell.textLabel.text = NSLocalizedString(@"Users", nil);
    }else if(indexPath.row == 1){
        cell.textLabel.text = NSLocalizedString(@"Groups", nil);
    }else if(indexPath.row == 2){
        cell.textLabel.text = NSLocalizedString(@"Profile", nil);
    }else if(indexPath.row == 3){
        cell.textLabel.text = NSLocalizedString(@"Settings", nil);
    }else if(indexPath.row == 4){
        cell.textLabel.text = NSLocalizedString(@"Logout", nil);
    }
    
    [StyleManupulator attachSideMenuCellBGBig:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuUsersSelected object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    }

    if(indexPath.row == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuGroupsSelected object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    }
 
    
    if(indexPath.row == 2){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuMyProfileSelected object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    }
    
    if(indexPath.row == 4){
        
        
        HUDialog *dialog = [[HUDialog alloc] initWithText:NSLocalizedString(@"Confirm Logout", nil)
                                                 delegate:self
                                              cancelTitle:NSLocalizedString(@"NO", nil)
                                               otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"YES", nil),nil]];
        [dialog show];

    }
    

}


-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index{
    
    if(index == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuLogoutSelected object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    }
}

- (void)dialogDidPressCancel:(HUDialog *)dialog {

}

@end