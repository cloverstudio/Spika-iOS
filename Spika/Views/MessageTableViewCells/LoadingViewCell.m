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

#import "LoadingViewCell.h"
#import "StrManager.h"
#import "StyleManupulator.h"

#define LeftPadding 100

@implementation LoadingViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void) buildViews{
    
    [self.contentView removeFromSuperview];
    [self.selectedBackgroundView removeFromSuperview];
    [self.imageView removeFromSuperview];
    [self.detailTextLabel removeFromSuperview];
    [self.textLabel removeFromSuperview];
    
    _bgView = [[UIView alloc] init];
    _bgView.frame = CGRectMake(
        0,
        0,
        self.frame.size.width,
        self.frame.size.height - 10
    );
    
    [StyleManupulator attachLoadingRowStyle:_bgView];
    [self addSubview:_bgView];
    
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.frame = CGRectMake(
        LeftPadding + 25,
        0,
        _bgView.frame.size.width - LeftPadding - 25,
        _bgView.frame.size.height
    );
    
    loadingLabel.text = [StrManager _:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"Loading", nil)]];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor lightGrayColor];
    
    [_bgView addSubview:loadingLabel];
    
    UIActivityIndicatorView  *ai =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    ai.center = CGPointMake(LeftPadding,_bgView.frame.size.height / 2);
    [ai startAnimating];
    
    [_bgView addSubview:ai];

}

-(void)hide{
    _bgView.alpha = 0.0;
}

-(void)show{
    _bgView.alpha = 1.0;
    
}

@end
