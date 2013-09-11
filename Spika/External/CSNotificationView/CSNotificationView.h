//
//  CSNotificationView.h
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

#import <UIKit/UIKit.h>

@interface CSNotificationView : UIView

@property (nonatomic) CGFloat anchorPointZ;

#if NS_BLOCKS_AVAILABLE
@property (nonatomic, copy) void(^touchHandler)(void);
#endif

-(void) showInView:(UIView *)view;

@end

@interface CSNotificationView (CSNotification)

#if NS_BLOCKS_AVAILABLE
+(CSNotificationView *) notificationWithView:(UIView *)view;
+(CSNotificationView *) notificationWithView:(UIView *)view touchHandler:(void(^)(void))block;
+(CSNotificationView *) notificationWithImage:(UIImage *)image;
+(CSNotificationView *) notificationWithImage:(UIImage *)image touchHandler:(void(^)(void))block;
#endif

@end

@interface UIView (CSNotification)

-(void) showNotification:(CSNotificationView *)notificationView;
-(void) showNotification:(CSNotificationView *)notificationView duration:(NSTimeInterval)duration;
-(void) hideNotification;

-(CSNotificationView *) showNotificationWithImage:(UIImage *)image;
-(CSNotificationView *) showNotificationWithView:(UIView *)view touchHandler:(void(^)(void))block;

@end