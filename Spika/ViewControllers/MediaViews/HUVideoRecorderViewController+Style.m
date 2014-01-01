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

#import "HUVideoRecorderViewController+Style.h"
#import "Utils.h"

@implementation HUVideoRecorderViewController (Style)

- (CGRect) frameForAddTitleView
{
    CGRect frame = CGRectMake(0, 0, 320, 75);
    return frame;
}

- (CGRect)  frameForVideoPlayer:(CGSize) videoSize{
    
    float width = 300;
    float scale = width / videoSize.width;
    float height = videoSize.height * scale;
 
    CGRect frame = CGRectMake(0, 5, width, height);
    
    return frame;
}

- (CGRect)  frameForContainerView{
    return CGRectMake(10, 85, 300, [Utils getDisplayHeight] - 85);
}
@end
