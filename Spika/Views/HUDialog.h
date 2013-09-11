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

@protocol HUDialogDelegate;

@interface HUDialog : UIView

@property (nonatomic, copy) NSString *text, *cancelTitle;
@property (nonatomic, strong) NSArray *otherTitles;
@property (nonatomic) CGPoint arrowAnchorPoint;
@property (nonatomic, copy) CSVoidBlock cancelHandler;
@property (nonatomic, copy) void(^buttonHandler)(NSInteger buttonIndex);
@property (nonatomic, weak) id<HUDialogDelegate> delegate;

-(id) initWithText:(NSString *)text delegate:(id<HUDialogDelegate>)delegate cancelTitle:(NSString *)cancelTitle otherTitle:(NSArray *)otherTitle;

-(void) addButton:(NSString *)buttonName;

-(void) show;
-(void) showInView:(UIView *)view;
-(void) hide;

-(CGRect) calculateFrameForText:(NSString *)text buttons:(NSArray *)buttons;

@end

@interface HUDialog (Extras)

+(HUDialog *) dialogWithText:(NSString *)text
                 cancelTitle:(NSString *)cancelTitle
                  otherTitle:(NSArray *)otherTitle
               cancelHandler:(CSVoidBlock)cancelHandler
               buttonHandler:(void(^)(NSInteger index))buttonHandler;

+(HUDialog *) dialogWithText:(NSString *)text
                 cancelTitle:(NSString *)cancelTitle
                  otherTitle:(NSArray *)otherTitle
                 anchorPoint:(CGPoint)anchorPoint
               buttonHandler:(void(^)(NSInteger index))buttonHandler;

@end

@protocol HUDialogDelegate <NSObject>

-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index;
-(void) dialogDidPressCancel:(HUDialog *)dialog;

@end