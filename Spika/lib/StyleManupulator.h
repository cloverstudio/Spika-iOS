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

#import <Foundation/Foundation.h>
#import "MessageTypeTextCell.h"

#define MessageBodyFont [UIFont fontWithName:@"Arial" size:14]
#define GeneralBoldFont [UIFont fontWithName:@"Helvetica-Bold" size:14]
#define MessageInfoFont [UIFont fontWithName:@"Arial" size:12]

@interface StyleManupulator : NSObject

+(void) attachNavigationBarStyle:(UINavigationBar *)navBar;
+(void) attachDefaultTextField:(UIView *)view;
+(void) attachDefaultTextView:(UIView *)view;
+(void) attachDefaultButton:(UIButton *)view;
+(void) attachDefaultBG:(UIView *)view;
+(void) attachSideMenuBG:(UIView *)view;
+(void) attachSideMenuCellBGBig:(UITableViewCell *)cell;
+(void) attachDefaultCellBG:(UITableViewCell *)cell;
+(void) attachDefaultCellFont:(UILabel *)label;
+(void) attachWallTextViewBG:(UIView *)view;
+(void) attachWallTextView:(UIView *)view;
+(void) attachWallButtons:(UIButton *)view;
+(void) attachTextMessageCell:(MessageTypeTextCell *)cell;
+(void) attachTextMessageHolderBG:(UIView *)view;
+(void) attachTextMessageLabel:(UILabel *)label;
+(void) attachTextMessageInfoLabel:(UILabel *)label;
+(void) attachMediaButtonStyle:(UIButton *)button;
+(void) attachImagePreviewStyle:(UIView *)view;
+(void) attachMessageImageViewFrameStyle:(UIView *)view;
+(void) attachCommentNumLabelStyle:(UILabel *)label;
+(void) attachLoadingRowStyle:(UIView *)view;
+(void) attachDefaultLabel:(UILabel *)label;
+(void) attachMessageVideoViewFrameStyle:(UIView *)view;
+(void) attachMessageVideoViewFrameStylePlayLabel:(UILabel *)label;
+(void) attachMessageLocationViewFrameStylePlayLabel:(UILabel *)label;

@end
