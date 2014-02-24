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

#import "HUBaseModel.h"
#import "HUPushNotificationManager.h"

#define kUserOnlineStatusKey	@"online"
#define kUserAwayStatusKey		@"away"
#define kUserBusyStatusKey		@"busy"
#define kUserOfflineStatusKey	@"offline"

@interface ModelUser : HUBaseModel <HUPushNotificationTarget>

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *_rev;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *about;
@property (strong, nonatomic) NSString *onlineStatus;
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *thumbImageUrl;
@property (strong, nonatomic) NSString *iOSPushToken;
@property (strong, nonatomic) NSString *fileId;
@property (strong, nonatomic) NSString *thumbFileId;
@property (strong, nonatomic) NSDictionary *attachmentsOrig;
@property (strong, nonatomic) NSMutableArray *favouriteGroups;
@property (copy, nonatomic) NSString *token;

@property (nonatomic) long long tokenTimestamp;
@property (nonatomic) long birthday;
@property (nonatomic) long lastLogin;
@property (readwrite) int maxContactNum;
@property (readwrite) int maxFavoriteNum;


//+(NSDictionary *) toDic:(ModelUser *)user;
//+(NSString *) toJSON:(ModelUser *)user;
//+(ModelUser *) jsonToObj:(NSString *)strJSON;
//+(ModelUser *) dicToObj:(NSDictionary *)dic;

#pragma mark - Initialization
//-(ModelUser *) initWithModelUser:(ModelUser *)user;

- (BOOL) isInContact:(ModelUser *)user;
- (BOOL) isInFavoriteGroups:(ModelGroup *)group;

@end
