//
//  CSTextField.h
//  CSKit
//
//  Created by Josip Bernat on 4/25/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTextField : UITextField

@property (nonatomic, retain) UIColor *placeholderTextColor;
@property (nonatomic) CGPoint textInset;
@property (nonatomic) CGPoint placeholderInset;

@end
