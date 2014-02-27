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

#import "ModelRecentActivity.h"
#import "ModelMessage.h"
#import "NSDictionary+KeyPath.h"

#pragma mark ModelRecentActivity

@implementation ModelRecentActivity

+(id) objectWithDictionary:(NSDictionary *)dictionary {
	
	ModelRecentActivity *activity = [ModelRecentActivity new];
	
	activity._id = [dictionary objectForKeyPath:@"_id"];
	activity._rev = [dictionary objectForKeyPath:@"_rev"];
	activity.type = [dictionary objectForKeyPath:@"type"];
	activity.userId = [dictionary objectForKeyPath:@"user_id"];
	activity.categories = [NSMutableArray new];
	
	NSDictionary *activities = [dictionary objectForKeyPath:@"recent_activity"];
	for (NSDictionary *rawActivity in [activities allValues]) {
		
		HUModelActivityCategory *category = [[HUModelActivityCategory alloc] initWithDictionary:rawActivity];
		if (category.notifications.count != 0) {
			[activity.categories addObject:category];
		}
	}
	
	[activity.categories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [[obj1 name] compare:[obj2 name]];
	}];
	
	return activity;
}

-(NSInteger) numberOfTotalActivities {
	
	return [self numberOfActivitiesForTarget:nil];
}

-(NSInteger) numberOfActivitiesForTarget:(id<HUPushNotificationTarget>)target {
	
	NSInteger count = 0;
	
	for (HUModelActivityCategory *category in self.categories) {
		
		for (HUModelActivityNotification *note in category.notifications) {
			
			if (target == nil || [[target targetId] isEqualToString:[note targetId]]) {
				count += note.count;
			}
		}
	}
	
	return count;
	
}

@end

#pragma mark -
#pragma mark - HUModelActivityCategory

@implementation HUModelActivityCategory

-(id) initWithDictionary:(NSDictionary *)dictionary {
	
	if (self = [super init]) {
		
		self.name = [dictionary objectForKeyPath:@"name"];
		self.targetType = [dictionary objectForKeyPath:@"target_type"];
		self.notifications = [NSMutableArray new];
		self.allMessages = [NSMutableArray new];
		
		NSDictionary *notifications = [dictionary objectForKeyPath:@"notifications"];
		for (NSDictionary *rawNote in notifications) {
			
			HUModelActivityNotification *note = [[HUModelActivityNotification alloc] initWithDictionary:rawNote];
			note.category = self;
			[self.notifications addObject:note];
			
			[self.allMessages addObjectsFromArray:note.messages];
		}
		
	}
	
	return self;
}

@end

#pragma mark -
#pragma mark - HUModelActivityNotification

@implementation HUModelActivityNotification

-(id) initWithDictionary:(NSDictionary *)dictionary {
	
	if (self = [super init]) {
		
		self.targetId = [dictionary objectForKeyPath:@"target_id"];
		self.count = [[dictionary objectForKeyPath:@"count"] integerValue];
		self.messages = [NSMutableArray new];
        
		
		NSDictionary *messages = [dictionary objectForKeyPath:@"messages"];
		for (NSDictionary *rawMessage in messages) {
			
			ModelMessage *message = [self messageWithDictionary:rawMessage];
			message.value = self;
			[self.messages addObject:message];
		}
	}
	
	return self;
}

-(ModelMessage *) messageWithDictionary:(NSDictionary *)dictionary {
	
	ModelMessage *message = [ModelMessage new];
	message.from_user_id = [dictionary objectForKeyPath:@"from_user_id"];
	message.body = [dictionary objectForKeyPath:@"message"];
	message.modified = [[dictionary objectForKeyPath:@"modified"] longValue];
    
    if([dictionary objectForKey:@"avatar_thumb_file_id"] != nil) {
        message.avatarThumbUrl =  [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dictionary objectForKey:@"avatar_thumb_file_id"]];
        message.avatarThumbFileId = [dictionary objectForKey:@"avatar_thumb_file_id"];
    }else{
        message.avatarThumbFileId = @"";
        message.avatarThumbUrl = @"";
    }
	
	return message;
}

@end
