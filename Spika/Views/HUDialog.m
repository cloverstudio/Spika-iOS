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

#import "HUDialog.h"
#import "HUDialog+Style.h"
#import "CSGraphics.h"

#define DialogClass [self class]

#define kRectContractionValue 20

@interface HUDialog () <HUDialogDelegate>
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, strong) UIView *blackView;
@end

@implementation HUDialog

#pragma mark - Dealloc

#pragma mark - Initialization

- (id)initWithText:(NSString *)text delegate:(id<HUDialogDelegate>)delegate cancelTitle:(NSString *)cancelTitle otherTitle:(NSArray *)otherTitle
{
    self = [super init];
    if (self) {
        // Initialization code
        //self.arrowAnchorPoint = CGPointMake(.0f, .5f);
        self.text = text;
        self.cancelTitle = cancelTitle;
        self.otherTitles = otherTitle;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.delegate = delegate;
        
        self.blackView = [[UIView alloc] init];
        self.blackView.backgroundColor = [UIColor blackColor];
        self.blackView.alpha = 0.5;
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void) attachPopUpAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .2;
    
    [self.layer addAnimation:animation forKey:@"popup"];
}

-(void) show {
    
    UIView *window = [[UIApplication sharedApplication].delegate window];
    self.blackView.frame = window.frame;
    [window addSubview:self.blackView];
    
    [self showInView:window];
    [self attachPopUpAnimation];
    
}

-(void) showInView:(UIView *)view {
    
    self.center = CGRectGetCenter(view.bounds);
    [view addSubview:self];
    
    
}

-(void) hide {
    
    [self.blackView removeFromSuperview];
    [self removeFromSuperview];
    
}

-(void) willMoveToSuperview:(UIView *)newSuperview {
    
    [self removeAllSubviews];
    self.buttons = [self newButtons];
    for (UIButton *button in self.buttons) {
        [self addSubview:button];
    }
    
    if (self.cancelTitle) {
        self.cancelButton = self.buttons.lastObject;
    }
}

-(void) layoutSubviews {
    
    CGPoint center = self.center;
    
    self.frame = [self calculateFrameForText:self.text buttons:self.buttons];
    
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    
    if ([self containsCancelAndOtherButtonOnly:self.buttons]) {
        
        UIButton *otherButton = self.buttons[0];
        otherButton.center = CGPointMake(CGRectGetWidth(self.bounds) * .3f, bottomCenter.y - otherButton.height - kRectContractionValue/2);
        
        UIButton *cancelButton = self.buttons[1];
        cancelButton.center = CGPointMake(CGRectGetWidth(self.bounds) * .7f, bottomCenter.y - cancelButton.height - kRectContractionValue/2);;
        
        
    } else {
        
        int i = self.buttons.count - 1;
        for (UIButton *button in self.buttons) {
            
            button.center = bottomCenter;
            button.y -=  button.height + kRectContractionValue/2 + (button.height + 5) * i ;
            
            i--;
        }
        
    }
    
    self.center = center;
    
}

#pragma mark - Override

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

#pragma mark - Selectors

-(void) buttonDidTouchUpInside:(UIButton *)button {
    
    if (button.tag == self.buttons.count - 1) {
        if ([self.delegate respondsToSelector:@selector(dialogDidPressCancel:)]) {
            [self.delegate dialogDidPressCancel:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(dialog:didPressButtonAtIndex:)]) {
            [self.delegate dialog:self didPressButtonAtIndex:button.tag];
        }
    }
    
	[self hide];
}

#pragma mark - Public methods

-(void) addButton:(NSString *)buttonName {
    
    NSMutableArray *buttons = [self.otherTitles mutableCopy];
    [buttons addObject:buttonName];
    self.otherTitles = [buttons copy];
    
}

#pragma mark - Private methods

-(CGRect) calculateFrameForText:(NSString *)text buttons:(NSArray *)buttons {
    
    
//    CGSize minimumSize = [DialogClass minimumDialogSize];
    CGSize maximumSize = [DialogClass maximumDialogSize];
    CGRect calculatedFrame = CGRectWithPointAndSize(self.frame.origin, maximumSize);
    
    CGSize textSize = CGRectContract(calculatedFrame, kRectContractionValue).size;
    textSize = [text sizeForBoundingSize:CGSizeMake(calculatedFrame.size.width, 9999)
                                    font:kFontArialMTOfSize(kFontSizeMiddium)];
    
    CGRect rectContraction = CGRectExpand(CGRectWithPointAndSize(self.frame.origin, textSize), kRectContractionValue);
    calculatedFrame = CGRectMake(rectContraction.origin.x, rectContraction.origin.y, calculatedFrame.size.width, rectContraction.size.height);
    
    calculatedFrame.size.height += kRectContractionValue/2;
    
    if ([self containsCancelAndOtherButtonOnly:buttons]) {
        
        calculatedFrame.size.height += [buttons.lastObject height];
        
    } else {
        
        for (UIButton *button in buttons) {
            calculatedFrame.size.height += button.height;
        }
        
    }
    
    calculatedFrame.size.height += kRectContractionValue * 2;
    
    return calculatedFrame;
    
}

-(BOOL) containsCancelAndOtherButtonOnly:(NSArray *)buttons {
    return (buttons.count == 2 && [buttons containsObject:self.cancelButton]);
}

#pragma mark - Setter

-(void) setArrowAnchorPoint:(CGPoint)arrowAnchorPoint {

    //_arrowAnchorPoint = [self validAnchorPointForPoint:arrowAnchorPoint];

}

#pragma mark - HUDialogDelegate

-(void) dialog:(HUDialog *)dialog didPressButtonAtIndex:(NSInteger)index {
    
    if (self.buttonHandler) {
        self.buttonHandler(index);
    }
    
}

-(void) dialogDidPressCancel:(HUDialog *)dialog {
    
    if (self.cancelHandler) {
        self.cancelHandler();
    }
    
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect contractedRect = CGRectContract(rect, kRectContractionValue);
    CSDrawRectangleFill(ctx, contractedRect, [DialogClass backgroundColor]);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    
    [self.text drawInRect:CGRectContract(contractedRect, 10) withAttributes:@{NSFontAttributeName:kFontArialMTOfSize(kFontSizeMiddium),
                                                                              NSParagraphStyleAttributeName:textStyle}];

}

@end

@implementation HUDialog (Extras)

+(HUDialog *) dialogWithText:(NSString *)text cancelTitle:(NSString *)cancelTitle otherTitle:(NSArray *)otherTitle cancelHandler:(CSVoidBlock)cancelHandler buttonHandler:(void (^)(NSInteger))buttonHandler {
    
    HUDialog *dialog = [HUDialog dialogWithText:text cancelTitle:cancelTitle otherTitle:otherTitle anchorPoint:CGPointZero buttonHandler:buttonHandler];
	dialog.cancelHandler = cancelHandler;
	
	return dialog;
}

+(HUDialog *) dialogWithText:(NSString *)text cancelTitle:(NSString *)cancelTitle otherTitle:(NSArray *)otherTitle anchorPoint:(CGPoint)anchorPoint buttonHandler:(void (^)(NSInteger))buttonHandler {
    
    HUDialog *dialog = [[HUDialog alloc] initWithText:text delegate:nil cancelTitle:cancelTitle otherTitle:otherTitle];
    dialog.delegate = dialog;
    dialog.arrowAnchorPoint = anchorPoint;
	dialog.buttonHandler = buttonHandler;
    
    return dialog;
    
}

@end
