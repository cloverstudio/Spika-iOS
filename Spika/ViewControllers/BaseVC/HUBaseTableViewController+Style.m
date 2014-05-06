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

#import "HUBaseTableViewController+Style.h"

@implementation HUBaseTableViewController (Style)

#pragma mark - UIViews

- (UIView *) loadingView {
    
    UIView *view = [CSKit viewWithFrame:[self frameForLoadingView]];
    view.autoresizingMask = self.view.autoresizingMask;
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *) noItemsView {
    
    UIView *view = [CSKit viewWithFrame:[self frameForNoItemsView]];
    view.autoresizingMask = self.view.autoresizingMask;
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - UITableView

- (UITableView *) contentTableView {

    UITableView *tableView = [[UITableView alloc] initWithFrame:[self frameForTableView]
                                                          style:self.tableViewStyle];
    tableView.autoresizingMask = self.view.autoresizingMask;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}

#pragma mark - UILabels

- (UILabel *) loadingLabel {
    
    UILabel *label = [CSKit labelWithFrame:[self frameForLoadingLabel]
                                      font:[self fontForViewStateLabels]
                                 textColor:[self colorForViewStateLabels]
                             textAlignment:NSTextAlignmentCenter
                                      text:nil];
    return label;
}

- (UILabel *) noItemsLabel {
    
    UILabel *label = [CSKit labelWithFrame:[self frameForNoItemsLabel]
                                      font:[self fontForViewStateLabels]
                                 textColor:[self colorForViewStateLabels]
                             textAlignment:NSTextAlignmentCenter
                                      text:nil];
    return label;
}

#pragma mark - UIActivityIndicatorView

- (UIActivityIndicatorView *) loadingIndicatorView {
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = [self centerForLoadingIndicatorView];
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [indicatorView startAnimating];
    
    return indicatorView;
}

#pragma mark - Frames

- (CGRect) frameForTableView {
    
    return self.view.bounds;
}

- (CGRect) frameForLoadingView {
    
    return self.view.bounds;
}
- (CGRect) frameForNoItemsView {
    
    return self.view.bounds;
}

- (CGPoint) centerForLoadingIndicatorView {
    
    return self.view.center;
}

- (CGRect) frameForLoadingLabel {
    
    CGPoint loadingIndicatorViewCenter = [self centerForLoadingIndicatorView];
    
    CGRect  loadingViewFrame = [self frameForLoadingView];
    
    return CGRectMake(0,
                      loadingIndicatorViewCenter.y + 20,
                      CGRectGetWidth(loadingViewFrame),
                      20);
}

- (CGRect) frameForNoItemsLabel {
    
    CGRect noItemsViewFrame = [self frameForNoItemsView];
    return CGRectMake(0,
                      CGRectGetMidY(noItemsViewFrame) - 10,
                      CGRectGetWidth(noItemsViewFrame),
                      20);
}


#pragma mark - Colors

- (UIColor *) colorForViewStateLabels {
    
    return [UIColor blackColor];
}

#pragma mark - Fonts

- (UIFont *) fontForViewStateLabels {
    
    return kFontArialMTBoldOfSize(kFontSizeMiddium);
}

@end
