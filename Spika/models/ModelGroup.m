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

#import "ModelGroup.h"
#import "UserManager.h"
#import "NSDictionary+KeyPath.h"
#import "DatabaseManager.h"

@implementation ModelGroup

@synthesize name = _name;
@synthesize description = _description;
@synthesize password = _password;
@synthesize _id = _id;
@synthesize userId = _userId;
@synthesize _rev = _rev;
@synthesize imageUrl = _imageUrl;
@synthesize thumbImageUrl = _thumbImageUrl;
@synthesize deleted = _deleted;

+(NSDictionary *) toDic:(ModelGroup *)group{
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    [tmpDic setObject:group._id forKey:@"_id"];
    [tmpDic setObject:group._rev forKey:@"_rev"];
    [tmpDic setObject:group.name forKey:@"name"];
    [tmpDic setObject:group.description forKey:@"description"];
    [tmpDic setObject:group.password forKey:@"group_password"];
    [tmpDic setObject:group.userId forKey:@"user_id"];
    [tmpDic setObject:@"group" forKey:@"type"];
    [tmpDic setObject:group.fileId forKey:@"avatar_file_id"];
    [tmpDic setObject:group.categoryId forKey:@"category_id"];
    [tmpDic setObject:group.categoryName forKey:@"category_name"];
    [tmpDic setObject:[NSNumber numberWithBool:group.deleted] forKey:@"deleted"];
    [tmpDic setObject:group.thumbFileId forKey:@"avatar_thumb_file_id"];

    return tmpDic;
    
}

+(NSString *) toJSON:(ModelGroup *)group{
    NSDictionary *tmpDic = [ModelGroup toDic:group];
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:tmpDic
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}

+(ModelGroup *) jsonToObj:(NSString *)strJSON{
    
    NSMutableDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:nil];
    return [ModelGroup dicToObj:tmpDic];
    
}

+(ModelGroup *) dicToObj:(NSDictionary *)dic{
    
    ModelGroup *group = [[ModelGroup alloc] init];
    
    if([dic objectForKey:@"_id"] != nil){
        group._id = [dic objectForKey:@"_id"];
    }
    else{
        group._id = @"";
    }
    
    if([dic objectForKey:@"_rev"] != nil){
        group._rev = [dic objectForKey:@"_rev"];
    }
    else{
        group._rev = @"";
    }

    
    if([dic objectForKey:@"description"] != nil){
        group.description = [dic objectForKey:@"description"];
    }
    else{
        group.description = @"";
    }

    
    if([dic objectForKey:@"name"] != nil){
        group.name = [dic objectForKey:@"name"];
    }
    else{
        group.name = @"";
    }

    
    if([dic objectForKey:@"group_password"] != nil){
        group.password = [dic objectForKey:@"group_password"];
    }
    else{
        group.password = @"";
    }

    
    if([dic objectForKey:@"user_id"] != nil){
        group.userId = [dic objectForKey:@"user_id"];
    }
    else{
        group.userId = @"";
    }
    

    if([dic objectForKey:@"avatar_file_id"] != nil){
        
        if([dic objectForKey:@"avatar_file_id"] != nil){
            NSString *str = [dic objectForKey:@"avatar_file_id"];
            if(str.length > 0){
                group.imageUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_file_id"]];
                group.fileId = [dic objectForKey:@"avatar_file_id"];
            }else{
               group.fileId = @""; 
            }
        }
        
    }else{
        group.fileId = @"";
    }

    if([dic objectForKey:@"category_id"] != nil){
        group.categoryId = [dic objectForKey:@"category_id"];
    }
    else{
        group.categoryId = @"";
    }

    if([dic objectForKey:@"category_name"] != nil && ![[dic objectForKey:@"category_name"] isKindOfClass:[NSNull class]]){
        group.categoryName = [dic objectForKey:@"category_name"];
    }
    else{
        group.categoryName = @"";
    }

    if([dic objectForKey:@"deleted"] != nil){
        group.deleted = [[dic objectForKey:@"deleted"] boolValue];
    }else{
        group.deleted = NO;
    }
    
    if([dic objectForKey:@"avatar_thumb_file_id"] != nil){
        NSString *str = [dic objectForKey:@"avatar_thumb_file_id"];
        if(str.length > 0){
            group.thumbImageUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_thumb_file_id"]];
        }
    }
    
    if ([dic objectForKey:@"avatar_thumb_file_id"]) {
        group.thumbFileId = [dic objectForKey:@"avatar_thumb_file_id"];
    } else {
        group.thumbFileId = @"";
    }
    
    return group;
    
}

#pragma mark - Copy

-(id)copy
{
	ModelGroup *group = [ModelGroup new];
	
	group._id = (_id != nil) ? [_id copy] : nil;
	group._rev = (_rev != nil) ? [_rev copy] : nil;
	group.name = (_name != nil) ? [_name copy] : nil;
	group.password = (_password != nil) ? [_password copy] : nil;
	group.description = (_description != nil) ? [_description copy] : nil;
	group.userId = (_userId != nil) ? [_userId copy] : nil;
	group.imageUrl = (_imageUrl != nil) ? [_imageUrl copy] : nil;
	group.fileId = (_fileId != nil) ? [_fileId copy] : nil;
	group.thumbFileId = (_thumbFileId != nil) ? [_thumbFileId copy] : nil;
	group.categoryId = (_categoryId != nil) ? [_categoryId copy] : nil;
	group.categoryName = (_categoryName != nil) ? [_categoryName copy] : nil;
	group.deleted = _deleted;
	group.thumbImageUrl = (_thumbImageUrl != nil) ? [_thumbImageUrl copy] : nil;
	
	return group;
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:self];
}

#pragma mark - HUAvatarModel

-(NSString *) modelId {
    
    return _id;
}

-(NSString *) imageUrl {
    
    return _imageUrl;
}

-(void) findModelWithCompletion:(CSResultBlock)block {
    
    [ModelGroup findModelWithModelId:self._id completion:block];
    
}

+(void) findModelWithModelId:(NSString *)modelId completion:(CSResultBlock)block{
    
    DMFindOneBlock result = ^(id result) {
        if ([result isKindOfClass:[NSString class]]) {
            result = nil;
        }
        if (block) {
            block(result);
        }
    };
    
    [[DatabaseManager defaultManager] findGroupByID:modelId success:result error:result];
    
}

@end
