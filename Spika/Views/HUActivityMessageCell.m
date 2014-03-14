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

#import "HUActivityMessageCell.h"
#import "HUActivityMessageCell+Style.h"
#import "HUCounterBalloonView.h"
#import "CSGraphics.h"
#import "UIImage+Aditions.h"
#import "HUSelectedTableViewCellVew.h"
#import "Utils.h"

@implementation HUActivityMessageCell {
	UIView *_backgroundView;
	UILabel *_textLabel;
	UIImageView *_arrowView;
    UILabel *_dateLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		_backgroundView = [self newBackgroundView];
		[self.contentView addSubview:_backgroundView];
		
		_textLabel = [self newTextLabel];
		[self.contentView addSubview:_textLabel];
		
		_dateLabel = [self newDateLabel];
		[self.contentView addSubview:_dateLabel];
		
		_counterView = [HUCounterBalloonView counterView];
		[self.contentView addSubview:_counterView];
		
		_arrowView = [CSKit imageViewWithImageNamed:@"hu_right_arrow"];
		[self.contentView addSubview:_arrowView];

        self.selectedBackgroundView = [[HUSelectedTableViewCellVew alloc] initWithFrame:self.frame withHeight:[HUActivityMessageCell cellHeightForMessage:nil]];
    
		[self.contentView bringSubviewToFront:self.avatarIconView];
        
    }
    return self;
}

-(void) layoutSubviews {
	
	//[super layoutSubviews];
	CGRect frame = CGRectMakeBounds(self.contentView.width, [MessageCell cellHeightForMessage:nil]);
	self.contentView.frame = frame;
	
	_backgroundView.frame = CGRectContract(self.contentView.bounds, 2);
	
	CGRect innerFrame = CGRectContract(_backgroundView.frame, 2);
	self.avatarIconView.position = innerFrame.origin;
	
	_arrowView.center = self.contentView.center;
	_arrowView.x = _backgroundView.relativeWidth - _arrowView.width - 4;
	
	_counterView.center = CGPointShiftLeft(_arrowView.center, _counterView.width);
	
	BOOL hasCount = _counterView.count > 0;
	_counterView.hidden = !hasCount;
	
	CGFloat endX = hasCount ? _counterView.x : _arrowView.x;
	
	CGRect labelFrame = innerFrame;
	labelFrame.origin.x = self.avatarIconView.relativeWidth + 4;
	labelFrame.size.width = endX - labelFrame.origin.x;
	_textLabel.frame = labelFrame;
	
    _dateLabel.frame = CGRectMake(
            _textLabel.frame.origin.x,
            self.height - 25,
            _textLabel.frame.size.width,
            25
    );
    
    
}

-(UILabel *)textLabel {
	
	return _textLabel;
}

-(UILabel *)timestampLabel {
	
	return _dateLabel;
}

+(BOOL) isArrowHidden {
	return YES;
}

+(BOOL) isTimestampHidden {
	return YES;
}

+(CGFloat) cellHeightForMessage:(ModelMessage *)message {
	return CGRectGetMaxY([MessageCell frameForAvatarIconView:message]) + 4;
}

@end
