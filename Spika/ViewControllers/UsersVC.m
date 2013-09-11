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

#import "UsersVC.h"
#import "HUUsersViewController+Style.h"

#import "StyleManupulator.h"

#import "DatabaseManager.h"
#import "AlertViewManager.h"
#import "Models.h"
#import "UserListCell.h"

@interface UsersVC ()

@property (nonatomic) UISearchBar *searchBar;

@end

@implementation UsersVC

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        
        self.title = @"Users";
        
        _lazyLoadController = [[CSLazyLoadController alloc] init];
        _lazyLoadController.delegate = self;
        _lazyLoadController.dataSource = self;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];
    
    [self addSlideButtonItem];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [[DatabaseManager defaultManager] findUsers:^(NSArray *aryUsers){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _aryUsers = [[NSArray alloc] initWithArray:aryUsers];
            [self buildViews];
            
        });
        
    } error:^(NSString *errStr){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
        });
        
    }];
}



//------------------------------------------------------------------------------------------------------
#pragma mark private methods
//------------------------------------------------------------------------------------------------------

- (void)buildViews{
    
    [StyleManupulator attachDefaultBG:self.view];

//    _searchBar = [self newSearchBar];
    
    _tvUsers = [[UITableView alloc] init];
    _tvUsers.frame = CGRectMake(
        0,
        self.searchBar.relativeHeight,
        self.view.frame.size.width,
        self.view.frame.size.height - self.searchBar.relativeHeight
    );
 
    [self.view addSubview:_tvUsers];
    
    _tvUsers.dataSource = self;
    _tvUsers.delegate = self;
    
    
    [self.view addSubview:_searchBar];
}

//------------------------------------------------------------------------------------------------------
#pragma mark UITableViewDataSource methods
//------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [_aryUsers count];
}


//------------------------------------------------------------------------------------------------------
#pragma mark UITableViewDelegate methods
//------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ModelUser *user = [_aryUsers objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"MyCellIdentifier";
    
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UserListCell alloc] initWithUser:user reuseIdentifier:cellIdentifier];
    }
    
    [cell populateWithData:user];
    
    
    UIImage *image = [[DatabaseManager defaultManager] readFromCache:user.imageUrl];
    
    if (image) {
        
        cell.userAvatarImageView.image = image;
    }
    if (!image) {
        
        if (tableView.dragging == NO) {
            
            [_lazyLoadController downloaImage:user.imageUrl
                                 forIndexPath:indexPath];
        }
        
        cell.userAvatarImageView.image = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    ModelUser *user = [_aryUsers objectAtIndex:indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowUserWall object:user];
    
    /*
    if(indexPath.row == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuUsersSelected object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    }
    
    if(indexPath.row == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuGroupsSelected object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
    }
    */
    
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return AvatarThumbNailSize;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
//    if ([scrollView isEqual:_tvUsers] && !decelerate) {
//        [_lazyLoadController loadImagesForOnscreenRows:[_tvUsers indexPathsForVisibleRows]];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
    
//    if ([scrollView isEqual:_tvUsers]){
//        [_lazyLoadController loadImagesForOnscreenRows:[_tvUsers indexPathsForVisibleRows]];
//    }
}

#pragma mark - CSLazyLoadDelegate

- (void) lazyLoadController:(CSLazyLoadController *)controller
           didFailWithError:(NSString *)error
               forIndexPath:(NSIndexPath *)indexPath {

    UserListCell *cell = (UserListCell *)[_tvUsers cellForRowAtIndexPath:indexPath];
    cell.userAvatarImageView = nil;
}

- (void) lazyLoadController:(CSLazyLoadController *)controller
            didReceiveImage:(UIImage *)image
               forIndexPath:(NSIndexPath *)indexPath {

    UserListCell *cell = (UserListCell *)[_tvUsers cellForRowAtIndexPath:indexPath];
    cell.userAvatarImageView.image = image;
}

- (NSString *) lazyLoadController:(CSLazyLoadController *)controller
           urlForImageAtIndexPath:(NSIndexPath *)indexPath {

    ModelUser *user = [_aryUsers objectAtIndex:indexPath.row];
    return user.imageUrl;
}

@end
