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

#import "HUEditableLabelView.h"

@interface HUEditableLabelView (){
    UILabel *_titleLabel;
    HUTextView *_textView;
    UITextField *_passwordView;
    UIImageView *_iconView;
    BOOL    _isSecure;
}

@end


@implementation HUEditableLabelView

@synthesize textView = _textView;
@synthesize passwordTextField = _passwordView;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _textView = [[HUTextView alloc] init];
        [_textView setReturnKeyType:UIReturnKeyDone];
        
        // crashes in iOS7
        //_textView.dataDetectorTypes = UIDataDetectorTypeLink;
        
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor clearColor];
        
        _passwordView = [[UITextField alloc] init];
        _passwordView.secureTextEntry = YES;
        _passwordView.delegate = self;
        _passwordView.backgroundColor = [UIColor clearColor];
        
        //_textView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textView.editable = NO;
        self.multiLine = NO;
        _passwordView.enabled = NO;
        
        [self addSubview:_titleLabel];
        [self addSubview:_textView];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

-(void) setPasswordEntry:(BOOL)passwordEntry{
    
    _isSecure = passwordEntry;
    _passwordView.text = _textView.text;
    
    if(_isSecure) {
        
        [self addSubview:_passwordView];
        
    }
    
}

-(void) setTitleFont:(UIFont *)font{
    _titleLabel.font = font;
}

-(void) setEditorFont:(UIFont *)font{
    _textView.font = font;
}

-(void) setTitle:(NSString *)title{
    _titleLabel.text = title;
}

-(void) setEditerText:(NSString *)text{
    _textView.text = text;
    _passwordView.text = text;
}

-(void) setTitleColor:(UIColor *)color{
    _titleLabel.textColor = color;
}

-(void) setEditorColor:(UIColor *)color{
    _textView.textColor = color;
}

-(void) setFrame:(CGRect)frame{
	
    [super setFrame:frame];
    
    [self adjustHeight];
    
    _titleLabel.frame = CGRectMake(
        kHUEditableLabelViewElementMargin,5,kTitleLabelWidth,self.frame.size.height
    );
    
    int textViewWidth = self.frame.size.width - kTitleLabelWidth - kHUEditableLabelViewElementMargin * 3;
    
    if(!_multiLine){
        _textView.frame = CGRectMake(kTitleLabelWidth + kHUEditableLabelViewElementMargin * 2, 8,
                                     textViewWidth, kEditableLabelHeight);
    }else{
        
        int textFieldHeight = [_textView getContentHeight];
        
        if(textFieldHeight < kEditableLabelHeight)
            textFieldHeight = kEditableLabelHeight;
        
        _textView.frame = CGRectMake(kTitleLabelWidth + kHUEditableLabelViewElementMargin * 2, 8,
                                     textViewWidth, textFieldHeight);
        
    }
    
    _passwordView.frame = CGRectMake(kTitleLabelWidth + kHUEditableLabelViewElementMargin * 2 + 7, 17,
                                     textViewWidth, kEditableLabelHeight);

    _passwordView.font = _textView.font;
    _passwordView.textColor = _textView.textColor;
    
    if(_iconView != nil){
        
        int margin = kHUEditableLabelViewElementMargin + 5;
        
        _textView.frame = CGRectMake(
                                     _iconView.x + _iconView.width + margin - 10,
                                     _textView.y,
                                     textViewWidth - _iconView.width - margin,
                                     _textView.height
                                     );
        
        _passwordView.frame = CGRectMake(
                                         _iconView.x + _iconView.width + margin - 10,
                                         _passwordView.y,
                                         textViewWidth - _iconView.width - margin,
                                         _passwordView.height
                                         );
    
        
    }
    
    _iconView.frame = CGRectMake(
        _iconView.x,
        (self.height - _iconView.height) / 2,
        _iconView.width,
        _iconView.height
    );
}

-(void) setEditing:(BOOL)editing{
    _textView.editable = editing;
    _passwordView.enabled = editing;
}

-(void) setScrollEnabled:(BOOL)enabled
{
	_textView.scrollEnabled = enabled;
}

-(NSString *) getEditorText{
    
    if(_isSecure)
        return _passwordView.text;
    else
        return _textView.text;
    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(self.delegate){
        return [self.delegate textViewShouldBeginEditing:textField];
    }
    
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    if(self.delegate){
        [self.delegate textViewDidBeginEditing:textField];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(self.delegate){
        [self.delegate textFieldDidEndEditing:textField];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(self.delegate){
        return [self.delegate textView:textField shouldChangeTextInRange:range replacementText:string];
    }
    
    return YES;

}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]){
        return [self.delegate textViewShouldBeginEditing:textView];
    }
    
    return YES;
    

}

- (void)textViewDidBeginEditing:(UITextView *)textView{

    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]){
        [self.delegate textViewDidBeginEditing:textView];
    }

    
}
- (void)textViewDidEndEditing:(UITextView *)textView{

    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]){
        [self.delegate textFieldDidEndEditing:textView];
    }

    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
        return [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    return YES;

}

- (void) setIconImage:(UIImage *) image{
    
    if(image == nil)
        return;
    
    if(_iconView)
        [_iconView removeFromSuperview];
    
    _iconView = [[UIImageView alloc] initWithImage:image];
    
    float iconViewWidth = 40;
    if(image.size.width < iconViewWidth)
        iconViewWidth = image.size.width;
    
    float scale = iconViewWidth / image.size.width;
    float iconViewHeight = image.size.height * scale;
    
    _iconView.frame = CGRectMake(
        kTitleLabelWidth + kHUEditableLabelViewElementMargin * 2,
        (self.height - iconViewHeight) / 2,
        iconViewWidth,
        iconViewHeight
    );
    
    [self addSubview:_iconView];

    int margin = kHUEditableLabelViewElementMargin + 5;
    
    int textViewWidth = self.frame.size.width - kTitleLabelWidth - kHUEditableLabelViewElementMargin * 3;

    
    _textView.frame = CGRectMake(
                                 _iconView.x + _iconView.width + margin - 10,
                                 _textView.y,
                                 textViewWidth - _iconView.width - margin,
                                 _textView.height
                                 );
    
    _passwordView.frame = CGRectMake(
                                     _iconView.x + _iconView.width + margin - 10,
                                     _passwordView.y,
                                     textViewWidth - _iconView.width - margin,
                                     _passwordView.height
                                     );

    
}

- (void) handleSingleTap{
    
    if(_textView.editable == NO){
        
        if([_delegate respondsToSelector:@selector(onTouch:)]){
            [_delegate performSelector:@selector(onTouch:) withObject:self];
        }
        
    }
    
}

- (void) setMultiLine:(BOOL)multiLine{
    
    _multiLine = multiLine;
    
    if(multiLine){
        _textView.returnKeyType = UIReturnKeyDefault;
    }else{
        _textView.returnKeyType = UIReturnKeyDone;
    }
}

-(void) adjustHeight{
    
    int height = [_textView getContentHeight];
    
    if(_multiLine == NO || height < kEditableLabelHeight)
        height = kEditableLabelHeight;
    
    super.frame = CGRectMake(
        self.x,
        self.y,
        self.width,
        height + 15
    );
    
}

@end
