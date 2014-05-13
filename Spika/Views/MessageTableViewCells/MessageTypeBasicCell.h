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

#import <UIKit/UIKit.h>


#define MessageCell [self class]

@class ModelMessage;
@protocol MessageCellDelegate;

@interface MessageTypeBasicCell : UITableViewCell

- (void) updateWithModel:(ModelMessage *)message;
- (UILabel *) layoutTimestampLabelBelowView:(UIView *)view;

-(void) tapGestureRecognizerDidTap:(UIGestureRecognizer *)tapRecognizer;

+ (CGFloat) cellHeightForMessage:(ModelMessage *)message;
+ (CGRect) frameForAvatarIconView:(ModelMessage *)message;
+ (CGRect) frameForArrowImageView:(ModelMessage *)message;

+ (CGFloat) heightForTimestampLabel;
+ (CGFloat) extraSpaceAtTheBottom;
+ (CGFloat) extraSpaceAtTheTop;
+ (CGFloat) totalExtraHeight;

+ (BOOL) isArrowHidden;
+ (BOOL) isTimestampHidden;
+ (BOOL) isAvatarIconHidden;

@property (nonatomic, strong) UIImageView *avatarIconView;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) ModelMessage *message;
@property (nonatomic) BOOL isUserMessage;
@property (nonatomic, strong) UIImageView *deleteTimerButtonView;

@property (nonatomic, weak) id delegate;

@end

@protocol MessageCellDelegate <NSObject>

-(void) messageCell:(MessageTypeBasicCell *)cell didTapAvatarImage:(ModelMessage *)message;
-(void) messageCell:(MessageTypeBasicCell *)cell didTapDeleteTimer:(ModelMessage *)message;

@end
