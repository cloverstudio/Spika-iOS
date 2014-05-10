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

#import "UIView+Apperance.h"

@implementation UIView (Apperance)

#pragma mark - Show and Hide options

-(void) show:(BOOL)show {
    [self show:show animated:NO];
}

-(void) show:(BOOL)show
    animated:(BOOL)animated {
    
    void (^animations)() = ^(){
        if (show) {
            self.hidden = !show;
        }
        self.alpha = show;
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        if (!show) {
            self.hidden = !show;
        }
    };
    
    if (!animated) {
        animations();
        completionBlock(YES);
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completionBlock];
}

-(void) show:(BOOL)show
    animated:(BOOL)animated
completionBlock:(void(^)(BOOL))completion {

    void (^animations)() = ^(){
        if (show) {
            self.hidden = !show;
        }
        self.alpha = show;
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        if (!show) {
            self.hidden = !show;
        }
        if(completion)completion(YES);
    };
    
    if (!animated) {
        animations();
        completionBlock(YES);
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completionBlock];
}

-(void) show:(BOOL)show
    duration:(NSTimeInterval)duration
    animated:(BOOL)animated
completionBlock:(void(^)(BOOL))completion {
    
    void (^animations)() = ^(){
        if (show) {
            self.hidden = !show;
        }
        self.alpha = show;
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        if (!show) {
            self.hidden = !show;
        }
        if(completion)completion(YES);
    };
    
    if (!animated) {
        animations();
        completionBlock(YES);
        return;
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completionBlock];
}

-(void) show:(BOOL)show
    duration:(NSTimeInterval)duration
animationOptions:(UIViewAnimationOptions) options
    animated:(BOOL)animated
completionBlock:(void(^)(BOOL))completion {
    
    void (^animations)() = ^(){
        if (show) {
            self.hidden = !show;
        }
        self.alpha = show;
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        
        if (!show) {
            self.hidden = !show;
        }
        if(completion)completion(YES);
    };
    
    if (!animated) {
        animations();
        completionBlock(YES);
        return;
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:options
                     animations:animations
                     completion:completionBlock];
}

#pragma mark - Frames

-(void) setFrame:(CGRect)frame
        animated:(BOOL) animated {
    
    
    void (^animations)() = ^(){
        self.frame = frame;
    };
    
    if (!animated) {
        animations();
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:nil];
}

-(void) setFrame:(CGRect)frame
        animated:(BOOL)animated
 completionBlock:(void(^)(BOOL))completion {
    
    
    void (^animations)() = ^(){
        self.frame = frame;
    };
    
    if (!animated) {
        animations();
        completion(YES);
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completion];
}

-(void) setFrame:(CGRect)frame
        duration:(NSTimeInterval)duration
        animated:(BOOL)animated
 completionBlock:(void(^)(BOOL))completion {
    
    
    void (^animations)() = ^(){
        self.frame = frame;
    };
    
    if (!animated) {
        animations();
        completion(YES);
        return;
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completion];
}

-(void) setFrame:(CGRect)frame
        duration:(NSTimeInterval)duration
    animationOptions:(UIViewAnimationOptions) options
        animated:(BOOL)animated
 completionBlock:(void(^)(BOOL))completion {
 
    
    void (^animations)() = ^(){
        self.frame = frame;
    };
    
    if (!animated) {
        animations();
        completion(YES);
        return;
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:options
                     animations:animations
                     completion:completion];
}
@end
