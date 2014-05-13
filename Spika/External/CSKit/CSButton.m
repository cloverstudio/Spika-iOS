//
//  CSButton.m
//
//  Created by Luka Fajl on 29.5.2012..
//  Copyright (c) 2012. Clover-Studio. All rights reserved.
//

#import "CSButton.h"

@interface CSButton()

@property (nonatomic, copy) CSVoidBlock callback;

#pragma mark - Target Selectors
-(void) pushed;

#pragma mark - Images Controll
-(void) swapImagesWithNormal:(NSString *)normal
                 highlighted:(NSString *)highlighted;

@end

@implementation CSButton
@synthesize callback = _callback;


#pragma mark - Memory Management

-(void) dealloc {
    
    [self removeTarget:self
                action:@selector(pushed)
      forControlEvents:UIControlEventTouchUpInside];
    
    _callback = nil;
}
#pragma mark - Initialization

+ (CSButton *) buttonWithFrame:(CGRect)frame
                      callback:(CSVoidBlock)callback {

    CSButton *button = [CSButton buttonWithType:UIButtonTypeCustom];
	[button setCallback:callback];
    [button setFrame:frame];
	[button addTarget:button
               action:@selector(pushed)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(CSButton*) buttonWithNormal:(NSString *)normal
                  highlighted:(NSString *)highlighted {
    
    return [CSButton buttonWithNormal:normal highlighted:highlighted callback:nil];
}

+(CSButton*) buttonWithImageNormal:(UIImage *)normal
                       highlighted:(UIImage *)highlighted
                          callback:(CSVoidBlock)callback {
    
    CSButton *button = [CSButton buttonWithType:UIButtonTypeCustom];
	button.callback = callback;
	[button setImage:normal forState:UIControlStateNormal];
	[button setImage:highlighted forState:UIControlStateHighlighted];
	[button addTarget:button action:@selector(pushed) forControlEvents:UIControlEventTouchUpInside];
    CGSize size = normal.size;
    button.frame = CGRectMake(0, 0, size.width, size.height);
	return button;
    
}

+(CSButton*) buttonWithNormal:(NSString *)normal
                  highlighted:(NSString *)highlighted
                     callback:(CSVoidBlock)callback {
    
    return [CSButton buttonWithImageNormal:[UIImage imageNamed:normal]
                               highlighted:[UIImage imageNamed:highlighted]
                                  callback:callback];
    
}

#pragma mark - Target Selectors

-(void) pushed {
    
    if (_callback)
        _callback();
}

#pragma mark - Callback Controll

-(void) setPressCallback:(CSVoidBlock)callback {
    
    self.callback = [callback copy];
}

#pragma mark - Images Controll

-(void) swapImagesWithNormal:(NSString *)normal
                 highlighted:(NSString *)highlighted {
    
    CGPoint center = self.center;
    [self setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
	[self setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
    
    CGSize size = [UIImage imageNamed:normal].size;
    self.frame = CGRectMake(center.x-size.width*.5f,
                            center.y-size.height*.5f,
                            size.width,
                            size.height);
}

@end
