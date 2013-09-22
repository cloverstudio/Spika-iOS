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
#import "HUEditableLabelDelegate.h"
#import "HUTextView.h"

#define kEditableLabelHeight					35
#define kTitleLabelWidth						110
#define kHUEditableLabelViewElementMargin		10
#define kHUEditableLabelViewMaxTextViewHeight	1000

@interface HUEditableLabelView : UIView<UITextFieldDelegate,UITextViewDelegate>

-(void) setTitleFont:(UIFont *)font;
-(void) setEditorFont:(UIFont *)font;
-(void) setTitle:(NSString *)title;
-(void) setEditerText:(NSString *)text;
-(void) setTitleColor:(UIColor *)color;
-(void) setEditorColor:(UIColor *)color;
-(void) setEditing:(BOOL)editing;
-(void) setScrollEnabled:(BOOL)enabled;
-(NSString *) getEditorText;
- (void) setIconImage:(UIImage *) image;
-(void) adjustHeight;

@property (nonatomic,readwrite) BOOL multiLine;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, readwrite) BOOL passwordEntry;
@property (nonatomic, weak) id<HUEditableLabelDelegate> delegate;

@end
