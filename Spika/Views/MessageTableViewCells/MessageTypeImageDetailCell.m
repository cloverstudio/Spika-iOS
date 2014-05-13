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

#import "MessageTypeImageDetailCell.h"
#import "MessageTypeImageDetailCell+Style.h"
#import "HUImageView.h"

#define kImageViewWidth 290
#define kReportHeight 20

@interface MessageTypeImageDetailCell (){
    ModelMessage *_message;
    UILabel *reportViolationBtn;
}
@property (nonatomic, strong) HUImageView *photoView;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation MessageTypeImageDetailCell
@synthesize containerView = _containerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        _containerView = [self newContainerView];
        
        [self.contentView addSubview:_containerView];
        
        _photoView = [[HUImageView alloc] initWithFrame:CGRectMake(5, 5, kImageViewWidth, 220)];
        _photoView.userInteractionEnabled = YES;
        [_containerView addSubview:_photoView];
        
        reportViolationBtn = [[UILabel alloc] init];
        reportViolationBtn.text = NSLocalizedString(@"ReportViolation", nil);
        reportViolationBtn.font = kFontArialMTOfSize(10);
        reportViolationBtn.textAlignment = NSTextAlignmentRight;
        reportViolationBtn.textColor = kHUColorLightGray;
        reportViolationBtn.userInteractionEnabled = YES;
        reportViolationBtn.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(report)];
        [reportViolationBtn addGestureRecognizer:tap];
        
        [self.containerView addSubview:reportViolationBtn];
        
        [self.contentView bringSubviewToFront:self.avatarIconView];
        [self.contentView bringSubviewToFront:self.timestampLabel];
    }
    return self;
}

-(void) layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize rawSize = _photoView.image.size;
    CGFloat factor = kImageViewWidth / rawSize.width;
    CGSize imageSize = CGSizeMake(rawSize.width * factor, rawSize.height * factor);
    
    _containerView.height = self.height;
    _photoView.height = imageSize.height;
    
    self.avatarIconView.y = _containerView.height - self.avatarIconView.height - 15;
    
    self.timestampLabel.frame = CGRectMake(
                                          _photoView.x + 10,
                                          _photoView.y + _photoView.height + 7,
                                          _photoView.width,
                                          20
                                          );
    
    self.timestampLabel.backgroundColor = [UIColor clearColor];
    
    reportViolationBtn.frame = CGRectMake(
        _photoView.x,
        _photoView.y + _photoView.height + 3,
        _photoView.width,
        kReportHeight
    );
    
    [self.deleteTimerButtonView setHidden:YES];
}

-(void) updateWithModel:(ModelMessage *)message {
    
    [super updateWithModel:message];
    
    self.photoView.image = message.value;
    _message = message;
//    self.photoView.imageURL = [NSURL URLWithString:message.imageUrl];
    
    [self.deleteTimerButtonView setHidden:YES];
}

+(CGFloat) cellHeightForImage:(UIImage *)image {
    
    CGFloat factor = kImageViewWidth / image.size.width;
    
    CGSize imageSize = CGSizeMake(image.size.width * factor, image.size.height * factor);
    
    return imageSize.height + [MessageCell frameForAvatarIconView:nil].size.height;
}

+ (BOOL) isArrowHidden
{
    return NO;
}

+ (BOOL) isCommentCounterHidden
{
    return YES;
}

+(CGFloat) extraSpaceAtTheTop {
    
    return 0;
}

-(UILabel *) layoutTimestampLabelBelowView:(UIView *)view {
    
    self.contentView.height = self.height;
    
    self.timestampLabel.frame = [MessageCell frameForInfoLabel:view.frame];
    
    return self.timestampLabel;
}

-(void) report{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReportViolation object:_message];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
