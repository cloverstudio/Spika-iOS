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

#import "HUGroupsViewController.h"
#import "HUGroupsViewController+Style.h"

#import "HUGroupsTableViewCell.h"
#import "HUNewGroupViewController.h"

#import "DatabaseManager.h"
#import "Models.h"

#import "AlertViewManager.h"
#import "CSToast.h"

#import "UserManager.h"
#import "HUMenuNavigationItem+Groups.h"
#import "HUGroupsCategoryTableViewCell.h"
#import "HUCachedImageLoader.h"

@interface HUGroupsViewController () {

    CSTextField     *_searchField;
    UIView          *_searchFieldContainerView;
    NSMutableArray  *_groupsArray;
    NSMutableArray  *_searchGroupsArray;
    NSMutableArray  *_groupCategoryArray;
    
    DisplayMode     _displayMode;
    
    BOOL            _tutorialShowed;
}

@property (nonatomic, weak) UILabel *noGroupsLabel;


#pragma mark - Animations
- (void) animateKeyboardWillShow:(NSNotification *)aNotification;
- (void) animateKeyboardWillHide:(NSNotification *)aNotification;

#pragma mark - Data Loading
//- (void) loadGroups;
//- (void) commitSearch;
- (void) findGroupWithName:(NSString *)name;

@end

@implementation HUGroupsViewController

#pragma mark - Memory Management

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NotificationNewGroupCreated
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationHideSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupsShowMyGroups object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupsShowSearch object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupsAddGroup object:nil];
}

#pragma mark - Initialization

- (id) init {

    if (self = [super init]) {
        
        _tutorialShowed = NO;
        
        _displayMode = kModeGroup;
        
        _groupsArray = [[NSMutableArray alloc] init];
        _searchGroupsArray = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

-(void) setNavigationItem {
    
    [self addSlideButtonItem];
    
    self.navigationItem.rightBarButtonItem = [CSKit barButtonItemWithNormalImageNamed:@"submenu_icon_off"
                                                                          highlighted:nil
                                                                               target:self
                                                                             selector:@selector(toggleSubMenu:)];
}

-(void) addSubMenuObserver {
    

    __weak UIButton *button = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
    __weak HUGroupsViewController *this = self;
    
    __weak UILabel *noGroupsLabel = _noGroupsLabel;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationNewGroupCreated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationHideSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupsShowMyGroups object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupsShowSearch object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationGroupsAddGroup object:nil];


    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationNewGroupCreated
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      
                                                      [this loadFavoriteGroups];
                                                  }];
    
    ///take care of the case when the sub menu is dismissed from another source
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationHideSubMenu
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
													  if (button.selected)
														  button.selected = NO;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowSubMenu
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
													  if (button.selected == NO)
														  button.selected = YES;
                                                  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NotificationGroupsShowMyGroups
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      this.navigationItem.title = NSLocalizedString(@"Favorites", @"");
                                                      [this toggleSubMenu:button];
													  [this loadFavoriteGroups];
													  [this hideTableHeaderView];
													  [this toGroupMode];
                                                      noGroupsLabel.hidden = YES;
                                                  }];
    
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NotificationGroupsShowCategories
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      this.navigationItem.title = NSLocalizedString(@"Categories", @"");
                                                      [this toggleSubMenu:button];
                                                      [this hideTableHeaderView];
													  [this toCategoryMode];
                                                      noGroupsLabel.hidden = YES;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationGroupsShowSearch
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      this.navigationItem.title = NSLocalizedString(@"Search", @"");
                                                      [this toggleSubMenu:button];
													  [this clearSearch];
													  [this showSearch];
													  [this toGroupMode];
                                                      noGroupsLabel.hidden = YES;
                                                  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NotificationGroupsAddGroup
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      [this toggleSubMenu:button];
													  [this onAddGroup];
                                                  }];
     
    
}

-(void) toggleSubMenu:(UIButton*) button {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTuggleSubMenu object:[HUMenuNavigationItem groupMenuItems]];
}

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];
    
    [self setNavigationItem];
    [self addSubMenuObserver];

    
    _tutorialShowed = [self showTutorialIfCan:NSLocalizedString(@"tutorial-groups",nil)];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = nil;
    
    _noGroupsLabel = [self createNoGroupsLabel];
	[self.view addSubview:_noGroupsLabel];

    [self loadFavoriteGroups];

}

-(void) viewDidLoad {
    [super viewDidLoad];
    
}


- (void) viewWillAppear:(BOOL)animated {

    __weak HUGroupsViewController *this = self;
    
    [super viewWillAppear:animated];
    
    [self subscribeForKeyboardWillChangeFrameNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillShow:note];
        
    }];
    
    [self subscribeForKeyboardWillHideNotificationUsingBlock:^(NSNotification *note) {
        
        [this animateKeyboardWillHide:note];
        
    }];

}


- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    [self unsubscribeForKeyboardWillChangeFrameNotification];
    [self unsubscribeForKeyboardWillHideNotification];

}

- (void) toCategoryMode{
    
    _noGroupsLabel.text = NSLocalizedString(@"No Groups", nil);

    
    [self clearSearch];
    
    _displayMode = kModeCategory;
    
    [self loadGroupCategory];
}

- (void) toGroupMode{
    [self clearSearch];

    _displayMode = kModeGroup;
}

#pragma mark - Override

- (NSString *) title {

    return NSLocalizedString(@"Favorites", @"");
}

#pragma mark - Animations

- (void) animateKeyboardWillShow:(NSNotification *)aNotification {
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGSize kbSize = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect tableViewFrame = [self frameForTableView];
    tableViewFrame.size.height -= kbSize.height;
    
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0
                        options:curve
                     animations:^(){
                         
                         self.tableView.frame = tableViewFrame;
                     }
                     completion:nil];
}

- (void) animateKeyboardWillHide:(NSNotification *)aNotification {
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    UIViewAnimationOptions curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:[duration doubleValue]
                          delay:0.0
                        options:curve
                     animations:^(){
                         
                         self.tableView.frame = [self frameForTableView];
                     }
                     completion:nil];
}

#pragma mark - Data Loading

- (void) loadGroupCategory{

    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending", nil)
										   message:nil];
    
    void(^successBlock)(id result) = ^(NSArray *groupCategories){
        
        [[AlertViewManager defaultManager] dismiss];
        
        _groupCategoryArray = [[NSMutableArray alloc] initWithArray:groupCategories];
        
        [self setTableItems:_groupCategoryArray];
        
        [self showViewType:HUViewTypeMain animated:YES];

        [self showHideNoUsersLabelForDatasource:_groupCategoryArray];
        
    };
    
    void(^errorBlock)(id result) = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager] findGroupCategories:successBlock error:errorBlock];
    
}

- (void) loadFavoriteGroups {
    
    _noGroupsLabel.text = NSLocalizedString(@"No Favorite Groups", nil);

    
    __weak HUGroupsViewController *this = self;
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil)
										   message:nil];

    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    
    void(^successBlock)(id result) = ^(NSArray *groups){
        
        [[AlertViewManager defaultManager] dismiss];
        
        [_groupsArray setArray:groups];
        
        [this setTableItems:_groupsArray];
            
        if(_tutorialShowed == NO && (_groupsArray == nil || _groupsArray.count == 0))
            [this showOneTimeAfterBootMessage:NSLocalizedString(@"No Favorite Advice", nil) key:kOneTimeMsgNoFavorite];

        [self showHideNoUsersLabelForDatasource:_groupsArray];
        
    };
    
    void(^errorBlock)(id result) = ^(NSString *errStr){
        
        [[AlertViewManager defaultManager] dismiss];
        
    };
    
    [[DatabaseManager defaultManager] findUserFavoriteGroups:user success:successBlock error:errorBlock];
    
}

- (void) findGroupWithName:(NSString *)name {
    
    __weak HUGroupsViewController *this = self;
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil) message:nil];
    
    [[DatabaseManager defaultManager] findGroupByName:name
                                              success:^(id object) {
                                                  
                                                  [[AlertViewManager defaultManager] dismiss];
                                                  
                                                  NSArray *groups = (NSArray*)object;

                                                  [this showHideNoUsersLabelForDatasource:groups];
                                                  [this setTableItems:groups];
                                                  [this showViewType:HUViewTypeMain animated:YES];

                                              } error:^(NSString *errorString) {
                                                  
                                                  [[AlertViewManager defaultManager] dismiss];
                                                  [CSToast showToast:errorString withDuration:3.0];
                                                  
                                              }];
}

-(void)showHideNoUsersLabelForDatasource:(NSArray *)datasource
{
    
    if(datasource==nil){
        _noGroupsLabel.hidden = NO;
        return;
    }
    
	if (datasource != nil && [datasource respondsToSelector:@selector(count)] && datasource.count > 0)
		_noGroupsLabel.hidden == NO ? _noGroupsLabel.hidden = YES : 1;
	else
		_noGroupsLabel.hidden ? _noGroupsLabel.hidden = NO : 1;
}


- (void) clearSearch{
    [self setTableItems:[NSArray array]];
    [self showViewType:HUViewTypeMain animated:YES];
}

#pragma mark - Button Selectors

- (void) onAddGroup {
    
    HUNewGroupViewController *vc = [[HUNewGroupViewController alloc] initWithNibName:@"NewGroupView" bundle:nil];
    
    CSNavigationController *addNewGroupViewController = [[CSNavigationController alloc] initWithRootViewController:vc];
    [addNewGroupViewController setBackgroundImageName:@"hp_nav_bar_background"]; //background of Navigation bar
    
    [self.navigationController presentViewController:addNewGroupViewController   
                                        animated:YES
                                      completion:nil];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_displayMode == kModeGroup){
        ModelGroup *group = [self.items objectAtIndex:indexPath.row];
        return [HUGroupsTableViewCell heightForCellWithGroup:group];
    }
    
    if(_displayMode == kModeCategory){
        ModelGroupCategory *groupCategory = [self.items objectAtIndex:indexPath.row];
        return [HUGroupsCategoryTableViewCell heightForCellWithGroup:groupCategory];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_displayMode == kModeCategory){
        
        ModelGroupCategory *groupCategory = [self.items objectAtIndex:indexPath.row];
        
        static NSString *cellIdentifier = @"MyCategoryCellIdentifier";
        
        HUGroupsCategoryTableViewCell *cell = (HUGroupsCategoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil) {
            cell = [[HUGroupsCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:cellIdentifier];
        }
        
        [cell populateWithData:groupCategory];
        
        cell.avatarImageView.image = [UIImage imageNamed:@"group_stub"];
        
        NSString *url = groupCategory.imageUrl;
        
        [[DatabaseManager defaultManager] loadImage:url
                                            success:^(UIImage *image){
                                                
                                                if(image == nil)
                                                    return;
                                                
                                                cell.avatarImageView.image = [image copy];
                                                
                                            }error:^(NSString *error) {
                                                
                                            }];

        
        return cell;

    } else{
        
        ModelGroup *group = [self.items objectAtIndex:indexPath.row];
        
        static NSString *cellIdentifier = @"MyCellIdentifier";
        
        HUGroupsTableViewCell *cell = (HUGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell == nil) {
            cell = [[HUGroupsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
        }
        
        [cell populateWithData:group];
        
        cell.avatarImageView.image = [UIImage imageNamed:@"group_stub"];

        [HUCachedImageLoader thumbnailFromGroup:group completionHandler:^(UIImage *image, ModelGroup *targetGroup) {
            
            if(image == nil)
                return;
            
            if([targetGroup._id isEqualToString:group._id])
                cell.avatarImageView.image = [image copy];
            
        }];
                
        return cell;

        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(_displayMode == kModeCategory){
        
        ModelGroupCategory *groupCategory = [self.items objectAtIndex:indexPath.row];
        
        [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending", nil)
                                               message:nil];

        __weak HUGroupsViewController *this = self;
        
        [self setTitle:groupCategory.title];
        
        [[DatabaseManager defaultManager] findGroupsByCategoryId:groupCategory._id
         
                                                  success:^(id object) {
                                                      
                                                      _displayMode = kModeGroup;
                                                      
                                                      this.items = object;
                                                      
                                                      [[AlertViewManager defaultManager] dismiss];
                                                      
                                                      [self showHideNoUsersLabelForDatasource:object];
                                                      
                                                  } error:^(NSString *errorString) {
                                                      
                                                      [[AlertViewManager defaultManager] dismiss];
                                                  }];
        
    }else{

        ModelGroup *group = [self.items objectAtIndex:indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupProfile object:group];

    }
    
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}


#pragma mark - Search

-(HUSearchByNameView*) newSearchView {
    HUSearchByNameView *searchView = [[HUSearchByNameView alloc] init];
    searchView.delegate = self;
    return searchView;
}

-(void) showSearch {
    
    _noGroupsLabel.text = NSLocalizedString(@"No Groups", nil);
    
    self.navigationItem.title = NSLocalizedString(@"Search", @"");
    [self showTableHeaderView:[self newSearchView]];
}

-(void) hideTableHeaderView {
    if (self.tableView.tableHeaderView) {
        [self showTableHeaderView:nil];
    }
}

-(void) showTableHeaderView:(UIView*) view {
    self.tableView.tableHeaderView = view;
}

-(void) searchView:(HUSearchByNameView *)searchView searchText:(NSString *)text {
    [self findGroupWithName:text];
}


@end
