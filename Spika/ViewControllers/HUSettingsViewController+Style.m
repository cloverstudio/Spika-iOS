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

#import "HUSettingsViewController+Style.h"
#import "HUBaseViewController+Style.h"
#import "AlertViewManager.h"
#import "DatabaseManager.h"
#import "UILabel+Extensions.h"
#import "CSToast.h"
#import "CSGraphics.h"
#import "RCSwitchOnOff.h"
#import "HUPasswordChangeDialog.h"

static CGFloat xOffset = 20;

@interface _ContentView : UIView

@end

@implementation _ContentView

-(void) layoutSubviews {
	
	[super layoutSubviews];
	for (UIView *view in self.subviews) {
		view.center = CGPointMake(view.center.x, CGRectGetCenter(self.bounds).y);
	}
	
}

@end

@implementation HUSettingsViewController (Style)

-(NSString *) headerTitleInSection:(NSInteger)section {
	
	NSString *title = nil;
	switch (section) {
		case 1:
			title = NSLocalizedString(@"API ENDPOINT", nil);
			break;
		case 0:
			title = NSLocalizedString(@"PASSCODE PROTECT", nil);
			break;
		default:
			title = @"";
			break;
	}
	
	return title;
}

-(UIView *) headerForSection:(NSInteger)section {
	
	_ContentView *contentView = [[_ContentView alloc] initWithFrame:CGRectMakeBounds(self.view.width, 0)];
	
	UILabel *label = [UILabel labelWithText:[self headerTitleInSection:section]];
	label.textColor = [UIColor colorWithIntegralRed:54 green:54 blue:54];
	label.width = self.view.width;
	label.x = xOffset;
	
	[contentView addSubview:label];
	
	if (section == 0) {
		
		BOOL hasPassword = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword];
		
		RCSwitch *aSwitch = [self newSwitchWithSelector:@selector(passwordActiveDidChangeValue:)];
		aSwitch.center = CGRectGetCenter(contentView.bounds);
		aSwitch.x = contentView.width - aSwitch.width - xOffset;
		[aSwitch setOn:hasPassword animated:NO];
		self.passwordSwitch = aSwitch;
		
		[contentView addSubview:aSwitch];
	}
	
	return contentView;
}

-(void) provideCellContent:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

    
    if (indexPath.row == 0) {
        
        UILabel *passwordLabel  = [UILabel labelWithText:NSLocalizedString(@"PASSWORD",nil)];
        passwordLabel.textColor = [UIColor colorWithIntegralRed:54 green:54 blue:54];
        passwordLabel.width = 100;
        passwordLabel.y = 10;
        passwordLabel.x = xOffset;
        [cell addSubview:passwordLabel];
        
        UIButton *button = [HUBaseViewController buttonWithTitle:NSLocalizedString(@"Change Password",nil)
                                                           frame:CGRectMakeBounds(168, 38)
                                                 backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
                                                          target:self
                                                        selector:@selector(changePassword)];
        button.layer.cornerRadius = button.height * 0.5f;
        button.x = 140;
        button.y = 0;
        [cell addSubview:button];
        
        
    }
    
    
    if (indexPath.row == 1) {
        
        _ContentView *contentView = [[_ContentView alloc] initWithFrame:CGRectMakeBounds(self.view.width, 50)];
        
        UILabel *label = [UILabel labelWithText:NSLocalizedString(@"PASSCODE PROTECT", nil)];
        
        label.textColor = [UIColor colorWithIntegralRed:54 green:54 blue:54];
        label.width = self.view.width;
        label.x = xOffset;
        
        [contentView addSubview:label];
        
        BOOL hasPassword = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultPassword];
        
        RCSwitch *aSwitch = [self newSwitchWithSelector:@selector(passwordActiveDidChangeValue:)];
        aSwitch.center = CGRectGetCenter(contentView.bounds);
        aSwitch.x = contentView.width - aSwitch.width - xOffset;
        [aSwitch setOn:hasPassword animated:NO];
        self.passwordSwitch = aSwitch;
        
        [contentView addSubview:aSwitch];
        
        [cell addSubview:contentView];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
}


-(RCSwitch *) newSwitchWithSelector:(SEL)aSelector {
	
	RCSwitchOnOff *aSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMakeBounds(75, 27)];
	aSwitch.offsetAdjustment = CGPointMake(-3.0f, -1.0f);
	[aSwitch addTarget:self action:aSelector forControlEvents:UIControlEventValueChanged];
	
	return aSwitch;
}

-(UIButton *) newClearCacheButtonWithSelector:(SEL)aSelector {
	
	NSString *title = NSLocalizedString(@"CLEAR CACHE", nil);
	UIButton *button = [HUBaseViewController buttonWithTitle:title
													   frame:CGRectMakeBounds(168, 38)
											 backgroundColor:[HUBaseViewController colorWithSharedColorType:HUSharedColorTypeRed]
													  target:self
													selector:aSelector];
	button.layer.cornerRadius = button.height * 0.5f;
	
	return button;
}

-(UIView *) newEnterPasswordField {
	return nil;
}

#pragma mark - UITextFieldDelegate

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([string isEqualToString:@"\n"]) {
		
		[textField resignFirstResponder];
		
		return NO;
	}
	
	return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
	
	[self apiEndpointDidChange:textField];
}

@end
