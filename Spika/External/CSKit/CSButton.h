//
//  CSButton.h
//
//  Created by Luka Fajl on 29.5.2012..
//  Copyright (c) 2012. Clover-Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSButton : UIButton

#pragma mark - Initialization

+ (CSButton *) buttonWithFrame:(CGRect)frame
                      callback:(CSVoidBlock)callback;

+ (CSButton *) buttonWithNormal:(NSString *)normal
                    highlighted:(NSString *)highlighted;

+ (CSButton *) buttonWithNormal:(NSString *)normal
                    highlighted:(NSString *)highlighted
                       callback:(CSVoidBlock)callback;

+ (CSButton *) buttonWithImageNormal:(UIImage *)normal
                         highlighted:(UIImage *)highlighted
                            callback:(CSVoidBlock)callback;

#pragma mark - Callback Controll
-(void) setPressCallback:(CSVoidBlock)callback;
@end
