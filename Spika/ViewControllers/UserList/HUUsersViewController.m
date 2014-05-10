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

#import "HUUsersViewController.h"
#import "HUUsersViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "UserListCell.h"
#import "UserManager.h"
#import "UIResponder+Extension.h"
#import "UIColor+Aditions.h"
#import "HUMenuNavigationItem+Users.h"  
#import "HUSearchByNameView.h"
#import "HUExploreUsersView.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"
#import "DatabaseManager.h"
#import "HUCachedImageLoader.h"

#define MODELS @[@"ModelUser",@"ModelGroup"]    

@interface HUUsersViewController (){
    BOOL _tutorialShowed;
}

@property (nonatomic, strong) HUSearchBarController *searchBar;
@property (nonatomic, weak) UILabel *noUsersLabel;

@end

@implementation HUUsersViewController

#pragma mark - Dealloc

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationHideSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowUsersSearch object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowUsersExplore object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowUsersMyContacts object:nil];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.items = [NSMutableArray new];
        //_searchBar = [self newSearchBar];
                
        _tutorialShowed = NO;
        
    }
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];
    
    [self setNavigationItem];
    
    [self addSubMenuObserver];

    _tutorialShowed = [self showTutorialIfCan:NSLocalizedString(@"tutorial-users",nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	UILabel *label = [self createNoUsersLabel];
    
	[self.view addSubview:label];
    
	_noUsersLabel = label;
    
    self.view.clipsToBounds = YES;
    
    [self loadUserContacts];

}

-(void) clearList{
    self.items = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}
-(void) setNavigationItem {
    
    [self addSlideButtonItem];
    
    self.navigationItem.rightBarButtonItem = [CSKit barButtonItemWithNormalImageNamed:@"submenu_icon_off"
                                                                          highlighted:nil
                                                                               target:self
                                                                             selector:@selector(toggleSubMenu:)];
}

-(void) addSubMenuObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationHideSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowSubMenu object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowUsersSearch object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowUsersExplore object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationShowUsersMyContacts object:nil];

    
    __weak UIButton *button = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
    __weak HUUsersViewController *this = self;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowUsersSearch
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      [this clearList];
 													  [this toggleSubMenu:button];
													  [this showSearch];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowUsersExplore
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      [this clearList];
													  [this toggleSubMenu:button];
													  [this showExplore];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NotificationShowUsersMyContacts
                                                      object:nil
                                                       queue:NSOperationQueue.mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      [this clearList];
                                                      [this toggleSubMenu:button];
                                                      [this loadUserContacts];
                                                      [this hideTableHeaderView];
                                                  }];

}

#pragma mark - Explore 

-(HUExploreUsersView*) newExploreView {
    HUExploreUsersView *View = [[HUExploreUsersView alloc] init];
    View.delegate = self;
    return View;
}

-(void) exploreView:(HUExploreUsersView *)exploreView exploreGender:(HUGender)gender fromAge:(NSInteger)fromAge toAge:(NSInteger)toAge {
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil) message:nil];
    
	__weak HUUsersViewController *this = self;
    [[DatabaseManager defaultManager] findUsersContainingString:@""
                                                        fromAge:[NSNumber numberWithInteger:fromAge]
                                                          toAge:[NSNumber numberWithInteger:toAge]
                                                         gender:gender
                                                        success:^(NSArray *users) {
                                                            [[AlertViewManager defaultManager] dismiss];
															[this showHideNoUsersLabelForDatasource:users];
                                                            [this setTableItems:users];
                                                            [this showViewType:HUViewTypeMain animated:YES];
                                                        }
                                                          error:^(NSString *errorString) {
                                                              [[AlertViewManager defaultManager] dismiss];
                                                          }];
}

-(void) showExplore {
    _allowSwipe = NO;
    self.navigationItem.title = NSLocalizedString(@"Explore", nil);
    [self showTableHeaderView:[self newExploreView]];
    _noUsersLabel.text = NSLocalizedString(@"No Users", nil);
    _noUsersLabel.hidden = YES;
}

#pragma mark - Search

-(HUSearchByNameView*) newSearchView {
    HUSearchByNameView *searchView = [[HUSearchByNameView alloc] init];
    searchView.delegate = self;
    return searchView;
}

-(void) showSearch {
    _allowSwipe = YES;

    self.navigationItem.title = NSLocalizedString(@"Search", nil);
    [self showTableHeaderView:[self newSearchView]];
    _noUsersLabel.text = NSLocalizedString(@"No Users", nil);
    _noUsersLabel.hidden = YES;
}

-(void) hideTableHeaderView {
    if (self.tableView.tableHeaderView) {
        [self showTableHeaderView:nil];
    }
}

-(void) showTableHeaderView:(UIView*) view {
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = view;
    self.tableView.tableHeaderView.alpha = 0;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.tableView.tableHeaderView.alpha = 1;
                     }];
    
    [self.tableView endUpdates];
}

-(void) searchView:(HUSearchByNameView *)searchView searchText:(NSString *)text {
    
	__weak HUUsersViewController *this = self;
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil) message:nil];
    
    [[DatabaseManager defaultManager] findUsersContainingString:text
                                                        fromAge:@0
                                                          toAge:@0
                                                         gender:@""
                                                        success:^(NSArray *users) {
                                                            [[AlertViewManager defaultManager] dismiss];
															[this showHideNoUsersLabelForDatasource:users];
                                                            [this setTableItems:users];
                                                            [this showViewType:HUViewTypeMain animated:YES];
                                                        }
                                                          error:^(NSString *errorString) {
                                                              [[AlertViewManager defaultManager] dismiss];
                                                              
                                                          }];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    CSLog(@"%f", scrollView.contentOffset.y);
    /*
    if (scrollView.contentOffset.y < -60) {
        [self showSearch];
    }
    else if (scrollView.contentOffset.y > 0) {
        [self hideTableHeaderView];
    }
    */
    
}

-(void) toggleSubMenu:(UIButton*) button {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTuggleSubMenu object:[HUMenuNavigationItem userMenuItems]];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hideSearchBar:(BOOL)isHidden {
    
    [self hideSearchBar:isHidden animated:NO];
}

-(void) hideSearchBar:(BOOL)isHidden animated:(BOOL)animated {
        
    void(^animateBlock)(void) = ^{
        
        if (isHidden) {
            self.searchBar.view.y -= self.searchBar.view.height;
            self.tableView.y = 0;
        } else {
            self.searchBar.view.y = 0;
            self.tableView.y = _searchBar.view.relativeHeight;
        }
        
    };
    
    void(^animationFinish)(BOOL finished) = ^(BOOL finished){
        if (isHidden) {
            self.tableView.height = self.view.height;
        } else {
            self.tableView.height = self.view.height - self.tableView.y;
        }
    };
    
    if (animated) {
        if (isHidden) {
            animationFinish(YES);
        }
        [UIView animateWithDuration:.25f
                         animations:animateBlock
                         completion:!isHidden ? animationFinish : nil];
    } else {
        animateBlock();
        animationFinish(YES);
    }
    
}

#pragma mark - Selectors

-(void) searchBarButtonItemDidPress:(id)sender {
    
    if (self.searchBar.view.y == 0) {
        [self hideSearchBar:YES animated:YES];
    } else if (self.searchBar.view.y <= -self.searchBar.view.height) {
        [self hideSearchBar:NO animated:YES];
    }
    
}

-(void) loadUserContacts {
    
    _allowSwipe = YES;
    _noUsersLabel.text = NSLocalizedString(@"No Users Contacts", nil);
    _noUsersLabel.hidden = YES;

    
    self.navigationItem.title = NSLocalizedString(@"My Contacts", nil);
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    
    ModelUser *user = [UserManager defaultManager].getLoginedUser;
    
	__weak HUUsersViewController *this = self;
    
    void(^successBlock)(id result) = ^(id result) {
        
        [[AlertViewManager defaultManager] dismiss];
        
        this.items = result;
		[this showHideNoUsersLabelForDatasource:nil];
        
        if(_tutorialShowed == NO && (this.items == nil || this.items.count == 0))
            [this showOneTimeAfterBootMessage:NSLocalizedString(@"No Contact Advice", nil) key:kOneTimeMsgNoContact];
            
        [this showViewType:HUViewTypeMain animated:YES];
        
        if(this.items.count == 0)
            _noUsersLabel.hidden = NO;
    };
    
    [[DatabaseManager defaultManager] findUserContactList:user
                                                  success:successBlock
                                                    error:nil];
    
    
}

-(void) searchUsersWithText:(NSString *)text {
    
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil) message:nil];
    
	__weak HUUsersViewController *this = self;
    [[DatabaseManager defaultManager] findUsersContainingString:text
														success:^(NSArray *users)
	{
        [[AlertViewManager defaultManager] dismiss];
		[this showHideNoUsersLabelForDatasource:users];
        this.items = [users mutableCopy];
        [this showViewType:HUViewTypeMain animated:YES];
    }
	error:^(NSString *errorString)
	{
        [[AlertViewManager defaultManager] dismiss];
        [this showViewType:HUViewTypeNoItems animated:YES];
    }];
    
}

-(void)showHideNoUsersLabelForDatasource:(NSArray *)datasource
{

    if(datasource==nil){
        _noUsersLabel.hidden = YES;
        return;
    }
    
	if (datasource != nil && [datasource respondsToSelector:@selector(count)] && datasource.count > 0)
		_noUsersLabel.hidden == NO ? _noUsersLabel.hidden = YES : 1;
	else
		_noUsersLabel.hidden ? _noUsersLabel.hidden = NO : 1;
}

#pragma mark - UITableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ModelUser *user = [self.items objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"MyCellIdentifier";
    
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UserListCell alloc] initWithUser:user reuseIdentifier:cellIdentifier];
    }
    
    [cell populateWithData:user];
    
    cell.userAvatarImageView.image = [UIImage imageNamed:@"user_stub"];
    

    [HUCachedImageLoader thumbnailFromUser:user completionHandler:^(UIImage *image, ModelUser *targetUser) {
        
        if(image == nil)
            return;
        
        if([targetUser._id isEqualToString:user._id])
            cell.userAvatarImageView.image = [image copy];
        
    }];

    return cell;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UserListCell heightForCell];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ModelUser *user = [self.items objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:user];
}

#pragma mark - HUSearchBarController

-(NSUInteger) numberOfRowsForSearchBar:(HUSearchBarController *)searchBar {
    return 3;
}

-(NSString *) headerTextForSearchBar:(HUSearchBarController *)searchBar {
    return NSLocalizedString(@"Search-Title", nil);
}

-(HUSearchBarModel *) searchBar:(HUSearchBarController *)searchBar modelForRow:(NSUInteger)row {
    HUSearchBarModel *model = nil;
    switch (row) {
        case 0:
            model = [HUSearchBarModel textFieldWithPlaceholderText:@"name"];
            break;
        case 1:
            model = [HUSearchBarModel textFieldWithPlaceholderText:@"age" keyboardType:UIKeyboardTypeNumberPad];
            break;
        case 2:
            model = [HUSearchBarModel selectionNamed:@"gender" firstChoiceNamed:@"male" secondChoiceNamed:@"female"];
        default:
            break;
    }
    
    return model;
}

-(UIColor *) backgroundColorForSearchBar:(HUSearchBarController *)searchBar {
    return [HUBaseViewController colorWithSharedColorType:HUSharedColorTypeGreen];
}

#pragma mark - HUSearchBarDelegate

-(void) searchBar:(HUSearchBarController *)searchBar searchWithParameters:(NSDictionary *)parameters {
    
    [[UIResponder currentFirstResponder] resignFirstResponder];
    
    [self hideSearchBar:YES];
    
    NSString *name = parameters[@"name"];
    [self searchUsersWithText:name];
}

@end
