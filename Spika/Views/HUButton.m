//
//  HUButton.m
//  Spika
//
//  Created by Ken Yasue on 2013/09/20.
//
//

#import "HUButton.h"

@implementation HUButton

- (UIEdgeInsets)alignmentRectInsets {
    
    UIEdgeInsets insets;

    if ([self isLeftButton]) {
        insets = UIEdgeInsetsMake(0, 20, 0, 0);
    } else {
        insets = UIEdgeInsetsMake(0, 0, 0, 20);
    }
    
    return insets;
}

- (BOOL)isLeftButton {
    return self.frame.origin.x < (self.superview.frame.size.width / 2);
}

@end
