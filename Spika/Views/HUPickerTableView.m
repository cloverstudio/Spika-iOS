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

#import "HUPickerTableView.h"

@implementation HUPickerTableView

+(HUPickerTableView *)pickerTableViewFor:(id<UITableViewDataSource, UITableViewDelegate>)viewController
{
	HUPickerTableView *pickerTableView = [[HUPickerTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	pickerTableView.delegate = viewController;
	pickerTableView.dataSource = viewController;
	return pickerTableView;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    
    if (self = [super initWithFrame:frame style:style])
	{
        
		[self addObserver:self
               forKeyPath:@"dataSourceArray"
                  options:0
                  context:NULL];
         
        
    }
    return self;
}

-(void)dealloc
{
	[self removeObserver:self
              forKeyPath:@"dataSourceArray"];
}

-(void)setFrame:(CGRect)frame
{
	UIView *shadowView = self.superview;
	shadowView.frame = frame;
	
	[super setFrame:shadowView.bounds];
}

-(void)setCenter:(CGPoint)center
{
	UIView *shadowView = self.superview;
	shadowView.center = center;
}

-(void)showPickerTableViewInView:(UIView *)view pickerDataType:(HUPickerTableViewDataType)dataType
{
	if (_holderView == nil)
	{
		UIView *holderView = [[UIView alloc] initWithFrame:view.bounds];
		holderView.backgroundColor = [UIColor blackColor];
		holderView.alpha = 1.0;
		
		UIView *shadowView = [[UIView alloc] init];
		shadowView.layer.masksToBounds = NO;
		shadowView.layer.shadowRadius = 10;
		shadowView.layer.shadowOpacity = 0.8;
		
		[shadowView addSubview:self];
		[holderView addSubview:shadowView];
		[view addSubview:holderView];
		
		_holderView = holderView;
	} else
		_holderView.hidden = NO;
	
	self.pickerDataType = dataType;
}

-(void)removePickerTableView
{
	if (_holderView != nil)
		_holderView.hidden = YES;
	
	if (_holderView != nil) {
		[_holderView removeFromSuperview];
		_holderView = nil;
	}
	self.delegate = nil;
	self.dataSource = nil;
	[self removeFromSuperview];
}

#pragma mark - Observing

-(void)observeValueForKeyPath:(NSString *)keyPath
					 ofObject:(id)object
					   change:(NSDictionary *)change
					  context:(void *)context
{
    if ([keyPath isEqualToString:@"dataSourceArray"])
	{
        [self reloadData];
    }
}

@end
