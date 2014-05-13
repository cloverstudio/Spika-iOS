//
//  HUServerListViewController.m
//  Spika
//
//  Created by Josip Marković on 27.03.2014..
//
//

#import "HUServerListViewController.h"
#import "HUServerListCell.h"
#import "DatabaseManager.h"
#import "ModelServer.h"
#import "AlertViewManager.h"
#import "HUHTTPClient.h"

@interface HUServerListViewController ()

@end

@implementation HUServerListViewController {
    NSMutableArray *serverList;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *color = [UIColor grayColor];
    self.addServerText.attributedPlaceholder = [[NSAttributedString alloc]
                                                initWithString: NSLocalizedString(@"AddServerHint", @"")
                                                attributes:@{NSForegroundColorAttributeName: color}];
    
    serverList = [NSMutableArray array];
    DMArrayBlock successBlock = ^(NSArray *servers) {
        for (NSDictionary *dictionary in servers) {
            ModelServer *server = [[ModelServer alloc] initWithDictionary:dictionary];
            [serverList addObject:server];
        }
        
        [self.tableViewServerList reloadData];
        [[AlertViewManager defaultManager] dismiss];
    };
    
    [[AlertViewManager defaultManager] showWaiting:@"" message:@""];
    [[DatabaseManager defaultManager] getServerListWithSuccess:successBlock andError:nil];}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self addBackButton];
    
    self.addServerText.placeholder = NSLocalizedString(@"AddServerHint", @"");

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelServer *server = [serverList objectAtIndex:indexPath.row];
    static NSString *serverListCellIdentifier = @"serverListCell";
    HUServerListCell *cell = (HUServerListCell *)[tableView dequeueReusableCellWithIdentifier:serverListCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HUServerListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.serverLabel.text = server.name;
    cell.serverUrl.text = server.url;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelServer *server = [serverList objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:server.url forKey:serverBaseURLprefered];
    [[NSUserDefaults standardUserDefaults] setObject:server.name forKey:serverBaseNamePrefered];
    [HUHTTPClient refreshClient];
    
    NSString *selected = server.name;
    [self.delegate addItemViewController:self didFinishEnteringItem:selected];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return serverList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

#pragma mark - Override

- (NSString *) title {
    return NSLocalizedString(@"ServerList-Title", @"");
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *selected = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:selected forKey:serverBaseURLprefered];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:serverBaseNamePrefered];
    [HUHTTPClient refreshClient];

    [self.delegate addItemViewController:self didFinishEnteringItem:selected];
    return NO;
}

@end
