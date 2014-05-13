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

}

@property (strong, nonatomic, readwrite) NSString *groupID;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (assign, nonatomic) NSInteger totalUsers;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation HUUsersInGroupViewController

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Members", nil);
        self.usersArray = [NSMutableArray array];
        _isLoading = NO;
    }
    return self;
}
- (id)initWithGroupID:(NSString *)groupID {
    self = [self initWithNibName:@"HUUsersInGroupViewController" bundle:nil];
    if (self) {
        self.groupID = groupID;
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    //Load user list if users array is empty
    if (self.usersArray.count == 0) {
        [self findUsersInGroupWithOffset:0];
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
        if (self.usersArray.count < self.totalUsers) {
            [self loadMoreUsers];
        }
    }
}

- (void)loadMoreUsers
{
    if (!self.isLoading) {
        [self findUsersInGroupWithOffset:[self.usersArray count]];
    }
}
- (void) findUsersInGroupWithOffset:(int)index
{
    self.isLoading = YES;
    [[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Loading", nil)
                                           message:nil];
    
    [[DatabaseManager defaultManager] findUserListByGroupID:self.groupID
                                                      count:PagingUserFetchNum offset:index
                                                    success:^(NSArray *result, NSInteger totalResults) {
                                                        [[AlertViewManager defaultManager] dismiss];
                                                        if (result) {
                                                            self.totalUsers = totalResults;
                                                            [self.usersArray addObjectsFromArray:result];
                                                            [self.tableViewUsers reloadData];
                                                        }
                                                        self.isLoading = FALSE;
                                                    } error:^(NSString *errorString) {
                                                        self.isLoading = FALSE;
                                                        [[AlertViewManager defaultManager] dismiss];
                                                    }];
}
@end
