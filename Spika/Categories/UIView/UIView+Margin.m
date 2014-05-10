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

#import <objc/runtime.h>
#import "UIView+Margin.h"

@implementation UIView (Margin)

NSString const *redefined_key_top = @"uiview.topmargin";
NSString const *redefined_key_bottom = @"uiview.bottommargin";

- (void) setTopMargin:(float)topMargin{
    objc_setAssociatedObject(self, &redefined_key_top, [NSNumber numberWithFloat:topMargin], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float) topMargin{
    if(objc_getAssociatedObject(self, &redefined_key_top) != nil)
        return [objc_getAssociatedObject(self, &redefined_key_top) floatValue];
    else
        return 0.0;
}

- (void) setBottomMargin:(float)bottomMargin{
    objc_setAssociatedObject(self, &redefined_key_bottom, [NSNumber numberWithFloat:bottomMargin], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float) bottomMargin{
    if(objc_getAssociatedObject(self, &redefined_key_bottom) != nil)
        return [objc_getAssociatedObject(self, &redefined_key_bottom) floatValue];
    else
        return 0.0;
}



@end
