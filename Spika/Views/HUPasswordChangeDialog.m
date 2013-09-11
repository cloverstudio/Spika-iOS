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

#import "HUPasswordChangeDialog.h"
#import "Utils.h"

@implementation HUPasswordChangeDialog{
    BOOL positionChanged;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        positionChanged = NO;
    }
    return self;
}

- (id) initWithText:(NSString *)text delegate:(id<HUDialogDelegate>)delegate cancelTitle:(NSString *)cancelTitle otherTitle:(NSArray *)otherTitle
{
    self = [super initWithText:@"" delegate:delegate cancelTitle:cancelTitle otherTitle:otherTitle];
    if (self) {
        self.userInteractionEnabled = YES;
        positionChanged = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.oldPasswordView = [[UITextField alloc] initWithFrame:CGRectMake(30, 30, 220, 30)];
    self.oldPasswordView.placeholder = NSLocalizedString(@"Enter current password",nil);
    self.oldPasswordView.secureTextEntry = YES;
    [self.oldPasswordView setBorderStyle:UITextBorderStyleBezel];
    [self addSubview:self.oldPasswordView];
    self.oldPasswordView.delegate = self;
    
    self.passwordView = [[UITextField alloc] initWithFrame:CGRectMake(30, 70, 220, 30)];
    self.passwordView.placeholder = NSLocalizedString(@"Enter new password",nil);
    self.passwordView.secureTextEntry = YES;
    [self.passwordView setBorderStyle:UITextBorderStyleBezel];
    [self addSubview:self.passwordView];
    self.passwordView.delegate = self;
    
    self.confirmPasswordView = [[UITextField alloc] initWithFrame:CGRectMake(30, 110, 220, 30)];
    self.confirmPasswordView.placeholder = NSLocalizedString(@"Re-enter new password",nil);
    self.confirmPasswordView.secureTextEntry = YES;
    [self.confirmPasswordView setBorderStyle:UITextBorderStyleBezel];
    [self addSubview:self.confirmPasswordView];
    self.confirmPasswordView.delegate = self;
    

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (CGRect) calculateFrameForText:(NSString *)text buttons:(NSArray *)buttons
{
    return CGRectMake(10, 10, 280, 220);
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(positionChanged)
        return;
    
    positionChanged = YES;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.frame = CGRectMake(
                                                         self.x,
                                                         self.y,
                                                         self.width,
                                                         self.height- [Utils getKeyboardHeight]
                                                         );
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    

    
}


@end
