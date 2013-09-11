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

#import <Foundation/Foundation.h>

@class CSLazyLoadController;
@protocol CSLazyLoadControllerDelegate <NSObject>

- (void) lazyLoadController:(CSLazyLoadController *)controller
            didReceiveImage:(UIImage *)image
               forIndexPath:(NSIndexPath *)indexPath;

- (void) lazyLoadController:(CSLazyLoadController *)controller
           didFailWithError:(NSString *)error
               forIndexPath:(NSIndexPath *)indexPath;
@end

@protocol CSLazyLoadControllerDataSource <NSObject>

- (NSString *) lazyLoadController:(CSLazyLoadController *)controller
           urlForImageAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CSLazyLoadController : NSObject

@property (nonatomic, assign) id<CSLazyLoadControllerDelegate> delegate;
@property (nonatomic, assign) id<CSLazyLoadControllerDataSource> dataSource;

#pragma mark - Image Download
- (void) downloaImage:(NSString *)imageUrl forIndexPath:(NSIndexPath *)indexPath;

-(void) loadImagesForOnscreenRows:(NSArray *) indexPaths;

@end
