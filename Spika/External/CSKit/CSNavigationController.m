//
//  CSNavigationController.m
//  CSNavigationController
//
//  Created by marko.hlebar on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSNavigationController.h"

static UIImage *csNavigationControllerImage = nil;

#pragma mark - UINavigationController Interface
@interface UINavigationBar (BackgroundImageBar)
@end


#pragma mark - CSNavigationController Implementation
@implementation CSNavigationController

#pragma mark - Actions

-(void) setBackgroundImageName:(NSString *)navImageName {
    [self setBackgroundImage:[UIImage imageNamed:navImageName]];
}

-(void) setBackgroundImage:(UIImage*) image {
    csNavigationControllerImage = image;
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:csNavigationControllerImage forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationBar setNeedsDisplay];
    }
}

@end

#pragma mark - UINavigationBar Implementation
@implementation UINavigationBar (BackgroundImageBar)

-(void) drawRect:(CGRect) rect {
    [csNavigationControllerImage drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

@end
