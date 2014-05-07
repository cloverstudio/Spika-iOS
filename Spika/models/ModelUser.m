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

#import "ModelUser.h"
#import "NSDictionary+KeyPath.h"
#import "DatabaseManager.h"

@implementation ModelUser

@synthesize name = _name;
@synthesize email = _email;
@synthesize password = _password;
@synthesize gender = _gender;
@synthesize birthday = _birthday;
@synthesize about = _about;
@synthesize onlineStatus = _onlineStatus;
@synthesize _id = _id;
@synthesize _rev = _rev;
@synthesize imageUrl = _imageUrl;
@synthesize thumbImageUrl = _thumbImageUrl;
@synthesize contacts = _contacts;
@synthesize attachmentsOrig = _attachmentsOrig;
@synthesize iOSPushToken = _iOSPushToken;
@synthesize favouriteGroups = _favouriteGroups;

#pragma mark - Initialization

- (id) init {

    if (self = [super init]) {
        
        _contacts = [[NSMutableArray alloc] init];
        _favouriteGroups = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - Serialization

+ (NSDictionary *) objectToDictionary:(ModelUser *)user {

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    if(user == nil)
        return nil;
    
    if(user._id != nil)
        [tmpDic setObject:user._id forKey:@"_id"];
    
    if(user._rev!= nil)
        [tmpDic setObject:user._rev forKey:@"_rev"];
    
    [tmpDic setObject:user.name forKey:@"name"];
    [tmpDic setObject:user.email forKey:@"email"];
    [tmpDic setObject:user.password forKey:@"password"];
    [tmpDic setObject:user.gender forKey:@"gender"];
    [tmpDic setObject:@(user.birthday) forKey:@"birthday"];
    [tmpDic setObject:user.about forKey:@"about"];
	[tmpDic setObject:user.onlineStatus forKey:@"online_status"];
    [tmpDic setObject:user.contacts forKey:@"contacts"];
    [tmpDic setObject:@"user" forKey:@"type"];
    [tmpDic setObject:user.iOSPushToken forKey:@"ios_push_token"];
    [tmpDic setObject:user.fileId forKey:@"avatar_file_id"];
    [tmpDic setObject:user.thumbFileId forKey:@"avatar_thumb_file_id"];
    
    if(user.favouriteGroups != nil)
        [tmpDic setObject:user.favouriteGroups forKey:@"favorite_groups"];

    if(user.attachmentsOrig != nil)
        [tmpDic setObject:user.attachmentsOrig forKey:@"_attachments"];    

    if(user.token) {
        [tmpDic setObject:user.token forKey:@"token"];
    }
    
    [tmpDic setObject:@(user.tokenTimestamp) forKey:@"token_timestamp"];
    [tmpDic setObject:@(user.maxContactNum) forKey:@"max_contact_count"];
    [tmpDic setObject:@(user.maxFavoriteNum) forKey:@"max_favorite_count"];

    return tmpDic;
}

+(NSString *) objectToJson:(ModelUser *)message{
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[ModelUser objectToDictionary:message]
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
    
}

#pragma mark - Autorelease Initializaiton

+ (id) objectWithJson:(NSString *)strJSON{
    
    NSError *error = nil;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:&error];
    
    if (error)
        CSLog(@"%@", [error description]);
    
    return [ModelUser objectWithDictionary:jsonDict];
    
}

+ (id) objectWithDictionary:(NSDictionary *)dic{
    
    ModelUser *user = [[ModelUser alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([dic objectForKey:@"_id"] != nil && ![[dic objectForKey:@"_id"] isEqual:[NSNull null]]){
        user._id = [dic objectForKey:@"_id"];
    }else{
        user._id = @"";
    }
    
    if([dic objectForKey:@"_rev"] != nil){
        user._rev = [dic objectForKey:@"_rev"];
    }else{
        user._rev = @"";
    }
    
    if([dic objectForKey:@"name"] != nil){
        user.name = [dic objectForKey:@"name"];
    }else{

        if([dic objectForKey:@"email"] != nil){
            user.name = [dic objectForKey:@"email"];
        }else{
            user.name = @"";
        }
        
    }
    
    if([dic objectForKey:@"email"] != nil){
        user.email = [dic objectForKey:@"email"];
    }else{
        user.email = @"";
    }
    

    if([dic objectForKey:@"birthday"] != nil && ![[dic objectForKey:@"birthday"] isEqual:@""]){
        user.birthday = [[dic objectForKey:@"birthday"] doubleValue];
    }else{
        user.birthday = 0;
    }
     

    if([dic objectForKey:@"gender"] != nil){
        user.gender = [dic objectForKey:@"gender"];
    }else{
        user.gender = @"";
    }
    if([dic objectForKey:@"about"] != nil){
        user.about = [dic objectForKey:@"about"];
    }else{
        user.about = @"";
    }
	if([dic objectForKey:@"online_status"] != nil){
        user.onlineStatus = [dic objectForKey:@"online_status"];
    }else{
        user.onlineStatus = @"";
    }
    
    
    if([dic objectForKey:@"contacts"] != nil){

        user.contacts = [[NSMutableArray alloc] init];
        
        for(id userId in [dic objectForKey:@"contacts"]){
            [user.contacts addObject:[NSString stringWithFormat:@"%@",userId]];
        }
        
    }
    
    if([dic objectForKey:@"password"] != nil){
        user.password = [dic objectForKey:@"password"];
    }else{
 
        NSString *lastPassword = [defaults objectForKey:UserDefaultLastLoginPass];
        if(lastPassword != nil)
            user.password = lastPassword;
        else
            user.password = @"";
    }
    
    if([dic objectForKey:@"ios_push_token"] != nil){
        user.iOSPushToken = [dic objectForKey:@"ios_push_token"];
    }else{
        
        user.iOSPushToken = @"";
    }
    
    if([dic objectForKey:@"favorite_groups"] != nil){
        //force convert to struing
        
        user.favouriteGroups = [[NSMutableArray alloc] init];
        
        for(id groupId in [dic objectForKey:@"favorite_groups"]){
            [user.favouriteGroups addObject:[NSString stringWithFormat:@"%@",groupId]];
        }

    }
    
    if([dic objectForKey:@"avatar_file_id"] != nil){
        NSString *str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar_file_id"]];
        if(str.length > 0){
            user.imageUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_file_id"]];
        }
    }
    
    if([dic objectForKey:@"avatar_thumb_file_id"] != nil){
        NSString *str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar_thumb_file_id"]];
        if(str.length > 0){
            user.thumbImageUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_thumb_file_id"]];
        }
    }
    
    if ([dic objectForKey:@"token"]) {
        user.token = [dic objectForKey:@"token"];
    } else {

        NSString *lastToken = [defaults objectForKey:UserToken];
        if(lastToken != nil)
            user.token = lastToken;
        else
            user.token = @"";

    }
    
    if ([dic objectForKey:@"token_timestamp"]) {
        user.tokenTimestamp = [[dic objectForKey:@"token_timestamp"] longLongValue];
    } else {
        user.tokenTimestamp = 0;
    }
    
    if ([dic objectForKey:@"token_timestamp"]) {
        user.lastLogin = [[dic objectForKey:@"token_timestamp"] longLongValue];
    } else {
        user.lastLogin = 0;
    }
    
    if ([dic objectForKey:@"avatar_file_id"]) {
        user.fileId = [dic objectForKey:@"avatar_file_id"];
    } else {
        user.fileId = @"";
    }
    
    if ([dic objectForKey:@"avatar_thumb_file_id"]) {
        user.thumbFileId = [dic objectForKey:@"avatar_thumb_file_id"];
    } else {
        user.thumbFileId = @"";
    }
    
    if([dic objectForKey:@"max_contact_count"] != nil && ![[dic objectForKey:@"max_contact_count"] isEqual:@""]){
        user.maxContactNum = [[dic objectForKey:@"max_contact_count"] intValue];
    }else{
        user.maxContactNum = DefaultContactNum;
    }
    
    if([dic objectForKey:@"max_favorite_count"] != nil && ![[dic objectForKey:@"max_favorite_count"] isEqual:@""]){
        user.maxFavoriteNum = [[dic objectForKey:@"max_favorite_count"] intValue];
    }else{
        user.maxFavoriteNum = DefaultFavoriteNum;
    }
    
    return user;
}

-(id) copy {
	return [ModelUser objectWithDictionary:[ModelUser objectToDictionary:self]];
}

#pragma mark - HUPushNotificationTarget

-(NSString *) targetId {
    
    return self._id;
}

-(NSString *) titleTextForUserInfo:(NSDictionary *)userInfo {
    
    return self.name;
}

-(NSString *) bodyTextForUserInfo:(NSDictionary *)userInfo {
    
    return [userInfo objectForKeyPath:@"aps.alert"];
}

-(void) pushNotificationDidPress:(UITapGestureRecognizer *)recognizer {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowUserWall object:self];
}

#pragma mark - HUAvatarModel

-(NSString *) modelId {
    
    return _id;
}

-(NSString *) imageUrl {
    
    return _imageUrl;
}

-(void) findModelWithCompletion:(CSResultBlock)block {
    
    [ModelUser findModelWithModelId:self._id completion:block];
    
}

+(void) findModelWithModelId:(NSString *)modelId completion:(CSResultBlock)block {
    
    DMFindOneBlock result = ^(id result) {
        if ([result isKindOfClass:[NSString class]]) {
            result = nil;
        }
        if (block) {
            
            block(result);
        }
    };
    
    [[DatabaseManager defaultManager] findUserWithID:modelId success:result error:result];
    
}

- (BOOL) isInContact:(ModelUser *)user{
    
    BOOL isExists = NO;
    
    for(int i = 0 ; i < [_contacts count] ; i++){
        if([[_contacts objectAtIndex:i] isEqualToString:user._id]){
            isExists = YES;
            break;
        }
    }
    
    return isExists;
}


- (BOOL) isInFavoriteGroups:(ModelGroup *)group{
    
    BOOL isExists = NO;
    
    if(_favouriteGroups == nil){
        return NO;
    }
    
    if(![_favouriteGroups isKindOfClass:[NSArray class]]){
        return NO;
    }
    
    if(![_favouriteGroups respondsToSelector:@selector(count)])
        return NO;
    
    int count = [_favouriteGroups count];
    int i = 0;
    
    for(i = 0 ; i < count ; i++){
        
        if(i > count)
            break;
        
        NSString *favoriteGroupId = [NSString stringWithFormat:@"%@",[_favouriteGroups objectAtIndex:i]];

        if([favoriteGroupId isEqualToString:group._id]){
            isExists = YES;
            break;
        }
    }
    
    return isExists;
}

@end
