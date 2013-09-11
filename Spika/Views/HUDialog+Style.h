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

#import "HUDialog.h"

@interface HUDialog (Style)

#pragma mark - Factory

-(NSMutableArray *) newButtons;

#pragma mark - Style

-(CGPoint) validAnchorPointForPoint:(CGPoint)point;
-(CGSize) buttonSize;

+(CGSize) minimumDialogSize;
+(CGSize) maximumDialogSize;
+(UIColor *) backgroundColor;
+(UIColor *) textColor;
+(UIColor *) cancelButtonBackgroundColor;
+(UIColor *) cancelButtonTextColor;
+(UIColor *) otherButtonBackgroundColor;
+(UIColor *) otherButtonTextColor;

@end
