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

@interface UIView (Apperance)

/*
 Sets view hidden property to !show
 Sets view alpha property to show
 **/
-(void) show:(BOOL)show;

/*
 Sets view hidden property to !show
 Sets view alpha property to show
 If animated is YES then apperance is made in animation block
 **/
-(void) show:(BOOL)show
    animated:(BOOL) animated;


/*
 Sets view hidden property to !show
 Sets view alpha property to show
 If animated is YES then apperance is made in animation block
 Set completion if you want to be notified when animation finishes
 **/
-(void) show:(BOOL)show
    animated:(BOOL) animated
completionBlock:(void(^)(BOOL))completion;


/*
 Sets view hidden property to !show
 Sets view alpha property to show
 If animated is YES then apperance is made in animation block
 Set completion if you want to be notified when animation finishes
 Use duration to manage animation duration
 **/
-(void) show:(BOOL)show
    duration:(NSTimeInterval)duration
    animated:(BOOL)animated
completionBlock:(void(^)(BOOL))completion;


/*
 Sets view hidden property to !show
 Sets view alpha property to show
 If animated is YES then apperance is made in animation block
 Set completion if you want to be notified when animation finishes
 Use duration to manage animation duration
 Use options to manage animation options
 **/

-(void) show:(BOOL)show
    duration:(NSTimeInterval)duration
animationOptions:(UIViewAnimationOptions) options
    animated:(BOOL)animated
completionBlock:(void(^)(BOOL))completion;

#pragma mark - Frames

/*
 Sets view frame
 If animated is YES then apperance is made in animation block
 **/
-(void) setFrame:(CGRect)frame
        animated:(BOOL) animated;


/*
 Sets view frame
 If animated is YES then apperance is made in animation block
 Set completion if you want to be notified when animation finishes
 **/
-(void) setFrame:(CGRect)frame
        animated:(BOOL)animated
 completionBlock:(void(^)(BOOL))completion;


/*
 Sets view frame
 If animated is YES then apperance is made in animation block
 Set completion if you want to be notified when animation finishes
 Use duration to manage animation duration
 **/
-(void) setFrame:(CGRect)frame
        duration:(NSTimeInterval)duration
        animated:(BOOL)animated
 completionBlock:(void(^)(BOOL))completion;


/*
 Sets view frame
 If animated is YES then apperance is made in animation block
 Set completion if you want to be notified when animation finishes
 Use duration to manage animation duration
 Use options to manage animation options
 **/
-(void) setFrame:(CGRect)frame
        duration:(NSTimeInterval)duration
animationOptions:(UIViewAnimationOptions) options
        animated:(BOOL)animated
 completionBlock:(void(^)(BOOL))completion;
@end
