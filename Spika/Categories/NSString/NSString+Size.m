//
//  NSString+Size.m
//  VectorChat
//
//  Created by Josip Bernat on 10/04/14.
//  Copyright (c) 2014 Vector. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGSize)sizeForBoundingSize:(CGSize)boundingSize
                         font:(UIFont *)font {

    return [self sizeForBoundingSize:boundingSize
                                font:font
                       lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)sizeForBoundingSize:(CGSize)boundingSize
                         font:(UIFont *)font
                lineBreakMode:(NSLineBreakMode)lineBreakMode {

    CGSize size = CGSizeZero;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    
    size = [self sizeWithFont:font
            constrainedToSize:boundingSize
                lineBreakMode:lineBreakMode];
#else
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    [textStorage addAttribute:NSFontAttributeName
                        value:font
                        range:NSMakeRange(0, self.length)];
    
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:boundingSize];
    textContainer.lineFragmentPadding = 0;
    textContainer.lineBreakMode = lineBreakMode;
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    size = [layoutManager usedRectForTextContainer:textContainer].size;
#endif
    
    return size;
}

@end
