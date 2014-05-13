// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support resizing/cropping
#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

-(UIImage *) resizeIfNeededToMaxDimension:(CGFloat) dimension;


- (UIImage *)rotateImage:(UIImage *)image;

#pragma mark - Resize And Crop
+(UIImage *) imageWithImage:(UIImage *)image resizedToSize:(CGSize)newSize croppedToSize:(CGSize)cropSize;

#pragma mark - Resize
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

#pragma mark - Crop
+ (UIImage *)imageWithImage:(UIImage *)image croppedToSize:(CGSize)targetSize;

@end
