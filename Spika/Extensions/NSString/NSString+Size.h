//
//  NSString+Size.h
//  VectorChat
//
//  Created by Josip Bernat on 10/04/14.
//  Copyright (c) 2014 Vector. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

- (CGSize)sizeForBoundingSize:(CGSize)boundingSize
                         font:(UIFont *)font;

- (CGSize)sizeForBoundingSize:(CGSize)boundingSize
                         font:(UIFont *)font
                lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
