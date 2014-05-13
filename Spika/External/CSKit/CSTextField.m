//
//  CSTextField.m
//  CSKit
//
//  Created by Josip Bernat on 4/25/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSTextField.h"

@implementation CSTextField

@synthesize placeholderTextColor = _placeholderTextColor;

#pragma mark - Getters

- (UIColor *) placeholderTextColor {

    if (!_placeholderTextColor) {
        self.placeholderTextColor = [UIColor blackColor];
    }
    return _placeholderTextColor;
}

#pragma mark - Override

- (void) drawPlaceholderInRect:(CGRect)rect {
    
    [[self placeholderTextColor] setFill];
    
    [[self placeholder] drawInRect:rect
                    withAttributes:@{NSFontAttributeName: self.font,
                                     NSForegroundColorAttributeName: [self placeholderTextColor]}];
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , self.textInset.x , self.textInset.y );
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , self.placeholderInset.x , self.placeholderInset.y );
}

@end
