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

#import "CSLazyLoadController.h"
#import "DatabaseManager.h"

@implementation CSLazyLoadController

#pragma mark - Image Download

- (void) downloaImage:(NSString *)imageUrl forIndexPath:(NSIndexPath *)indexPath {

    [[DatabaseManager defaultManager] loadImage:imageUrl
                                        success:^(UIImage *image){
                                        
                                            if ([(NSObject *)_delegate respondsToSelector:@selector(lazyLoadController:didReceiveImage:forIndexPath:)]) {
                                                
                                                [_delegate lazyLoadController:self
                                                              didReceiveImage:image
                                                                 forIndexPath:indexPath];
                                            }
                                        }
                                            error:^(NSString *error) {
                                            
                                                if ([(NSObject *)_delegate respondsToSelector:@selector(lazyLoadController:didFailWithError:forIndexPath:)]) {
                                                    [_delegate lazyLoadController:self
                                                                 didFailWithError:error
                                                                     forIndexPath:indexPath];
                                                }
                                            }];
}

-(void) loadImagesForOnscreenRows:(NSArray *) indexPaths {

    for (NSIndexPath *indexPath in indexPaths) {
        
        NSString *imageUrl = nil;
        
        if ([(NSObject *)_dataSource respondsToSelector:@selector(lazyLoadController:urlForImageAtIndexPath:)]) {
            
            imageUrl = [_dataSource lazyLoadController:self
                                urlForImageAtIndexPath:indexPath];
        }
        
        if (imageUrl) {
            [self downloaImage:imageUrl forIndexPath:indexPath];
        }
    }

}

@end
