//
//  CSNotificationView.m
//  Hugg
//
//  Made by Luka Fajl on 8.4.2013..
//
//  Based on CMNavBarNotificationView
//
//  Modified by Eduardo Pinho on 1/12/13.
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Codeminer42 All rights reserved.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "CSNotificationView.h"
#import "UIView+Extensions.h"
#import <objc/runtime.h>

#define RADIANS(deg) ((deg) * M_PI / 180.0f)

@interface CSNotificationView()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CSNotificationView

#pragma mark - Initialization

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.anchorPointZ = 9; //11.547f;
		self.imageView = [UIImageView new];
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

-(void) dealloc {
    UIGestureRecognizer *recognizer = [self.gestureRecognizers lastObject];
    if (recognizer) {
        [recognizer removeTarget:self action:@selector(didTap:)];
    }
    [self removeGestureRecognizer:recognizer];
}

#pragma mark - Gesture

-(void) didTap:(UITapGestureRecognizer *)recognizer {
    
#if NS_BLOCKS_AVAILABLE
    if (self.touchHandler) {
        self.touchHandler();
    }
#endif
    
}

#pragma mark - View

-(void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
}

-(void) showInView:(UIView *)view {
    
    [view showNotification:self];
    
}

@end

@implementation CSNotificationView (CSNotification)

#pragma mark - Constructors

#if NS_BLOCKS_AVAILABLE
+(CSNotificationView *) notificationWithView:(UIView *)view {
    return [CSNotificationView notificationWithView:view touchHandler:nil];
}

+(CSNotificationView *) notificationWithView:(UIView *)view touchHandler:(void (^)(void))block {

    CSNotificationView *noteView = [[CSNotificationView alloc] initWithFrame:view.bounds];
    noteView.imageView.image = nil;
    view.position = CGPointZero;
    [noteView addSubview:view];
    noteView.touchHandler = block;
    
    return noteView;
}

+(CSNotificationView *) notificationWithImage:(UIImage *)image {
    return [CSNotificationView notificationWithImage:image touchHandler:nil];
}

+(CSNotificationView *) notificationWithImage:(UIImage *)image touchHandler:(void (^)(void))block {
    
    CSNotificationView *view = [[CSNotificationView alloc] initWithFrame:CGRectZero];
    view.imageView.image = image;
    view.touchHandler = block;
    
    return view;
}
#endif

@end

@implementation UIView (CSNotification)

#pragma mark - Notification lifecycle

-(CSNotificationView *) showNotificationWithView:(UIView *)view touchHandler:(void(^)(void))block {
    
    view.size = self.size;
    
    CSNotificationView *aView = [CSNotificationView notificationWithView:view touchHandler:block];
    [self showNotification:aView];
    return aView;
    
}

-(CSNotificationView *) showNotificationWithImage:(UIImage *)image {
    
    CSNotificationView *view = [CSNotificationView notificationWithImage:image];
    [self showNotification:view];
    return view;
    
}

-(void) hideNotification {
    
    [self showNotification:nil];
    
}

-(void) showNotification:(CSNotificationView *)notificationView {
    
    [self showNotification:notificationView duration:0.0f];

}

-(void) showNotification:(CSNotificationView *)notificationView duration:(NSTimeInterval)duration {
    
    if ([self notificationAnimating]) {
        return;
    }
    
    [self setNotificationAnimating:YES];
    
    UIImage *screenshot = [self imageOfView];
    
    if (self.oldImage == nil && notificationView) {
        self.oldImage = screenshot;
    }
    
    UIImageView *viewToRotateOut = nil;
    if (notificationView) {
        viewToRotateOut = [[UIImageView alloc] initWithImage:screenshot];
    } else {
        viewToRotateOut = (UIImageView *)[self previousNotificationView];
    }
    
    UIView *viewToRotateIn = nil;
    if (notificationView && [notificationView isKindOfClass:[CSNotificationView class]]) {
        viewToRotateIn = notificationView;
        [viewToRotateIn setFrame:self.bounds];
        [self setPreviousNotificationView:viewToRotateIn];
		[self setOldAnchorPointZ:notificationView.anchorPointZ];
    } else {
        if (self.oldImage != nil) {
            viewToRotateIn = [[UIImageView alloc] initWithImage:self.oldImage];
        } else {
            viewToRotateOut.alpha = 0;
            viewToRotateIn = [[UIImageView alloc] initWithImage:[self imageOfView]];
            viewToRotateOut.alpha = 1;
        }
    }
    
	CGFloat anchorPointZ = notificationView ? notificationView.anchorPointZ : self.oldAnchorPointZ;
	
    viewToRotateIn.layer.anchorPointZ = anchorPointZ;
    viewToRotateIn.layer.doubleSided = NO;
    viewToRotateIn.layer.zPosition = 50;
    
    CATransform3D viewInStartTransform = CATransform3DMakeRotation(RADIANS(-120), 1.0, 0.0, 0.0);
    viewInStartTransform.m34 = -1.0 / 200.0;
    viewToRotateIn.layer.transform = viewInStartTransform;
    
    viewToRotateOut.layer.anchorPointZ = anchorPointZ;
    viewToRotateOut.layer.doubleSided = NO;
    viewToRotateOut.layer.zPosition = 50;
    
    CATransform3D viewOutEndTransform = CATransform3DMakeRotation(RADIANS(120), 1.0, 0.0, 0.0);
    viewOutEndTransform.m34 = -1.0 / 200.0;
    
    [self addSubview:viewToRotateOut];
    [self addSubview:viewToRotateIn];
    
    UIColor *backgroundColor = self.backgroundColor;
    self.backgroundColor = nil;
    
    void(^animationBlock)(void) = ^{
        viewToRotateIn.layer.transform = CATransform3DIdentity;
        viewToRotateOut.layer.transform = viewOutEndTransform;
    };
    
    void(^finishedBlock)(BOOL finished) = ^(BOOL finished) {
        [viewToRotateOut removeFromSuperview];
        if (![viewToRotateIn isKindOfClass:[CSNotificationView class]]) {
            [viewToRotateIn removeFromSuperview];
//            self.oldImage = nil;
        } else {
//            self.oldImage = nil;
        }
        self.oldImage = nil;
        self.backgroundColor = backgroundColor;
        [self setNotificationAnimating:NO];
    };
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:animationBlock
                     completion:finishedBlock];
    
    if (duration != 0.0f) {
        duration = MIN(0.5f, duration);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideNotification];
        });
    }
}

#pragma mark - Setter

-(void) setOldAnchorPointZ:(CGFloat)anchorPointZ {
	objc_setAssociatedObject(self, @"_oldZ_", @(anchorPointZ), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void) setOldImage:(UIImage *)oldImage {
    objc_setAssociatedObject(self, @"_oldImage_", oldImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void) setPreviousNotificationView:(UIView *)view {
    objc_setAssociatedObject(self, @"_noteView_", view, OBJC_ASSOCIATION_RETAIN);
}

-(void) setNotificationAnimating:(BOOL)notificationAnimating {
    objc_setAssociatedObject(self, @"_noteAnim_", notificationAnimating ? @"YES" : nil, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - Getter

-(CGFloat) oldAnchorPointZ {
	return [objc_getAssociatedObject(self, @"_oldZ_") floatValue];
}

-(UIImage *) oldImage {
    return objc_getAssociatedObject(self, @"_oldImage_");
}

-(UIView *) previousNotificationView {
    return objc_getAssociatedObject(self, @"_noteView_");
}

-(BOOL) notificationAnimating {
    return objc_getAssociatedObject(self, @"_noteAnim_") ? YES : NO;
}

@end