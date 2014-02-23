//
//  AnimatedTransitioning.m
//  CustomTransitionExample
//
//  Created by Blanche Faur on 10/24/13.
//  Copyright (c) 2013 Blanche Faur. All rights reserved.
//

#import "AnimatedTransitioning.h"

@implementation AnimatedTransitioning

//===================================================================
// - UIViewControllerAnimatedTransitioning
//===================================================================

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isPresenting) {
        UIView *inView = [transitionContext containerView];
        UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [inView addSubview:toVC.view];
        
        toVC.view.frame = CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
        toVC.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             toVC.view.transform = CGAffineTransformIdentity;
                             toVC.view.frame = CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];

    }
    else {
        UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        fromVC.view.frame = CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
        fromVC.view.transform = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             fromVC.view.frame = CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
                             fromVC.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}


@end
