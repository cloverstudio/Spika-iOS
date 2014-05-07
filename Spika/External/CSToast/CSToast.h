//
//  CBToast.h
//  KeepSafe
//
//  Created by Chris Beauchamp on 12/2/11.
//  Copyright (c) 2011 Chris Beauchamp. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOAST_LONG  2000
#define TOAST_SHORT 1000

@interface CSToast : NSObject

#pragma mark - Public Static Methods

/* 
 The only method - static - and shows a toast with a given message at either
 a constant (found above) or at a user-defined time (in milliseconds)
 */
+ (void) showToast:(NSString*)msg withDuration:(NSUInteger)durationInMillis;

@end
