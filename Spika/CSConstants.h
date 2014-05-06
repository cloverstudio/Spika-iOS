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

#ifndef CS_CONSTANTS_H
#define CS_CONSTANTS_h

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

#pragma mark -
#pragma mark Debug macros

/** NSLog with additional info.
 @param NSString
 @since v1.0
 */
#ifdef DEBUG
#   define CSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define CSLog(...)
#endif

/** Timer macro used in couple with CSEndTimer. Stores current time.
 @since v1.0
 */
#define CSStartTimer NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate]

/** Timer macro used in couple with CSStartTimer. Prints time interval between calling CSStartTimer macro.
 @param NSString
 @since v1.0
 */
#define CSEndTimer(msg) NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate]; CSLog([NSString stringWithFormat:@"%@ Time = %f", msg, stop-start],nil)

#pragma mark -
#pragma mark Positional macros

/** Sets new frame origin.
 @since v1.0
 */
#define CSSetOrigin(view,x,y) view.frame = CGRectMake(x,y,view.frame.size.width,view.frame.size.height)

/** Sets new frame size.
 @since v1.0
 */
#define CSSetSize(view,w,h) view.frame = CGRectMake(view.frame.origin.x,view.frame.origin.y,w,h)

/** Applys transformation to scale the view.
 @since v1.0
 */
#define CSSetScale(view,scale) view.transform = CGAffineTransformMakeScale(scale, scale)

/** Moves the view frame.
 @since v1.0
 */
#define CSMoveBy(view,x,y) view.frame = CGRectMake(view.frame.origin.x + x,view.frame.origin.y + y,view.frame.size.width,view.frame.size.height)

/** Adds value to CGPoint.
 @return CGPoint
 @since v1.0
 */
#define CSPointAdd(pt1, pt2) CGPointMake(pt1.x + pt2.x,pt1.y + pt2.y)

/** Subtracts value from CGPoint.
 @return CGPoint
 @since v1.0
 */
#define CSPointSub(pt1, pt2) CGPointMake(pt1.x - pt2.x,pt1.y - pt2.y)

#pragma mark -
#pragma mark Color macros

/** Creates UIColor from RGB value.
 @return UIColor
 @since v1.0
 */
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

/** Creates UIColor from RGB value.
 @return UIColor
 @since v1.0
 */
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

/** Creates UIColor from hexadecimal value.
 @return UIColor
 @since v1.0
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#pragma mark -
#pragma mark Selectors

/** Assign action to button.
 @param @selector(method name)
 @param UIButton
 @since v1.0
 */
#define CSSetActionToButton(selector, button) [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside]

/** Assign action to button.
 @param @selector(method name)
 @param UIButton
 @since v1.0
 */
#define CSRemoveActionFromButton(selector, button) [button removeTarget:self action:selector forControlEvents:UIControlEventTouchUpInside]

#pragma mark - Degrees to radians

#define CS_DEGREES_TO_RADIANS(__X__) ((__X__) * 0.01745329252f)
#define CS_RADIANS_TO_DEGREES(__X__) ((__X__) * 57.29577951f)

#pragma mark - Utility

#define CS_WINSIZE CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)

#pragma mark - DispatchQueue

#define asyncMain(__BLOCK__) dispatch_async(dispatch_get_main_queue(), ^(void) {__BLOCK__();})
#define asyncGlobal(__BLOCK__) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^(void){__BLOCK__();})

#pragma mark - System Versions

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - UIKit structs

#define UIEdgeInsetsMakeSame(__FLOAT__) UIEdgeInsetsMake(__FLOAT__,__FLOAT__,__FLOAT__,__FLOAT__)

#pragma mark - UIScreen size check

#define UIScreenIsWide ([UIScreen mainScreen].bounds.size.height > 480 || [UIScreen mainScreen].bounds.size.width > 320)

#pragma mark - Random
#define CS_RANDOM_0_1() ((random() / (float)0x7fffffff ))
#define CS_RANDOM_SIGN() ((arc4random()%2 == 0 ? -1.0f : 1.0f))
#define CS_RANDOM_NEG1_1() ((CS_RANDOM_0_1() * CS_RANDOM_SIGN()))

#pragma mark - Bogus Class

//http://latest.docs.nimbuskit.info/Preprocessor-Macros.html#gNI_FIX_CATEGORY_BUG
#define CS_CATEGORY_FIX(name) @interface name##CategoryFix @end \
                              @implementation name##CategoryFix @end


#pragma mark - NexTStep

#define NSStringWithInt(__INT__) [NSString stringWithFormat:@"%i",__INT__]
#define NSStringFromBOOL(__BOOL__) (__BOOL__ == YES) ? @"YES" : @"NO"
#define NSStringFormat1(__STR__,__ARG__) [NSString stringWithFormat:__STR__,__ARG__]
#define NSStringFormat2(__STR__,__ARG1__,__ARG2__) [NSString stringWithFormat:__STR__,__ARG1__,__ARG2__]

#pragma mark - Application Defaults

#define CS_APPLICATION_NAME [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define CS_BUNDLE_ID [[NSBundle mainBundle] bundleIdentifier]

#endif
