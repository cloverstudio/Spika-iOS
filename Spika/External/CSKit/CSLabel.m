//
//  CSLabel.m
//  AirVinyl
//
//  Created by Luka Fajl on 9.8.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "CSLabel.h"
#import "CSGraphics.h"

@implementation CSLabel

@synthesize outlineColor, outlineWidth, underlineColor, underlineWidth, underlineOffset, strikeoutColor, strikeoutWidth, margin;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.outlineColor = self.underlineColor = self.strikeoutColor = [UIColor blackColor];
        self.outlineWidth = 0;
        self.strikeoutWidth = self.underlineWidth = 0;
        self.underlineOffset = 0;
        self.margin = UIEdgeInsetsZero;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    
    rect = CGRectMake(rect.origin.x + self.margin.left,
                      rect.origin.y + self.margin.top,
                      rect.size.width - self.margin.left - self.margin.right,
                      rect.size.height - self.margin.top - self.margin.bottom);
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, self.outlineWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    if (self.outlineColor != nil && self.outlineWidth != 0) {
        CGContextSetTextDrawingMode(c, kCGTextStroke);
        self.textColor = self.outlineColor;
        [super drawTextInRect:rect];
    }
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    //draw underline
    /*if (self.underlineColor != nil && self.underlineWidth != 0)
        [self drawUnderlineInContext:c rect:rect];*/
    
    self.shadowOffset = shadowOffset;
    
}

-(void) sizeToFit {
    CGFloat width = self.bounds.size.width;
    
    CGRect frame = self.frame;
    frame.size = [self.text sizeForBoundingSize:CGSizeMake(frame.size.width - self.margin.left - self.margin.right*2, 9999)
                                           font:[UIFont systemFontOfSize:self.font.pointSize + 2]];
    frame.size.width = width;
    
    self.frame = frame;
}

/*-(void) drawUnderlineInContext:(CGContextRef)context rect:(CGRect)rect {
    
    CGContextSetStrokeColorWithColor(context, self.underlineColor.CGColor);
    CGContextSetLineWidth(context, self.underlineWidth);
    [self drawLinesInContext:context rect:rect strikeout:NO];
    
}

-(void) drawStrikeoutInContext:(CGContextRef)context rect:(CGRect)rect {
    
    CGContextSetStrokeColorWithColor(context, self.strikeoutColor.CGColor);
    CGContextSetLineWidth(context, self.strikeoutWidth);
    [self drawLinesInContext:context rect:rect strikeout:YES];
    
}*/

//
// UnderLineLabel.m
//
//
// Created by Guntis Treulands on 8/01/12.
//

/*-(void) drawLinesInContext:(CGContextRef)context rect:(CGRect)rect strikeout:(BOOL)isStrikeout {
    
    //calculate line height for some random simbol using its own font.
    int lineHeight = [@"a" sizeWithFont:self.font constrainedToSize:self.frame.size].height;
    
    float mPartOfTextStringWidth = 0.0;
    
    //text part between two spaces, for checking if it is in one line.
    NSString *mPartOfTextString = @"";
    
    
    //we add a space for easier calculations
    NSString *mTotalTextString = [NSString stringWithFormat:@"%@ ",self.text];
    
    
    //corresponding line we are in.
    int mCurrentLine = 1;
    
    
    //space char counter
    int mSpaceChar = 0;
    
    
    //break char counter
    int mBreakChar = 0;
    
    
    //in case its not Aligned to left side
    int extraSpaceFromBeginning = 0;
    
    
    //topOffset, if label height is bigger than text height
    int topOffset = (self.frame.size.height-[mTotalTextString sizeWithFont:self.font constrainedToSize:self.frame.size].height)/2;
    
    if(isStrikeout)//offset to top by 1/3 of line height (but its not 100% perfect..)
    {
        topOffset -=lineHeight/3;
    }
    
    //--- go through text and search for spaces
    for(int i = 0; i < [mTotalTextString length]; i++)
    {
        if([mTotalTextString characterAtIndex:i] == ' ')
        {
            //get string from break char to current character (break char is when new line encountered
            mPartOfTextString = [[mTotalTextString substringToIndex:i] substringFromIndex:mBreakChar];
            
            
            //calculate width (total width - so we know, it should break!
            mPartOfTextStringWidth = [mPartOfTextString sizeWithFont:self.font constrainedToSize:CGSizeMake(9999, 9999)].width;
            
            
            //this means that it will not break
            if(mPartOfTextStringWidth < self.frame.size.width-1)
            {
                mSpaceChar = i;
            }
            else //it breaks!!!!
            {
                //in case a word is longer than label width - disable underlines.
                if(mSpaceChar == mBreakChar-1)
                {
                    mPartOfTextString = @"";
                }
                else
                {	
                    //get string from last break char to last space char
                    mPartOfTextString = [[mTotalTextString substringToIndex:mSpaceChar] substringFromIndex:mBreakChar];
                }
                
                //calculate precise width
                mPartOfTextStringWidth = [mPartOfTextString sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 9999)].width;
                
                //--- set extra space from beginning
                if(self.textAlignment == NSTextAlignmentCenter)
                {
                    extraSpaceFromBeginning = (self.frame.size.width-mPartOfTextStringWidth)/2;
                }
                else if(self.textAlignment == NSTextAlignmentRight)
                {
                    extraSpaceFromBeginning = self.frame.size.width-mPartOfTextStringWidth;
                }
                //===
                
                CGContextMoveToPoint(context, extraSpaceFromBeginning, lineHeight * mCurrentLine - 1 + self.underlineOffset + topOffset);
                
                CGContextAddLineToPoint(context, extraSpaceFromBeginning + mPartOfTextStringWidth, lineHeight * mCurrentLine - 1 + self.underlineOffset + topOffset);
                
                mCurrentLine++;
                
                mBreakChar = mSpaceChar+1; //break char is last space char +1.
            }
        }
        if(i == [mTotalTextString length]-1)//last line - draw from last break to this char.
        {
            //get string from last break char to last space char
            mPartOfTextString = [[mTotalTextString substringToIndex:i] substringFromIndex:mBreakChar];
            
            
            //calculate precise width
            mPartOfTextStringWidth = [mPartOfTextString sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 9999)].width;
            
            
            //--- set extra space from beginning
            if(self.textAlignment == NSTextAlignmentCenter)
            {
                extraSpaceFromBeginning = (self.frame.size.width-mPartOfTextStringWidth)/2;
            }
            else if(self.textAlignment == NSTextAlignmentRight)
            {
                extraSpaceFromBeginning = self.frame.size.width-mPartOfTextStringWidth;
            }
            //===
            
            CGContextMoveToPoint(context, extraSpaceFromBeginning, lineHeight * mCurrentLine - 1 + self.underlineOffset + topOffset);
            
            CGContextAddLineToPoint(context, extraSpaceFromBeginning + mPartOfTextStringWidth, lineHeight * mCurrentLine - 1 + self.underlineOffset + topOffset);
        }
    }
    //===
    
    
    CGContextStrokePath(context);
}*/

@end
