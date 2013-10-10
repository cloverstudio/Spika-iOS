//
//  HUTextView.m
//  Spika
//
//  Created by Ken Yasue on 2013/09/22.
//
//

#import "HUTextView.h"
#import "Utils.h"

@implementation HUTextView

-(int) getContentHeight{
    float height = [self textViewHeightForAttributedText:[[NSAttributedString alloc] initWithString:self.text] andWidth:self.width];
    return (int) height + 20;
}

- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    if([calculationView respondsToSelector:@selector(setAttributedText:)]){
      [calculationView setAttributedText:text];
    }else{
      [calculationView setText:text.string];
    }
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

@end
