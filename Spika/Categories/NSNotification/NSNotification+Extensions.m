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

#import "NSNotification+Extensions.h"

@implementation NSNotification (Extensions)

-(CGRect) keyboardFrameEnd {
    
    NSValue *value = [[self userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    return value ? [value CGRectValue] : CGRectZero;
}

-(CGRect) keyboardFrameBegin {
    
    NSValue *value = [[self userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    return value ? [value CGRectValue] : CGRectZero;
}

-(NSTimeInterval) keyboardAnimationDuration {
    
    NSNumber *value = [[self userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    return value ? [value floatValue] : 0.0f;
}

-(UIViewAnimationCurve) keyboardAnimationCurve {
    
    return [[self userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
}

@end


@implementation NSNotificationCenter (Extensions)

+(void) addObserverNamed:(NSString *)name usingBlock:(void (^)(NSNotification *note))block {
	
	[[NSNotificationCenter defaultCenter] addObserverForName:name object:nil queue:nil usingBlock:block];
	
}

@end
