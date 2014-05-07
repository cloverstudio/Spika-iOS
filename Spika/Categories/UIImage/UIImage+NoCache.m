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

#import "UIImage+NoCache.h"

@implementation UIImage (NoCache)

//Returnes new UIImage but does not caches image like imageNamed does
//Image must be png
+(UIImage *)imageWithBundleImage:(NSString *)imageNamed {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:imageNamed ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

//Returnes new UIImage but does not caches image like imageNamed does
//Image must have type extension
+(UIImage *) imageWithBundleImage:(NSString *)imageNamed ofType:(NSString *) type {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:imageNamed ofType:type];
    return [UIImage imageWithContentsOfFile:path];
}

//Returns stretchable image depending on iOS version
-(UIImage *) resizableImageWithSize:(CGSize)size {
    
    if([self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        
        return [self resizableImageWithCapInsets:UIEdgeInsetsMake(size.height, size.width, size.height, size.width)];
    } 
    else {
        return [self stretchableImageWithLeftCapWidth:size.width topCapHeight:size.height];
    }
}

@end
