//
//  HUUsersInGroupViewController.m
//  Spika
//
//  Created by Dao Xuan Cuong on 3/19/14.
//
//

#import "HUUsersInGroupViewController.h"
#import "HUUserListCell.h"
#import "ModelUser.h"
#import "HUCachedImageLoader.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"

@interface HUUsersInGroupViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isLoading;
    BOOL _isEnd;
}
@end

@implementation HUUsersInGroupViewController

#pragma mark - Dealloc
- (void)dealloc
{
    CS_RELEASE(_tableViewUsers);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CS_SUPER_DEALLOC;
    
}
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Members", nil);
        self.totalUsers = -1;
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.usersArray && self.totalUsers != -1) {
        if (self.usersArray.count >= self.totalUsers) {
            _isEnd = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [self.tableViewUsers indexPathForSelectedRow];
    if (indexPath) {
        [self.tableViewUsers deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UITableViewDatasource
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HUUserListCell";
    HUUserListCell *cell = (HUUserListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HUUserListCell" owner:self options:nil];
        cell = (HUUserListCell *)[nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    ModelUser *user = [_usersArray objectAtIndex:indexPath.row];
    cell.usernameLabel.text = user.name;
    if ([user.onlineStatus isEqualToString:@"online"]) {
        [cell.statusButton setBackgroundImage:[UIImage imageNamed:@"user_online_icon"] forState:UIControlStateNormal ] ;
    }else{
        [cell.statusButton setBackgroundImage:[UIImage imageNamed:@"user_offline_icon"] forState:UIControlStateNormal ];
    }
    if (user.thumbFileId) {
        [HUCachedImageLoader imageFromUrl:user.imageUrl completionHandler:^(UIImage *image) {
            if(image)
                cell.avatarImageView.image = image;
            else
                cell.avatarImageView.image = [UIImage imageNamed:@"user_stub"];
        }];
    }
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_usersArray count];
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowProfile object:[_usersArray objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {//Last Row Will Display
        if (_isLoading) {
            return;
        }
        
        if (!_isEnd) {
            [self reloadTable];
        }
    }
}

- (void)reloadTable
{
    if (!_isLoading ) {
        [self findUsersInGroupWithOffset:[_usersArray count]];
    }
}
- (void) findUsersInGroupWithOffset:(int)index
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil)
                                           message:nil];
    
    [[DatabaseManager defaultManager] findUserListByGroupID:_group._id
                                                      count:PagingUserFetchNum offset:index
                                                    success:^(NSArray *result, NSInteger totalResults) {
                                                        [[AlertViewManager defaultManager] dismiss];
                                                        if (result) {
                                                            [_usersArray addObjectsFromArray:result];
                                                            [_tableViewUsers reloadData];
                                                            if (index + PagingUserFetchNum >= totalResults) {
                                                                _isEnd = TRUE;
                                                            }
                                                        }
                                                        _isLoading = FALSE;
                                                    } error:^(NSString *errorString) {
                                                        _isLoading = FALSE;
                                                        [[AlertViewManager defaultManager] dismiss];
                                                    }];
}
@end
