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

#import "HUSubMenuViewController.h"
#import "HUMenuNavigationItem.h"
#import "HUSideMenuViewController+Style.h"

@interface HUSubMenuViewController ()

@end

@implementation HUSubMenuViewController

-(id) init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"items" options:0 context:NULL];
    }
    return self;
}

- (void) loadView{
    [super loadView];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToHideSubMenu)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:oneFingerSwipeRight];
    
}

- (void) swipeToHideSubMenu{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTuggleSubMenu object:nil];
}


-(OrderedDictionary*) newTableItems {
    return nil;
}

-(void) setShadow {
    
}

-(void) setupFrame {
    self.view.width = 267;
    self.view.x = CSKit.frame.size.width;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ReuseIdentifier";
    
    HUSettingsViewTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    HUMenuNavigationItem *item = [self.items objectAtKeyIndex:indexPath.section][indexPath.row];
    if (cell == nil) {
        
        cell = [[HUSettingsViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSettingsViewStyle];
    }

    cell.imageView.image = [UIImage imageNamed:item.imageName];
    cell.textLabel.text = item.name;
    return cell;
}

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HUMenuNavigationItem *item = [self.items objectAtKeyIndex:indexPath.section][indexPath.row];
    [item trigger];
}

@end
