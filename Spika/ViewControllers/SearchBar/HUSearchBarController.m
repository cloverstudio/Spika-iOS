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

#import "HUSearchBarController.h"
#import "HUSearchBarController+Style.h"
#import "CSGraphics.h"

@interface HUSearchBarController ()
@property (nonatomic, strong) NSMutableArray *modelArray;
@end

@implementation HUSearchBarController

#pragma mark - Dealloc

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.modelArray = [NSMutableArray new];
    }
    return self;
}

#pragma mark - View lifecycle

-(void) loadView {
    
    [super loadView];
    
    CGSize winSize = [CSKit frame].size;
    
    NSString *headerText = [self.datasource headerTextForSearchBar:self];
    
    UIView *headerView = [self headerViewForText:headerText];
    headerView.y = 5;
    headerView.x = (winSize.width - [[self class] frameForTextBoxContainerView].size.width) / 2;
    [self.view addSubview:headerView];
    
    NSUInteger count = [self.datasource numberOfRowsForSearchBar:self];

    [self.modelArray removeAllObjects];
    
    for (int i = 0; i < count; i++) {
        
        HUSearchBarModel *model = [self.datasource searchBar:self modelForRow:i];
        
        UIView *view = [self viewForModel:model];
        view.y = self.view.topSubview.relativeHeight + 2;
        view.x = self.view.topSubview.x;
        [self.view addSubview:view];
        
        [self.modelArray addObject:model];
    }
    
    UIButton *searchButton = [self searchButtonWithSelector:@selector(searchButtonDidPress:)];
    searchButton.center = self.view.center;
    searchButton.y = self.view.topSubview.relativeHeight + 5;
    [self.view addSubview:searchButton];
        
    self.view.frame = CGRectMakeBounds(winSize.width, self.view.topSubview.relativeHeight + 5);
    self.view.backgroundColor = [self.datasource backgroundColorForSearchBar:self];
    
    UIImageView *shadowView = [CSKit imageViewWithImageNamed:@"hp_wall_tableview_bottom_shadow.png"];
    shadowView.width = self.view.width;
    shadowView.y = self.view.height - shadowView.height;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:shadowView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

-(void) searchButtonDidPress:(UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(searchBar:searchWithParameters:)]) {
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        for (HUSearchBarModel *model in self.modelArray) {
            [params setObject:model.callback() forKey:model.text];
        }
        
        [self.delegate searchBar:self searchWithParameters:params];
        
    }
    
}

@end
