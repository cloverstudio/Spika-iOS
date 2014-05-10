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

#import "HUCounterBalloonView.h"
#import "DatabaseManager.h"
#import "HPDefaultExtensions.h"
#import "UIImage+NoCache.h"
#import "UserManager.h"

@interface HUCounterBalloonView ()

@property (nonatomic, strong) UILabel *label;


#pragma mark - Count Update
- (void) setBaloonCount:(NSInteger)count;

@end

@implementation HUCounterBalloonView

#pragma mark - Initialization

-(id) initWithImage:(UIImage *)image {
    
    if (self = [super initWithImage:image]) {
        
        _label = [UILabel labelWithText:@"0"];
        _label.numberOfLines = 1;
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.frame = CGRectMake(
            -3,
            0,
            self.frame.size.width + 5,
            self.frame.size.height - 5
        );
        
        //_label.backgroundColor = [UIColor blackColor];
        
        [self addSubview:_label];
    }
    
    return self;
}

#pragma mark - Actions

-(void) updateWithModel:(ModelMessage *)message {
    
    
    
//    [[DatabaseManager defaultManager]
//     getCommentsCountByMessage:message
//     success:^(NSString *result){
//         
//         dispatch_async(dispatch_get_main_queue(), ^{
    
    if (message.comment_count > 0) {
        [self setHidden:NO];
        [self setBaloonCount:message.comment_count];
    } else {
        [self setHidden:YES];
    }
    
    
             
//             if(result != nil){
//                 
//                 if(result != nil && [result isKindOfClass:[NSString class]]){
//                     
//                     NSInteger *integer = [result integerValue];
//                     
//                     [self setHidden:NO];
//                     [self setBaloonCount:integer];
//                     
//                     return;
//                 }
//                 
//             }
             
//         });
//
//
//     } error:^(NSString *errStr){
         
//         dispatch_async(dispatch_get_main_queue(), ^{
//             
//             
//         });
//         
//     }];
    
    
    
}

#pragma mark - Count Update

- (void) setBaloonCount:(NSInteger)count {

    NSString *countString = countString = [NSString stringWithFormat:@"%lu",(unsigned long)count];;
    
    if (count > 99) {
        countString = @"99+";
    }
    
    
    _label.text = countString;

}

#pragma mark - Setter

-(void) setTextColor:(UIColor *)textColor {
    
    _textColor = textColor;
    
    _label.textColor = textColor;
}

- (void) setCount:(NSInteger)count {

    _count = count;
    
    [self setBaloonCount:count];
}

@end

@implementation HUCounterBalloonView (Extras)

+(HUCounterBalloonView *) counterView {
    return [[HUCounterBalloonView alloc] initWithImage:[UIImage imageNamed:@"comment_number_ballon"]];
}

@end
