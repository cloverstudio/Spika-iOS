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

#import "HUBaseViewController.h"
#import "HUSearchBarModel.h"
#import "HUSearchBarCellView.h"

@protocol HUSearchBarDelegate, HUSearchBarDatasource;

@interface HUSearchBarController : HUBaseViewController <UITextFieldDelegate>
@property (nonatomic, weak) id<HUSearchBarDatasource> datasource;
@property (nonatomic, weak) id<HUSearchBarDelegate> delegate;
@end

@protocol HUSearchBarDatasource <NSObject>

@required
-(NSString *) headerTextForSearchBar:(HUSearchBarController *)searchBar;
-(NSUInteger) numberOfRowsForSearchBar:(HUSearchBarController *)searchBar;
-(HUSearchBarModel *) searchBar:(HUSearchBarController *)searchBar modelForRow:(NSUInteger)row;

@optional
-(UIColor *) backgroundColorForSearchBar:(HUSearchBarController *)searchBar;

@end

@protocol HUSearchBarDelegate <NSObject>

-(void) searchBar:(HUSearchBarController *)searchBar searchWithParameters:(NSDictionary *)parameters;

@end
