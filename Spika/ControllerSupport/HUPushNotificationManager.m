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

#import "HUPushNotificationManager.h"
#import "CSGraphics.h"

static HUPushNotificationManager *instance = nil;
static dispatch_queue_t serialQueue = nil;

@interface HUPushNotificationManager ()
@property (nonatomic, strong) NSMutableArray *mNotifications;
@property (nonatomic, strong) UIView *contentView, *notificationView;
@property (nonatomic) BOOL isAnimating, isScheduledForUpdate;
@end

@implementation HUPushNotificationManager

#pragma mark - Initialization

+(HUPushNotificationManager *) defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [HUPushNotificationManager new];
    });
    
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        serialQueue = dispatch_queue_create("com.clover-studio.hookup.PushSerialQueue", NULL);
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    
    return instance;
}

-(id) init {
    
    __block id this;
    
    dispatch_sync(serialQueue, ^{
        this = [super init];
    });
    
    if ((self = this)) {
        self.mNotifications = [NSMutableArray new];
        self.contentViewFrame = CGRectMake(0, 44 + [UIApplication sharedApplication].statusBarFrame.size.height, 320, 60);
        self.contentView = [[UIView alloc] initWithFrame:self.contentViewFrame];
        self.contentView.clipsToBounds = YES;
    }
    
    return self;
}

#pragma mark - Setter

+(void) setDatasource:(id<HUPushNotificationDatasource>)datasource {
    [HUPushNotificationManager defaultManager].datasource = datasource;
}

#pragma mark - Push notification view lifecycle

-(void) addPushNotification:(HUPushNotificationModel *)pushNotification {
    
    [self insertPushNotification:pushNotification atIndex:NSIntegerMax];
}

-(void) insertPushNotification:(HUPushNotificationModel *)pushNotification atIndex:(NSUInteger)index {
    
    if (!pushNotification || ![pushNotification isKindOfClass:[HUPushNotificationModel class]]) {
        return;
    }
    
    __block BOOL needsUpdate = NO;
    dispatch_sync(serialQueue, ^{
    
        if ([self.mNotifications containsObject:pushNotification]) {
            return;
        }
        
        NSInteger idx = index;
        NSInteger count = self.mNotifications.count;
        if (idx > count - 1) {
            needsUpdate = YES;
            [self.mNotifications addObject:pushNotification];
        } else {
            [self.mNotifications insertObject:pushNotification atIndex:index];
        }
        
    });
    
    if (needsUpdate) {
        [self setViewNeedsUpdate];
    }
}

-(void) removePushNotification:(HUPushNotificationModel *)pushNotification {
    
    if (!pushNotification || ![pushNotification isKindOfClass:[HUPushNotificationModel class]]) {
        return;
    }
    
    __block BOOL needsUpdate = NO;
    dispatch_sync(serialQueue, ^{
        
        if ([pushNotification isEqual:self.mNotifications.lastObject]) {
            needsUpdate = YES;
        }
        [self.mNotifications removeObject:pushNotification];
        
    });
    
    if (needsUpdate) {
        [self setViewNeedsUpdate];
    } 
    
}

-(void) setViewNeedsUpdate {
    
    if (_isAnimating) {
        _isScheduledForUpdate = YES;
        return;
    }
    
    if (self.notificationView.superview) {
        [self hidePushNotification];
        return;
    }
    
    __block NSUInteger count = 0;
    dispatch_sync(serialQueue, ^{
        count = self.mNotifications.count;
    });
    
    if (count == 0) {
        [self.contentView removeFromSuperview];
        return;
    }
    
    __block HUPushNotificationModel *model = nil;
    dispatch_sync(serialQueue, ^{
        model = [self.mNotifications lastObject];
    });
    
    self.notificationView = [model loadView:CGRectMakeBoundsWithSize(self.contentViewFrame.size)];
    self.notificationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.notificationView.y -= self.notificationView.height;
    
    self.contentView.height = MIN(self.notificationView.height, self.contentViewFrame.size.height);
    if (!self.contentView.superview) {
        [[self.datasource presentingViewController].view addSubview:self.contentView];
    }
    
    [self.contentView addSubview:self.notificationView];
    
    [self showPushNotification:model];
    
}

-(void) hidePushNotification {
    
    self.isAnimating = YES;
    [UIView animateWithDuration:.25f animations:^{
        self.notificationView.y = -self.notificationView.height;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        [self.notificationView removeFromSuperview];
        [self setViewNeedsUpdate];
    }];
}

-(void) showPushNotification:(HUPushNotificationModel *)model {
    
    self.isAnimating = YES;
    [UIView animateWithDuration:.25f animations:^{
        self.notificationView.y = 0;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (self.isScheduledForUpdate) {
            self.isScheduledForUpdate = NO;
            [self setViewNeedsUpdate];
        }
		
		if (model.hidesAfterTimeInterval != 0.0f) {
			__block HUPushNotificationModel *_model = model;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_model.hidesAfterTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removePushNotification:_model];
            });
		}
    }];
}

#pragma mark - Notifications

-(NSArray *) notifications {
    return [self.mNotifications copy];
}

@end
