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

#import "HURecentActivityViewController.h"
#import "HURecentActivityViewController+Style.h"
#import "DatabaseManager.h"
#import "HUActivityMessageCell.h"
#import "HUAvatarManager.h"
#import "MAKVONotificationCenter.h"

@interface HURecentActivityViewController ()

@end

@implementation HURecentActivityViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Recent activity", nil);
		
		void(^observerBlock)(MAKVONotification *notification) = ^(MAKVONotification *notification) {
			DatabaseManager *manager = [notification target];
			[[notification observer] updateDataWithNewRecentActivity:manager.recentActivity];
		};
		
		[[MAKVONotificationCenter defaultCenter] addObserver:self
													  object:[DatabaseManager defaultManager]
													 keyPath:@"recentActivity"
													 options:0
													   block:observerBlock];
    }
    return self;
}

-(void) updateDataWithNewRecentActivity:(ModelRecentActivity *)recentActivity {
	

	self.activity = recentActivity;
    

	[self.tableView reloadData];
	
	//[self.tableView endUpdates];
}

+(HURecentActivityViewController *) newRecentActivityViewController {
	
	HURecentActivityViewController *viewController = [HURecentActivityViewController new];
	viewController.activity = [DatabaseManager defaultManager].recentActivity;
	
	return viewController;
}

#pragma mark - View lifecycle

-(void) loadView {
	
	[super loadView];
	
    [self addSlideButtonItem];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _noItemsLabel = [self noItemsLabel];
	[self.view addSubview:_noItemsLabel];
    
    _noItemsLabel.hidden = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self showTutorialIfCan:NSLocalizedString(@"tutorial-recent",nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource

-(HUModelActivityCategory *) categoryForIndexPath:(NSIndexPath *)indexPath {
	return [self categoryForSection:indexPath.section];
}

-(HUModelActivityCategory *) categoryForSection:(NSInteger)section {
	return self.activity.categories[section];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    if(self.activity.categories.count == 0){
        _noItemsLabel.hidden = NO;
    }else{
        _noItemsLabel.hidden = YES;
    }
    
	return self.activity.categories.count;
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	HUModelActivityCategory *category = [self categoryForSection:section];
	return category.notifications.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return [HUActivityMessageCell cellHeightForMessage:nil];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	HUModelActivityCategory *category = [self categoryForIndexPath:indexPath];
	HUModelActivityNotification *notification = category.notifications[indexPath.row];
	ModelMessage *message = notification.messages.lastObject;
	
	NSString *cellIdentifier = @"CellIdentifier";
	NSString *tableViewClassName = @"HUActivityMessageCell";
	HUActivityMessageCell *cell = (HUActivityMessageCell *)[CSKit tableViewCellCustom:cellIdentifier
																			className:tableViewClassName
																			tableView:tableView];
	
	cell.textLabel.text = message.body;
	cell.counterView.count = notification.count;
	

	cell.avatarIconView.image = [UIImage imageNamed:@"user_stub"];
	[HUAvatarManager avatarImageForId:message.from_user_id atIndexPath:indexPath width:kListViewBigWidth completionHandler:^(UIImage *image, NSIndexPath *indexPath) {
		cell.avatarIconView.image = image;
	}];
	
	return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	HUModelActivityCategory *category = [self categoryForSection:section];
	return [self newTableHeaderViewWithTitle:NSLocalizedString([category.name uppercaseString], nil)];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return [[self class] heightForHeaderView];
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	HUModelActivityCategory *category = [self categoryForIndexPath:indexPath];
	//ModelMessage *message = category.allMessages[indexPath.row];
	HUModelActivityNotification *note = category.notifications[indexPath.row];
	
    if([note.category.targetType isEqualToString:@"group"]){
        [HUAvatarManager findModelForModelId:note.targetId forClasses:@[@"ModelGroup"].mutableCopy completion:^(id<HUAvatarModel> model) {
            
            NSString *notificationName = [model isKindOfClass:[ModelGroup class]] ? NotificationShowGroupWall : NotificationShowUserWall;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:model];
            
        }];
    }else{
        [HUAvatarManager findModelForModelId:note.targetId forClasses:@[@"ModelUser"].mutableCopy completion:^(id<HUAvatarModel> model) {
            
            NSString *notificationName = [model isKindOfClass:[ModelGroup class]] ? NotificationShowGroupWall : NotificationShowUserWall;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:model];
            
        }];
    }
    

}

@end
