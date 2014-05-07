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

#import "HUSideMenuViewController.h"
#import "HUSideMenuViewController+Style.h"
#import "HUCounterBalloonView.h"
#import "MAKVONotificationCenter.h"
#import "DatabaseManager.h"
#import "CSGraphics.h"
#import "Utils.h"

@interface HUSideMenuViewController ()
@property (nonatomic, strong) HUCounterBalloonView *counterView;
@property (nonatomic, strong) UITableView *settingsTableView;
@end

@implementation HUSideMenuViewController

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        
        _items = [self newTableItems];
        [self setupFrame];
    }
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self.settingsTableView reloadData];
    }
}



#pragma mark - View lifecycle

-(void) setupFrame {
    self.view.width = 267;
    self.view.x = -self.view.width;
}

-(void) loadView {
    
    [super loadView];
    
    self.settingsTableView = (UITableView *)self.view;
    self.settingsTableView.backgroundColor = [UIColor clearColor];
    
    [self.view removeFromSuperview];
    
    self.view = [[UIView alloc] initWithFrame:_settingsTableView.bounds];
    self.view.clipsToBounds = YES;
    self.view.height = [Utils getDisplayHeight];
    
    UINavigationBar *navigationBar = [HUSideMenuViewController newNavigationBarWithTitle:NSLocalizedString(@"MAIN MENU", nil)];
    [self.view addSubview:navigationBar];
    
    _settingsTableView.y = navigationBar.relativeHeight;
    [self.view addSubview:_settingsTableView];
    
    self.counterView = [HUCounterBalloonView counterView];
	
	void(^observerBlock)(MAKVONotification *notification) = ^(MAKVONotification *notification) {
		DatabaseManager *manager = [notification target];
		self.counterView.count = manager.recentActivity.numberOfTotalActivities;
	};
	
	[[MAKVONotificationCenter defaultCenter] addObserver:self
												  object:[DatabaseManager defaultManager]
												 keyPath:@"recentActivity"
												 options:0
												   block:observerBlock];

    UISwipeGestureRecognizer *oneFingerSwipeUp =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToHideMenu)];
    [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:oneFingerSwipeUp];

}


- (void) swipeToHideMenu{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTuggleSideMenu object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setSettingsViewStyle];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

}

// Add this Method
- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override

#pragma mark - Selector

-(void) notificationHeaderDidTap:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state==UIGestureRecognizerStateEnded){
        CGPoint point = [recognizer locationInView:self.tableView];
        
        if(point.y < 34){
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowRecentActivity object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideSideMenu object:nil];
        }        
    }
}

#pragma mark - Button Selectors

#pragma mark - Notification selectors

#pragma mark - Animation

#pragma mark - Setter

#pragma mark - Getter

-(UITableView *) tableView {
    return self.settingsTableView;
}

#pragma mark - Datasource

-(id) objectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *array = [self.items objectAtKeyIndex:indexPath.section];
    
    return [array objectAtIndex:indexPath.row];
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.items allKeys].count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.items objectAtKeyIndex:section] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForTableViewAtIndexPath:indexPath];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.heightForTableViewHeader;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ReuseIdentifier";
    
    HUSettingsViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[HUSettingsViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSettingsViewStyle];
        
        cell.imageView.image = [self imageForTableViewCellAtIndexPath:indexPath];
        cell.textLabel.text = [self objectAtIndexPath:indexPath];
    }
    
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *headerText = [self.items keyAtIndex:section];
    
    UIView *view = [self viewForTableViewHeaderWithText:headerText];
    view.autoresizesSubviews = NO;
    
    if (section == 0) {
        self.counterView.center = view.center;
        self.counterView.x = 190;
        [view addSubview:self.counterView];
    }
    
    [view addTapGestureRecognizerWithTarget:self selector:@selector(notificationHeaderDidTap:)];
    
    return view;
    
}

#pragma mark - Delegate

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section == 0) ? NO : YES;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if (indexPath.section == 0) {
		[self notificationHeaderDidTap:nil];
        return;
    }
    
    if(indexPath.row == 0){
        [center postNotificationName:NotificationSideMenuUsersSelected object:nil];
    }
    
    if(indexPath.row == 1){
        [center postNotificationName:NotificationSideMenuGroupsSelected object:nil];
    }
    
    if(indexPath.row == 2){
        [center postNotificationName:NotificationSideMenuMyProfileSelected object:nil];
    }
    
	if(indexPath.row == 3){
		[center postNotificationName:NotificationShowInformation object:nil];
	}
    
	if(indexPath.row == 4){
		[center postNotificationName:NotificationShowSettings object:nil];
	}
	
    if(indexPath.row == 5){
        [center postNotificationName:NotificationSideMenuPersonalWallSelected object:nil];
    }
    
    if(indexPath.row == 6){

        HUDialog *dialog = [[HUDialog alloc] initWithText:NSLocalizedString(@"Confirm Logout", nil)
                                                 delegate:self
                                              cancelTitle:NSLocalizedString(@"NO", nil)
                                               otherTitle:[NSArray arrayWithObjects:NSLocalizedString(@"YES", nil),nil]];
        [dialog show];
        
    }
    
    [center postNotificationName:NotificationHideSideMenu object:nil];

}

-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index{
    
    if(index == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuLogoutSelected object:nil];
    }
}

-(void) dialogDidPressCancel:(HUDialog *)dialog {

}

@end
