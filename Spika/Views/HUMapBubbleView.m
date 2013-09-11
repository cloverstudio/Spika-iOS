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

#import "HUMapBubbleView.h"


#define CalloutMapAnnotationViewBottomShadowBufferSize 6.0f
#define CalloutMapAnnotationViewContentHeightBuffer 8.0f
#define CalloutMapAnnotationViewHeightAboveParent 2.0f

@interface HUMapBubbleView(){
        CGRect _endFrame;
}

@property (nonatomic) CGRect endFrame;



@end

@implementation HUMapBubbleView
@synthesize endFrame = _endFrame;
@synthesize offsetFromParent = _offsetFromParent;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseId{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseId];
    if (self){
        UILabel *annotationTitle = [[UILabel alloc] initWithFrame:CGRectMake(45, 8, 190, 20)];
        annotationTitle.text = [annotation.title uppercaseString];
        annotationTitle.textColor = [UIColor colorWithRed:51.0/256 green:51.0/256 blue:51.0/256 alpha:1];
        annotationTitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:10];
        annotationTitle.backgroundColor=[UIColor clearColor];
        [self addSubview:annotationTitle];
        UILabel *annotationSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(45, 20, 190, 20)];
        annotationSubtitle.text = annotation.subtitle;
        annotationSubtitle.textColor = [UIColor colorWithRed:102.0/256 green:102.0/256 blue:102.0/256 alpha:1];
        annotationSubtitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:10];
        annotationSubtitle.backgroundColor=[UIColor clearColor];
        [self addSubview:annotationSubtitle];
        self.image=[UIImage imageNamed:@"location_bubble.png"];
    }
    
    return self;
}


- (CGFloat)xTransformForScale:(CGFloat)scale {
	CGFloat xDistanceFromCenterToParent = self.endFrame.size.width / 2 - [self relativeParentXPosition];
	return (xDistanceFromCenterToParent * scale) - xDistanceFromCenterToParent;
}

- (CGFloat)yTransformForScale:(CGFloat)scale {
	CGFloat yDistanceFromCenterToParent = (((self.endFrame.size.height) / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize + CalloutMapAnnotationViewHeightAboveParent);
	return yDistanceFromCenterToParent - yDistanceFromCenterToParent * scale;
}

- (CGFloat)relativeParentXPosition {
	CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin
											 fromView:self.parentAnnotationView.superview];
	return parentOrigin.x + self.offsetFromParent.x;
}


#pragma mark - Animations
- (void)animateIn {
	self.endFrame = self.frame;
	CGFloat scale = 0.001f;
//	self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    self.scale = CGSizeMake(scale, scale);
	[UIView beginAnimations:@"animateIn" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.075];
	[UIView setAnimationDidStopSelector:@selector(animateInStepTwo)];
	[UIView setAnimationDelegate:self];
	scale = 1.1;
	self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
	[UIView commitAnimations];
}

- (void)animateInStepTwo {
	[UIView beginAnimations:@"animateInStepTwo" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDidStopSelector:@selector(animateInStepThree)];
	[UIView setAnimationDelegate:self];
	
	CGFloat scale = 0.95;
    self.scale = CGSizeMake(scale, scale);
//	self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
	
	[UIView commitAnimations];
}

- (void)animateInStepThree {
	[UIView beginAnimations:@"animateInStepThree" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.075];
	
	CGFloat scale = 1.0;
    self.scale = CGSizeMake(scale, scale);
//	self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
	
	[UIView commitAnimations];
}

- (void)didMoveToSuperview {
	//[self adjustMapRegionIfNeeded];
	[self animateIn];
}
 



@end
