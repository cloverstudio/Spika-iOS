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

#import "HUPasswordDisplayView.h"
#import "HUPasswordDisplayView+Style.h"
#import "HUBaseViewController+Style.h"
#import "CSNotificationView.h"
#import "CSGraphics.h"

@interface HUPasswordDisplayView ()
@property (nonatomic, strong) UIView *contentView;
@end

@implementation HUPasswordDisplayView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		self.contentView = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:_contentView];
		
		UIButton *deleteButton = [self newDeleteButtonWithSelector:@selector(deleteButtonDidPress:)];
		
		CGFloat heightFactor = deleteButton.height / self.height;
		deleteButton.height = _contentView.height;
		deleteButton.width = floorf(deleteButton.width / heightFactor);
		deleteButton.x = self.width - deleteButton.width;
		[self addSubview:deleteButton];
    }
    return self;
}

#pragma mark - Layout

-(void) layoutSubviews {
	
	[self.contentView removeAllSubviews];
	_contentView.width = self.width;
	
	NSInteger totalNumber = [_datasource totalNumberOfDigitsForDisplayView:self];
	
	CGFloat height = self.height;
	for (int i = 0; i < totalNumber; i++) {
		UIView *circle = [self newCircle];
		circle.x = i * height;
		circle.frame = CGRectContract(circle.frame, 4);
		[_contentView addSubview:circle];
		_contentView.width = circle.relativeWidth;
	}
	
	_contentView.center = CGPointMake(self.width * .5f, _contentView.center.y);
	
	int j = 0;
	NSInteger currentNumberOfDigits = [_datasource currentNumberOfDigitsForDisplayView:self];
	for (UIView *view in _contentView.subviews) {
		
		HUSharedColorType type = j < currentNumberOfDigits ? HUSharedColorTypeRed : HUSharedColorTypeGray;
		view.backgroundColor = [HUBaseViewController colorWithSharedColorType:type];
		j++;
	}

}

#pragma mark - Selector

-(void) deleteButtonDidPress:(id)sender {
	
	if ([self.delegate respondsToSelector:@selector(displayViewDidPressDeleteButton:)]) {
		[self.delegate displayViewDidPressDeleteButton:self];
	}
	
}

#pragma mark - Construction

static CGFloat roundRadius = 18.0f;

-(UIView *) newCircle {
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeBounds(self.height, self.height)];
	view.layer.cornerRadius = roundRadius;
	
	return view;
}

#pragma mark - Notification effect

-(void) showResult:(BOOL)isSuccess {
	
	UILabel *resultView = [[UILabel alloc] initWithFrame:self.bounds];
	resultView.textAlignment = NSTextAlignmentCenter;
	resultView.textColor = [UIColor whiteColor];
	resultView.font = kFontArialMTBoldOfSize(kFontSizeBig);
	
	NSString *resultText = isSuccess ? @"SUCCESS" : @"FAIL";
	resultView.text = NSLocalizedString(resultText, nil);
	
	HUSharedColorType type = isSuccess ? HUSharedColorTypeGreen : HUSharedColorTypeRed;
	resultView.backgroundColor = [HUBaseViewController colorWithSharedColorType:type];
	
	CSNotificationView *note = [CSNotificationView notificationWithView:resultView];
	note.anchorPointZ = 12;
	[self showNotification:note];
    
	if (!isSuccess) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self hideNotification];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.animationFinishedCallback) { self.animationFinishedCallback(); }
            });
        });
	}
}

@end
