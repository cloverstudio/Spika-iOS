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

#import "DatabaseManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Utils.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+KeyPath.h"
#import "NSString+MD5.h"
#import "UserManager.h"
#import "CSToast.h"
#import "AFJSONRequestOperation.h"
#import "ModelComment.h"
#import "UIImage+Resize.h"

@implementation DatabaseManager

+(DatabaseManager *) defaultManager {
    
	@synchronized(self) {
    
        static DatabaseManager *_instance = nil;
        
		if (!_instance)
			_instance = [[self alloc] init];
		
		return _instance;
	}
	
	return nil;
}

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        _offlineNotificationModel = [HUOfflinePushNotification new];
    }
    
    return self;
}


#pragma mark - Header 

-(NSMutableDictionary *) setDefaultHeaderValues {
    return [self setHeaderValues:nil];
}

-(NSMutableDictionary *) setHeaderValues:(NSDictionary *)dictionary {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    if (user) {
        [dic setObject:user._id forKey:@"user_id"];
        [dic setObject:user.token forKey:@"token"];
    }
    if (dictionary) {
        [dic addEntriesFromDictionary:dictionary];
    }
    
    [[HUHTTPClient sharedClient] setDefaultHeader:@"user_id" value:user._id];
    [[HUHTTPClient sharedClient] setDefaultHeader:@"token" value:user.token];
    
    return dic;
}


#pragma mark - check methods

-(NSDictionary *) checkUniqueSynchronous:(NSString *) key
                                   value:(NSString *) value{

    
    NSString *escapedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 kCFAllocatorDefault,
                                                                                 (CFStringRef)value, // ←エンコード前の文字列(NSStringクラス)
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",DatabaseURL,key,escapedString]];
    
    NSString *result = [[HUHTTPClient sharedClient] doGetSynchronous:url];
    
    if(result) {
        
        id resultJSON = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
        
        if([resultJSON isKindOfClass:[NSArray class]]) {
            
            NSArray *resultAry = (NSArray *) resultJSON;
            if(resultAry.count > 0) {
                return [resultAry objectAtIndex:0];
            }
            else {
                return nil;
            }
        }
        else if([resultJSON isKindOfClass:[NSDictionary class]]) {
            return (NSDictionary *)resultJSON;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

#pragma mark - User Methods


-(NSString *)sendReminderSynchronous:(NSString *)email {

    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?email=%@",DatabaseURL,ReminderURL,email]];
    
    NSString *result = [[HUHTTPClient sharedClient] doGetSynchronous:url];
    
    if(result != nil)
        return result;
    else
        return nil;
    
}



-(void) loginUserByEmail:(NSString *)email
                password:(NSString *)password
                 success:(DMFindOneBlock)successBlock
                   error:(DMErrorBlock)errorBlock {
    
    NSDictionary *params = @{@"email" : email, @"password" : [Utils MD5:password]};
    
    CSErrorBlock error = ^(NSError *error) {
        if (errorBlock) {
            errorBlock(error.description);
        }
    };
    
    CSResultBlock success = ^(NSDictionary *result) {

        ModelUser *user = [ModelUser objectWithDictionary:result];
        
		//save password and token
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:user.password forKey:UserPassword];
        [defaults setObject:user.token forKey:UserToken];
        [defaults synchronize];
        
        if (user.token && user.tokenTimestamp != 0) {
            
            if (successBlock) {
				
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(user);
                });
            }
        }
        else {
            
            if (errorBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(nil);
                });
            }
        }
    };
    
    [[HUHTTPClient sharedClient] doPost:AuthURL
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:success
                           failureBlock:error
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

- (void)findUserByEmail:(NSString *)email
                success:(DMFindOneBlock)successBlock
                  error:(DMErrorBlock)errorBlock{

    NSString *strUrl = [NSString stringWithFormat:@"findGroup/name/%@", [Utils urlencode:email]];

    
    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                                             
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               NSArray *ary = [responseDictionary objectForKey:@"rows"];
                               
                               if([ary count] > 0){
                                                 
                                   NSDictionary *tmpDic2 = [ary objectAtIndex:0];
                                   if([[[tmpDic2 objectForKey:@"value"] objectForKey:@"type"] isEqual:@"user"]){
                                       
                                       ModelUser *user = [ModelUser objectWithDictionary:[tmpDic2 objectForKey:@"value"]];
                                       successBlock(user);
                                       return;
                                   }
                               }
                               if (successBlock) {
                                   successBlock(nil);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              CSLog(@"%@", [error description]);
                              errorBlock(error.localizedDescription);
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

- (void)createUserByEmail:(NSString *)email
                     name:(NSString *)name
                 password:(NSString *)password
                  success:(DMUpdateBlock)successBlock
                    error:(DMErrorBlock)errorBlock {
    
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:name forKey:@"name"];
        [params setObject:email forKey:@"email"];
        [params setObject:[Utils MD5:password] forKey:@"password"];
        [params setObject:@"user" forKey:@"type"];
        [params setObject:@"online" forKey:@"online_status"];
        [params setObject:@(DefaultContactNum) forKey:@"max_contact_count"];
        [params setObject:@(DefaultFavoriteNum) forKey:@"max_favorite_count"];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"create_user" forKey:@"user_id"];
        [dic setObject:@"" forKey:@"token"];
        
        [[HUHTTPClient sharedClient] setDefaultHeader:@"user_id" value:@"create_user"];
        
        [[HUHTTPClient sharedClient] doPost:@"createUser"
                              operationType:AFJSONParameterEncoding
                                     params:params
                                resultBlock:^(id result) {
                                                  
                                    NSDictionary *responseDictionary = (NSDictionary *)result;
                                    if([[responseDictionary objectForKey:@"ok"] intValue] == 1){
                                        successBlock(YES,nil);
                                        return;
                                    }
                                                  
                                    if (successBlock) {
                                        successBlock(false, @"Failed to create new user.");
                                    }
                                }
                               failureBlock:^(NSError *error) {
                                   
                                   if (errorBlock) {
                                       errorBlock(error.localizedDescription);
                                   }
                               }
                        uploadProgressBlock:nil
                      downloadProgressBlock:nil];
}

- (void)saveUserAvatarImage:(ModelUser *)toUser
                      image:(UIImage *)image
                    success:(DMUpdateBlock)successBlock
                      error:(DMErrorBlock)errorBlock {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[ModelUser objectToDictionary:toUser]];
    
    DMFindOneBlock success = ^(NSDictionary *result) {
        
        if (result) {
            if ([result objectForKey:@"rev"]) {
                toUser._rev = [result objectForKey:@"rev"];
            }
            if (successBlock) {
                successBlock(YES, nil);
            }
        }
        else if (successBlock) {
            successBlock(false, @"Failed to save avatar");
        }
    };
    
    [self saveAvatarImageWithParams:params
                              image:image
                           fileName:UserAvatarImageFileName
                            success:success
                              error:errorBlock];
}

-(void) saveAvatarImageWithParams:(NSMutableDictionary *)params
                            image:(UIImage *)image
                         fileName:(NSString *)fileName
                          success:(DMFindOneBlock)successBlock
                            error:(DMErrorBlock)errorBlock {
    
    [self setDefaultHeaderValues];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSData *imageData = UIImageJPEGRepresentation(image,0.8);
        NSString *returnString = [self uploadFileSynchronously:imageData fliename:@"avatar.jpg"];
        
        UIImage *thumbImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(AvatarThumbNailSize, AvatarThumbNailSize)];
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage,0.8);
        NSString *thumbReturnString = [self uploadFileSynchronously:thumbData fliename:@"avatarThumb.jpg"];
        
        if([returnString rangeOfString:@"error"].location == NSNotFound){
            
            [params setObject:returnString forKey:@"avatar_file_id"];
            [params setObject:thumbReturnString forKey:@"avatar_thumb_file_id"];
            
            [[HUHTTPClient sharedClient] doPost:@"updateUser"
                                  operationType:AFJSONParameterEncoding
                                         params:params
                                    resultBlock:^(id result) {
                                        
                                        NSDictionary *responseDictionary = (NSDictionary *)result;
                                        if([responseDictionary objectForKey:@"_id"]) {
                                                          
                                            if (successBlock) {
                                                successBlock(responseDictionary);
                                            }
                                            return;
                                        }
                                        
                                        if (successBlock) {
                                            successBlock(nil);
                                        }
                                    }
                                   failureBlock:^(NSError *error) {
                                       
                                       if (errorBlock) {
                                           errorBlock(error.localizedDescription);
                                       }
                                   }
                            uploadProgressBlock:nil
                          downloadProgressBlock:nil];
        }
        else {
            
            if (errorBlock) {
                errorBlock(@"Failed to upload");
            }
        }
    });
}

-(NSString *) uploadFileSynchronously:(NSData *) data fliename:(NSString *) filename{
    return [self uploadFileSynchronously:data fliename:filename contentType:@"image/jpeg"];
}

-(NSString *) uploadFileSynchronously:(NSData *) data fliename:(NSString *) filename contentType:(NSString *) strContentType{
    
    // upload image
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HttpRootURL,FileUplaoder];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
        
    // set Content-Type in HTTP header
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add image data
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",strContentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set URL
    [request setURL:[NSURL URLWithString:urlString]];
    
    // now lets make the connection to the web
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    return returnString;
    
}


-(void)findUsers:(DMArrayBlock)successBlock
           error:(DMErrorBlock)errorBlock {
    
    [self findUsersContainingString:nil
                            success:successBlock
                                error:errorBlock];
}

-(void) findUsersContainingString:(NSString*) string
                          fromAge:(NSNumber*) fromAge
                            toAge:(NSNumber*) toAge
                           gender:(HUGender) gender
                          success:(DMArrayBlock) successBlock
                            error:(DMErrorBlock) errorBlock {
    
    NSString *method = [self getURL:@"searchUsers"
                     withParameters:@{
                        @"n"    :   string,
                        @"af"   :   [fromAge stringValue],
                        @"at"   :   [toAge stringValue],
                        @"g"    :   gender
                        }];
    
    [[HUHTTPClient sharedClient] doGet:method
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                              
                               CSLog(@"%@", result);
                               
                               NSMutableArray *arrayOfUsers = [NSMutableArray arrayWithCapacity:[result count]];
                               
                               for (NSDictionary *userDictionary in result) {
                                   
                                   ModelUser *user = [ModelUser objectWithDictionary:userDictionary];
                                   [arrayOfUsers addObject:user];
                               }
                                             
                               NSArray *sortedAry = [arrayOfUsers sortedArrayUsingComparator:^(ModelUser *a, ModelUser *b) {
                                   return [a.name compare:b.name];
                               }];
                                             
                               if (successBlock) {
                                   successBlock(sortedAry);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(NSString*) getURL:(NSString*) url withParameters:(NSDictionary*) parameters {
    NSMutableString *stringURL = [NSMutableString stringWithFormat:@"%@?", url];
    for (NSString *key in parameters.allKeys) {
        [stringURL appendFormat:@"%@=%@&", key, parameters[key]];
    }
    return [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void) findUsersContainingString:(NSString *)string
                          success:(DMArrayBlock)successBlock
                            error:(DMErrorBlock)errorBlock {
    
    NSMutableArray *aryUsers = [[NSMutableArray alloc] init];
    
    NSString *strUrl = [NSString stringWithFormat:@"_design/app/_view/find_user_by_email"];
    
    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               NSArray *ary = [responseDictionary objectForKey:@"rows"];
                                             
                               if (string) {
                                   //retrieve object you want to compare
                                   id(^objectBlock)(NSDictionary *rawDictionary) = ^id(NSDictionary *rawDictionary) {
                                       return [rawDictionary objectForKeyPath:@"value.name"];
                                   };
                                                 
                                   //do the comparison in this block
                                   BOOL(^compareBlock)(id obj, id value) = ^BOOL(NSString *object, NSString *value) {
                                       return [object rangeOfString:value].location != NSNotFound;
                                   };
                                   
                                   ary = [ary arrayByFilteringObjectsContainingValue:string
                                                                              object:objectBlock
                                                                          usingBlock:compareBlock];
                                   
                               }
                                             
                               for(NSDictionary *row in ary){
                                   
                                   if([row objectForKey:@"value"] != nil){
                                       ModelUser *user = [ModelUser objectWithDictionary:[row objectForKey:@"value"]];
                                       [aryUsers addObject:user];
                                   }
                               }
                               if (successBlock) {
                                   successBlock(aryUsers);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

- (void)reloadUser:(ModelUser *)user
           success:(DMFindOneBlock)successBlock
             error:(DMErrorBlock)errorBlock{
    
    [self findUserWithID:user._id
                 success:successBlock
                     error:errorBlock];
    
}

- (void)findUserWithID:(NSString *)userId
               success:(DMFindOneBlock)successBlock
                 error:(DMErrorBlock)errorBlock{
        
    NSString *strUrl = [NSString stringWithFormat:@"findUser/id/%@", userId];

    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
						 operationType:AFJSONParameterEncoding
						   resultBlock:^(id result) {
                                             
                               NSDictionary *responseDictionary = (NSDictionary *)result;
		
                               if ([[responseDictionary objectForKey:@"type"] isEqual:@"user"]) {
                                   ModelUser *user = [ModelUser objectWithDictionary:responseDictionary];
                                   if (successBlock) {
                                       successBlock(user);
                                   }
                               }
                               else {
                                   if (successBlock) {
                                       successBlock(nil);
                                   }
                               }
                           }
                          failureBlock:^(NSError *error) {
                              errorBlock(error.localizedDescription);
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(void)findUserByName:(NSString *)userName
              success:(DMFindOneBlock)successBlock
                error:(DMErrorBlock)errorBlock{

    NSString *strUrl = [NSString stringWithFormat:@"findGroup/name/%@", [Utils urlencode:userName]];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
						 operationType:AFJSONParameterEncoding
						   resultBlock:^(id result) {
         
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               NSArray *rows = [responseDictionary objectForKey:@"rows"];
                               if(rows && rows.count > 0){
             
                                   ModelUser *user = [ModelUser objectWithDictionary:[[rows objectAtIndex:0] objectForKey:@"value"]];
                                   if (successBlock) {
                                       successBlock(user);
                                   }
                               }
                               else {
                                   if (successBlock) {
                                       successBlock(nil);
                                   }
                               }
                           }
                          failureBlock:^(NSError *error) {
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

- (void) findUserListByGroupID:(NSString *)groupId
                         count:(int)count
                        offset:(int)offset
                       success:(DMArrayPagingBlock)successBlock
                         error:(DMErrorBlock)errorBlock
{
    NSString *strUrl = [NSString stringWithFormat:@"groupUsers/%@/%d/%d", groupId, count, offset];
    [self setDefaultHeaderValues];
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
        
                               NSDictionary *dictionary  = result;
                               NSInteger totalResults = [dictionary[@"count"] integerValue];
                               NSArray *arrayUsers = dictionary[@"users"];
                               NSMutableArray *arrayModel = [NSMutableArray arrayWithCapacity:arrayUsers.count];
                               for (NSDictionary *dict in arrayUsers) {
                                   ModelUser *user = [ModelUser objectWithDictionary:dict];
                                   [arrayModel addObject:user];
                               }
        
                               if (successBlock) {
                                   successBlock(arrayModel, totalResults);
                               }
                               if (errorBlock) {
                                   errorBlock(nil);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              if (errorBlock) {
                                  errorBlock([error localizedDescription]);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
    
}

-(void) findUserContactList:(ModelUser *)user
                    success:(DMFindOneBlock)successBlock
                      error:(DMErrorBlock)errorBlock {
    
    if(user==nil)
        return;
    
    NSAssert1([user isKindOfClass:[ModelUser class]], @"You have provided %@ instead ModelUser!",NSStringFromClass([user class]));
    NSAssert(successBlock, @"You must provide successBlock handler!");
    
    NSMutableArray *users = [NSMutableArray new];
    
    __block NSInteger i = 0;
    
    void(^success)(id result) = ^(id result) {
        if ([result isKindOfClass:[ModelUser class]]) {
            [users addObject:result];
        }
        i++;
        if (i == user.contacts.count) {
            
            NSArray *sortedAry = [users sortedArrayUsingComparator:^(ModelUser *a, ModelUser *b) {
                return [a.name compare:b.name];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(sortedAry);
            });
        }
    };
    
    if (user.contacts.count == 0) {
        successBlock(@[]);
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        for (NSString *userId in user.contacts) {
            
            dispatch_sync(queue, ^{
                
                [[DatabaseManager defaultManager] findUserWithID:userId
                                                         success:success
                                                           error:success];
            });
            
        }
        
    });
    
    
    
}

- (void)updateUser:(ModelUser *)toUser
          oldEmail:(NSString *)oldEmail
           success:(DMUpdateBlock)successBlock
             error:(DMErrorBlock)errorBlock {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[ModelUser objectToDictionary:toUser]];
    
    // disable to update email
    [params removeObjectForKey:@"email"];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"updateUser"
						 operationType:AFJSONParameterEncoding
								params:params
						   resultBlock:^(id result) {
                                             
                               NSDictionary *responseDictionary = (NSDictionary *)result;
		
                               if([responseDictionary objectForKey:@"_rev"] != nil) {
			
                                   toUser._rev = [responseDictionary objectForKey:@"_rev"];
                                   
                                   if (successBlock) {
                                       successBlock(YES, nil);
                                   }
                                   return;
                               }
                               if (successBlock) {
                                   successBlock(false, @"Failed to user");
                               }
                           }
						  failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

- (void) updateUser:(ModelUser *)user
             result:(CSResultBlock)resultBlock
              error:(CSErrorBlock)errorBlock {
    
    [self reloadUser:user success:^(ModelUser *latestUserData) {
        
        if(latestUserData != nil)
            user._rev = latestUserData._rev;
        
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[ModelUser objectToDictionary:user]];
        //remove password
        [params removeObjectForKey:@"password"];
        
        [self setDefaultHeaderValues];
        
        [[HUHTTPClient sharedClient] doPost:@"updateUser"
                             operationType:AFJSONParameterEncoding
                                    params:params
                               resultBlock:^(id result) {
                                   
                                   NSDictionary *responseDictionary = (NSDictionary *)result;
                                   
                                   if ([responseDictionary objectForKey:@"rev"]) {
                                       
                                       [[UserManager defaultManager] getLoginedUser]._rev = [responseDictionary objectForKey:@"rev"];
                                   }
                                   
                                   if (resultBlock) {
                                       resultBlock(result);
                                   }
                               }
                              failureBlock:errorBlock
                       uploadProgressBlock:nil
                     downloadProgressBlock:nil];
        
    } error:^(NSString *errorMessage){

        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:errorMessage forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
        
        errorBlock(error);
        
    }];
}

- (void)updateUserAddRemoveContacts:(ModelUser *)user
                          contactId:(NSString *)contactId
                            success:(DMUpdateBlock)successBlock
                              error:(DMErrorBlock)errorBlock{
    
    if ([user.contacts containsObject:contactId]) {
        
        NSDictionary *params = @{@"user_id":contactId};
        
        [[HUHTTPClient sharedClient] doPost:@"removeContact"
                              operationType:AFJSONParameterEncoding
                                     params:params
                                resultBlock:^(id result) {
                                    
                                    NSDictionary *responseDictionary = (NSDictionary *)result;
                                    ModelUser *user = [ModelUser objectWithDictionary:responseDictionary];
                                    [[UserManager defaultManager] setLoginedUser:user];
                                    
                                    if (successBlock) {
                                        successBlock(YES,result);
                                    }
                                }
         
                               failureBlock:^(NSError *error) {}
                        uploadProgressBlock:nil
                      downloadProgressBlock:nil];
    }
    else {
        
        
        NSDictionary *params = @{@"user_id":contactId};
        
        [[HUHTTPClient sharedClient] doPost:@"addContact"
                              operationType:AFJSONParameterEncoding
                                     params:params
                                resultBlock:^(id result) {
                                    
                                    NSDictionary *responseDictionary = (NSDictionary *)result;
                                    ModelUser *user = [ModelUser objectWithDictionary:responseDictionary];
                                    [[UserManager defaultManager] setLoginedUser:user];
                                    
                                    if (successBlock) {
                                        successBlock(YES,result);
                                    }
                                }
                               failureBlock:^(NSError *error) {}
                        uploadProgressBlock:nil
                      downloadProgressBlock:nil];
    }
}

- (void)saveUserPushNotificationToken:(ModelUser *)toUser
                                token:(NSString *)token
                              success:(DMUpdateBlock)successBlock
                                error:(DMErrorBlock)errorBlock {
    
    toUser.iOSPushToken = token;
    toUser.onlineStatus = @"online";
    
    [self updateUser:toUser
              result:^(id result) {
                  
                  NSDictionary *responseDictionary = (NSDictionary *)result;
                  
                  if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                      
                      successBlock(YES,nil);
                      return;
                  }
                  
                  successBlock(false, @"Failed to save token.");
                  return;
              }
               error:^(NSError *error) {
                   errorBlock(error.localizedDescription);
               }];
}

-(void)updatePassword:(ModelUser *)toUser
          newPassword:(NSString *)password
              success:(DMUpdateBlock)successBlock
                error:(DMErrorBlock)errorBlock{
    

    toUser.password = password;
    
    [self updateUser:toUser
              result:^(id result) {
                  
                  NSDictionary *responseDictionary = (NSDictionary *)result;
                  
                  if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                      
                      successBlock(YES,nil);
                      return;
                  }
                  
                  errorBlock(@"Failed to save password.");
                  return;
              }
               error:^(NSError *error) {
                   errorBlock(error.localizedDescription);
               }];

    
    
}
#pragma mark - Group Methods

- (void)loadGroups:(DMArrayBlock)successBlock
             error:(DMErrorBlock)errorBlock {
    
    NSString *strUrl = [NSString stringWithFormat:@"_design/app/_view/find_group_by_name"];
    
    NSMutableArray *groupsArray = [NSMutableArray array];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                                       operationType:AFJSONParameterEncoding
                                         resultBlock:^(id result) {
                                             
                                             NSDictionary *responseDictionary = (NSDictionary *)result;
                                             
                                             NSArray *ary = [responseDictionary objectForKey:@"rows"];
                                             
                                             for(NSDictionary *row in ary){
                                                 
                                                 if([row objectForKey:@"value"] != nil){
                                                     ModelGroup *group = [ModelGroup dicToObj:[row objectForKey:@"value"]];
                                                     [groupsArray addObject:group];
                                                 }
                                             }
                                             
                                             if (successBlock) {
                                                 successBlock(groupsArray);
                                             }
                                         }
                                        failureBlock:^(NSError *error) {
                                            
                                            if (errorBlock) {
                                                errorBlock(error.localizedDescription);
                                            }
                                        }
                                 uploadProgressBlock:nil
                               downloadProgressBlock:nil];
}

- (void)findGroupByName:(NSString *)name
                success:(DMFindOneBlock)successBlock
                  error:(DMErrorBlock)errorBlock {
    
    NSString *url = [NSString stringWithFormat:@"searchGroups/name/%@",name];
    
    [[HUHTTPClient sharedClient] doGet:url
                                       operationType:AFJSONParameterEncoding
                                         resultBlock:^(id result) {
                                             
                                             NSArray *aryResult = (NSArray *)result;
                                             NSMutableArray *aryGroup = [[NSMutableArray alloc] initWithCapacity:[aryResult count]];

                                             if([result count] > 0){
                                                 
                                                 for(int i = 0 ; i < [aryResult count] ; i++){                                                     
                                                     ModelGroup *group = [ModelGroup dicToObj:[aryResult objectAtIndex:i]];
                                                     [aryGroup addObject:group];
                                                 }
                                                 
                                                 NSArray *sortedAry = [aryGroup sortedArrayUsingComparator:^(ModelGroup *a, ModelGroup *b) {
                                                     return [a.name compare:b.name];
                                                 }];
                                                 
                                                 if (successBlock) {
                                                     successBlock(sortedAry);
                                                 }
                                             }
                                             else {
                                                 
                                                 if (successBlock) {
                                                     successBlock(nil);
                                                 }
                                             }
                                         }
                                        failureBlock:^(NSError *error) {
                                            errorBlock(error.localizedDescription);
                                        }
                                 uploadProgressBlock:nil
                               downloadProgressBlock:nil];
 
}

- (void)createGroup:(NSString *)name
        description:(NSString *)description
           password:(NSString *)password
		 categoryID:(NSString *)categoryID
		 categoryName:(NSString *)categoryName
               ower:(ModelUser *)user
        avatarImage:(UIImage *)avatarImage
            success:(DMUpdateBlock)successBlock
              error:(DMErrorBlock)errorBlock{
    
    NSString *fileId = nil;
    NSString *thumbId = nil;
    
    if(avatarImage != nil){
        NSData *imageData = UIImageJPEGRepresentation(avatarImage,0.8);
        fileId = [self uploadFileSynchronously:imageData fliename:@"avatar.jpg"];
        
        UIImage *thumbImage = [UIImage imageWithImage:avatarImage scaledToSize:CGSizeMake(AvatarThumbNailSize, AvatarThumbNailSize)];
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage,0.8);
        thumbId = [self uploadFileSynchronously:thumbData fliename:@"avatarThumb.jpg"];
    }
    
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:name forKey:@"name"];
    
    if(password.length > 0)
        [params setObject:[Utils MD5:password] forKey:@"group_password"];
    else
        [params setObject:@"" forKey:@"group_password"];
    
    [params setObject:categoryID forKey:@"category_id"];
    [params setObject:categoryName forKey:@"category_name"];
    [params setObject:description forKey:@"description"];
    [params setObject:@"group" forKey:@"type"];
    [params setObject:user._id forKey:@"user_id"];
    [params setObject:[NSNumber numberWithBool:NO] forKey:@"is_favourite"];
    if(fileId != nil)
        [params setObject:fileId forKey:@"avatar_file_id"];
    
    if(thumbId != nil)
        [params setObject:thumbId forKey:@"avatar_thumb_file_id"];
    
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"createGroup"
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(id result) {
                                
                                NSDictionary *responseDictionary = (NSDictionary *)result;
                                
                                if([[responseDictionary objectForKey:@"ok"] intValue] == 1){
                                    
                                    if (successBlock) {
                                        successBlock(YES,result);
                                    }
                                    return;
                                }
                                
                                if (successBlock) {
                                    successBlock(false, @"Failed to create new group.");
                                }
                            }
                           failureBlock:^(NSError *error) {
                               errorBlock(error.localizedDescription);
                           }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

- (void)findGroupByID:(NSString *)groupId
               success:(DMFindOneBlock)successBlock
                 error:(DMErrorBlock)errorBlock{
    
    NSString *strUrl = [NSString stringWithFormat:@"findGroup/id/%@", groupId];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                                       operationType:AFJSONParameterEncoding
                                         resultBlock:^(id result) {
                                             
                                             NSDictionary *responseDictionary = (NSDictionary *)result;
                                             
                                             if ([[responseDictionary objectForKey:@"type"] isEqual:@"group"]) {
                                                 ModelGroup *group = [ModelGroup dicToObj:responseDictionary];
                                                 
                                                 if (successBlock) {
                                                     successBlock(group);
                                                 }
                                             }
                                             else {
                                                 if (successBlock) {
                                                     successBlock(nil);
                                                 }
                                             }
                                         }
                                        failureBlock:^(NSError *error) {
                                            errorBlock(error.localizedDescription);
                                        }
                                 uploadProgressBlock:nil
                               downloadProgressBlock:nil];
}

- (void)findGroupsByCategoryId:(NSString *)groupCategoryId
                      success:(DMArrayBlock)successBlock
                        error:(DMErrorBlock)errorBlock{
    
    NSString *strUrl = [NSString stringWithFormat:@"findGroup/categoryId/%@", groupCategoryId];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;

                               NSArray *rows = [responseDictionary objectForKey:@"rows"];
                               
                               if(rows == nil){
                                   if (successBlock) {
                                       successBlock(nil);
                                   }
                                   return;
                               }
                               
                               NSMutableArray *successResult = [[NSMutableArray alloc] init];
                               
                               for(int i = 0; i < rows.count ; i++){
                                   
                                   NSDictionary *rowDic = [rows objectAtIndex:i];
                                   
                                   if([rowDic objectForKey:@"value"]){
                                       ModelGroup *group = [ModelGroup dicToObj:[rowDic objectForKey:@"value"]];
                                       [successResult addObject:group];
                                   }
                               }
                               
                               NSArray *sortedAry = [successResult sortedArrayUsingComparator:^(ModelGroup *a, ModelGroup *b) {
                                   return [a.name compare:b.name];
                               }];
                               
                               if (successBlock) {
                                   successBlock(sortedAry);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
    
}


- (void)removeGroupFromFavorite:(ModelGroup *)group
                    toUser:(ModelUser *)user
                   success:(DMUpdateBlock)successBlock
                     error:(DMErrorBlock)errorBlock{
    

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:group._id forKey:@"group_id"];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"unSubscribeGroup"
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(NSString * result){
                                
                                if (successBlock) {
                                    successBlock(YES,result);
                                }
                            }
                           failureBlock:^(NSError *error) {
                               
                               if (errorBlock) {
                                   errorBlock(error.localizedDescription);
                               }
                           }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
    
    
}

-(void) addGroupNamedToFavorite:(NSString *)groupName
                         toUser:(ModelUser *)user
                        success:(DMUpdateBlock)successBlock
                          error:(DMErrorBlock)errorBlock {
    
    [[DatabaseManager defaultManager] findGroupByName:groupName success:^(id result) {
        
        NSArray *resultAry = (NSArray *) result;
        
        if(resultAry != nil && [resultAry count] > 0){
            
            ModelGroup *group = (ModelGroup *) [result objectAtIndex:0];
            [[DatabaseManager defaultManager] addGroupToFavorite:group toUser:user success:successBlock error:errorBlock];
            
            
        }else{
            
        }
        
     
    } error:errorBlock];
    
}

- (void)addGroupToFavorite:(ModelGroup *)group
                    toUser:(ModelUser *)user
                   success:(DMUpdateBlock)successBlock
                     error:(DMErrorBlock)errorBlock{
    

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:group._id forKey:@"group_id"];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"subscribeGroup"
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(NSString * result){
                                
                                if (successBlock) {
                                    successBlock(YES,result);
                                }
                            }
                            failureBlock:^(NSError *error) {
                                
                                if (errorBlock) {
                                    errorBlock(error.localizedDescription);
                                }
                            }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];

}

- (void)updateGroup:(ModelGroup *)newGroup
        avatarImage:(UIImage *)avatarImage
            success:(DMUpdateBlock)successBlock
              error:(DMErrorBlock)errorBlock{
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(avatarImage != nil){
            NSData *imageData = UIImageJPEGRepresentation(avatarImage,0.8);
            NSString *returnString = [self uploadFileSynchronously:imageData fliename:@"avatar.jpg"];
            if([returnString rangeOfString:@"error"].location == NSNotFound){
                newGroup.fileId = returnString;
            }

            UIImage *thumbImage = [UIImage imageWithImage:avatarImage scaledToSize:CGSizeMake(AvatarThumbNailSize, AvatarThumbNailSize)];
            NSData *thumbData = UIImageJPEGRepresentation(thumbImage,0.8);
            NSString *thumbId = [self uploadFileSynchronously:thumbData fliename:@"avatarThumb.jpg"];
            if([thumbId rangeOfString:@"error"].location == NSNotFound){
                newGroup.thumbFileId = thumbId;
            }
        }
        

        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[ModelGroup toDic:newGroup]];
        
        [self setDefaultHeaderValues];
        
        [[HUHTTPClient sharedClient] doPost:@"updateGroup"
                              operationType:AFJSONParameterEncoding
                                     params:params
                                resultBlock:^(id result) {
                                                 
                                    NSDictionary *responseDictionary = (NSDictionary *)result;
                                                 
                                    if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                                       
                                        if ([responseDictionary objectForKey:@"rev"]) {
                                            newGroup._rev = [responseDictionary objectForKey:@"rev"];
                                        }
                                        
                                        if (successBlock) {
                                            successBlock(YES, nil);
                                        }
                                        return;
                                    }
                                    if (successBlock) {
                                        successBlock(false, @"Failed to save group");
                                    }
                                }
                               failureBlock:^(NSError *error) {
                                                
                                   if (errorBlock) {
                                       errorBlock(error.localizedDescription);
                                   }
                               }
                        uploadProgressBlock:nil
                      downloadProgressBlock:nil];
    });
    
}

- (void)reloadGroup:(ModelGroup *)group
            success:(DMFindOneBlock)successBlock
              error:(DMErrorBlock)errorBlock{
    
    NSString *strUrl = [NSString stringWithFormat:@"findGroup/id/%@", group._id];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                                             
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               ModelGroup *group = [ModelGroup dicToObj:responseDictionary];
                               
                               if (successBlock) {
                                   successBlock(group);
                               }
                               return;
                           }
                          failureBlock:^(NSError *error) {
                                            
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

- (void)deleteGroup:(ModelGroup *)newGroup
            success:(DMUpdateBlock)successBlock
              error:(DMErrorBlock)errorBlock{
    
    newGroup.deleted = YES;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:newGroup._id forKey:@"_id"];
    
    [self setDefaultHeaderValues];
    

    [[HUHTTPClient sharedClient] doPost:@"deleteGroup"
                         operationType:AFJSONParameterEncoding
                                params:params
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               
                               if([[responseDictionary objectForKey:@"ok"] intValue] == 1){
                                   
                                   void(^successBlockRemoveFav)(BOOL success, NSString *error) = ^(BOOL success, NSString *error) {
                                       
                                       if(success){
                                           if (successBlock) {
                                               successBlock(YES,nil);
                                           }
                                       }
                                       else {
                                           if (successBlock) {
                                               successBlock(false, @"Failed to unsubscribe group");
                                           }
                                       }
                                   };
                                   
                                   void(^errorBlockRemoveFav)(id result) = ^(NSString *errStr){
                                       successBlock(false, @"Failed to unsubscribe group");
                                   };
                                   
                                   [[DatabaseManager defaultManager]
                                    removeGroupFromFavorite:newGroup
                                    toUser:[[UserManager defaultManager] getLoginedUser]
                                    success:successBlockRemoveFav error:errorBlockRemoveFav];

                                   return;
                               }
                               
                               if (successBlock) {
                                   successBlock(false, @"Failed to delete group");
                               }
                               return;
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(void)getUsersInGroup:(ModelGroup *)group
               success:(DMFindOneBlock)successBlock
                 error:(DMErrorBlock)errorBlock{
    
    
    
    
}

-(void) findUserFavoriteGroups:(ModelUser *)user
                       success:(DMFindOneBlock)successBlock
                         error:(DMErrorBlock)errorBlock {
    
    NSAssert1([user isKindOfClass:[ModelUser class]], @"You have provided %@ instead ModelUser!",NSStringFromClass([user class]));
    NSAssert(successBlock, @"You must provide successBlock handler!");
    
    NSMutableArray *groups = [NSMutableArray new];
    
    __block NSInteger i = 0;
    
    void(^success)(id result) = ^(id result) {
        if ([result isKindOfClass:[ModelGroup class]]) {
            [groups addObject:result];
        }
        i++;
        if (i == user.favouriteGroups.count) {
            
            NSArray *sortedAry = [groups sortedArrayUsingComparator:^(ModelUser *a, ModelUser *b) {
                return [a.name compare:b.name];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(sortedAry);
            });
        }
    };
    
    if (user.favouriteGroups.count == 0) {
        successBlock(@[]);
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        for (NSString *groupId in user.favouriteGroups) {
            
            dispatch_sync(queue, ^{
                
                [self setDefaultHeaderValues];
                
                [[DatabaseManager defaultManager] findGroupByID:groupId
                                                        success:success
                                                          error:success];
            });
            
        }
        
    });
    
    
    
}

- (void)saveGroupAvatarImage:(ModelGroup *)toGroup
                       image:(UIImage *)image
                     success:(DMUpdateBlock)successBlock
                       error:(DMErrorBlock)errorBlock {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[ModelGroup toDic:toGroup]];
    
    DMFindOneBlock success = ^(NSDictionary *result) {
        
        if (result) {
            if ([result objectForKey:@"rev"]) {
                toGroup._rev = [result objectForKey:@"rev"];
            }
            successBlock(YES, nil);
        } else {
            successBlock(false, @"Failed to save avatar");
        }
        
    };
    
    [self saveAvatarImageWithParams:params
                              image:image
                           fileName:GroupAvatarImageFileName
                            success:success
                              error:errorBlock];
}

-(void) findGroupCategories:(DMArrayBlock)successBlock
                      error:(DMErrorBlock)errorBlock{
    
    NSString *strUrl = @"findAllGroupCategory";
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               
                               NSArray *rows = [responseDictionary objectForKey:@"rows"];
                               
                               NSMutableArray *resultAry = [[NSMutableArray alloc] init];
                               
                               for(int i = 0 ; i < rows.count ; i++){
                                   
                                   NSDictionary *dic1 = [rows objectAtIndex:i];
                                   if(dic1 != nil){
                                       ModelGroupCategory *gc = [ModelGroupCategory dicToObj:[dic1 objectForKey:@"value"]];
                                       [resultAry addObject:gc];
                                   }
                               }
                               
                               if (successBlock) {
                                   successBlock(resultAry);
                               }
                               return;
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
    
    
}

-(void)findOneGroupByName:(NSString *)groupName
              success:(DMFindOneBlock)successBlock
                error:(DMErrorBlock)errorBlock{

    NSString *strUrl = [NSString stringWithFormat:@"findGroup/name/%@", [Utils urlencode:groupName]];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
						 operationType:AFJSONParameterEncoding
						   resultBlock:^(id result)
     {
         
         NSDictionary *responseDictionary = (NSDictionary *)result;
         
         NSArray *rows = [responseDictionary objectForKey:@"rows"];
         if(rows != nil && rows.count > 0){
             
             ModelGroup *group = [ModelGroup dicToObj:[[rows objectAtIndex:0] objectForKey:@"value"]];
             if (successBlock) {
                 successBlock(group);
             }
             
             
         }
         else {
             if (successBlock) {
                 successBlock(nil);
             }
         }
         
     } failureBlock:^(NSError *error) {
         errorBlock(error.localizedDescription);
     }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
    
    
}

#pragma mark - Message Methods

- (void)sendTextMessage:(int) targetType
                 toUser:(ModelUser *)toUser
                toGroup:(ModelGroup *)toGroup
                   from:(ModelUser *)fromUser
                message:(NSString *)message
                success:(DMUpdateBlock)successBlock
                  error:(DMErrorBlock)errorBlock{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"message" forKey:@"type"];
   
    [params setObject:MessageTypeText forKey:@"message_type"];
    
    [params setObject:message forKey:@"body"];
 
    [params setObject:fromUser._id forKey:@"from_user_id"];
    
    [params setObject:fromUser.name forKey:@"from_user_name"];
    
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
    
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
    
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
    
    NSString *apiName = @"sendMessageToUser";
    
    if(targetType == TargetTypeUser) {
    
        [params setObject:toUser.name forKey:@"to_user_name"];
        
        [params setObject:toUser._id forKey:@"to_user_id"];
        
        [params setObject:@"user" forKey:@"message_target_type"];
        
    }
    
    if(targetType == TargetTypeGroup) {
        
        apiName = @"sendMessageToGroup";

        [params setObject:toGroup.name forKey:@"to_group_name"];
        
        [params setObject:toGroup._id forKey:@"to_group_id"];
        
        [params setObject:@"group" forKey:@"message_target_type"];
    }
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:apiName
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(id result) {
                                              
                                NSDictionary *responseDictionary = (NSDictionary *)result;
                                
                                if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                                    
                                    if (successBlock) {
                                        successBlock(YES, nil);
                                    }
                                    
                                    return;
                                }
                                
                                if (successBlock) {
                                    successBlock(false, @"Failed to send message");
                                }
                            }
                           failureBlock:^(NSError *error) {
                               
                               if (errorBlock) {
                                   errorBlock(error.localizedDescription);
                               }
                           }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

-(void)findUserMessagesByUser:(ModelUser *) user
                      partner:(ModelUser *) partner
                         page:(int) page
                      success:(DMArrayBlock)successBlock
                        error:(DMErrorBlock)errorBlock{
    
    NSMutableArray *modelMessages = [[NSMutableArray alloc] init];
    
    int skip = page * PagingMessageFetchNum;
    
    NSString *url = [NSString stringWithFormat:@"userMessages/%@/%d/%d",
                       partner._id,
                       PagingMessageFetchNum,
                       skip];
    
    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] doGet:url
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               NSArray *messages = [responseDictionary objectForKey:@"rows"];
                                             
                               for(NSDictionary *row in messages){
                                   if([row objectForKey:@"value"] != nil){
                                       
                                       ModelMessage *messages = [ModelMessage dicToObj:[row objectForKey:@"value"]];
                                       [modelMessages addObject:messages];
                                   }
                               }
                                             
                               if (successBlock) {
                                   successBlock(modelMessages);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}


-(void)findMessagesByGroup:(ModelGroup *) group
                      page:(int) page
                   success:(DMArrayBlock)successBlock
                     error:(DMErrorBlock)errorBlock{
        
    int skip = page * PagingMessageFetchNum;
    
    NSString *strUrl = [NSString stringWithFormat:@"groupMessages/%@/%d/%d",
                     group._id,
                     PagingMessageFetchNum,
                     skip];

    
    NSMutableArray *messagesArray = [NSMutableArray array];
    __block ModelMessage *message = nil;

    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                                             
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               NSArray *rows = [responseDictionary objectForKey:@"rows"];
                                             
                               for(NSDictionary *row in rows){
                                   
                                   if([row objectForKey:@"value"] != nil){
                                       
                                       message = [ModelMessage dicToObj:[row objectForKey:@"value"]];
                                       [messagesArray addObject:message];
                                   }
                               }
                               
                               if (successBlock) {
                                   successBlock(messagesArray);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

- (void)reloadMessage:(ModelMessage *)message
              success:(DMFindOneBlock)successBlock
                error:(DMErrorBlock)errorBlock {
    
    NSString *strUrl = [NSString stringWithFormat:@"findMessageById/%@", message._id];

    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                                             
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               
                               ModelMessage *message = [ModelMessage dicToObj:responseDictionary];
                               
                               if (successBlock) {
                                   successBlock(message);
                               }
                           }
                          failureBlock:^(NSError *error) {
                                            
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

#pragma mark - Emoticons

- (void)loadEmoticons:(DMArrayBlock)successBlock
                error:(DMErrorBlock)errorBlock {
    
    NSString *strUrl = [NSString stringWithFormat:@"Emoticons"];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               NSArray *array = [responseDictionary objectForKey:@"rows"];
                                             
                               if (successBlock) {
                                   successBlock(array);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}


#pragma mark - Image Methods

- (void)sendImageMessage:(ModelUser *)toUser
                 toGroup:(ModelGroup *)toGroup
                    from:(ModelUser *)fromUser
                   image:(UIImage *)image
                 success:(DMUpdateBlock)successBlock
                   error:(DMErrorBlock)errorBlock{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"message" forKey:@"type"];
    
    [params setObject:MessageTypeImage forKey:@"message_type"];
    
    [params setObject:@"" forKey:@"body"];
    
    [params setObject:fromUser._id forKey:@"from_user_id"];
   
    [params setObject:fromUser.name forKey:@"from_user_name"];
    
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
    
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
    
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
    
    NSString *apiName = @"sendMessageToUser";
    
    if(toUser != nil) {
        
        [params setObject:toUser.name forKey:@"to_user_name"];
        [params setObject:toUser._id forKey:@"to_user_id"];
        [params setObject:@"user" forKey:@"message_target_type"];
        
    }
    else if(toGroup != nil) {
        apiName = @"sendMessageToGroup";
        [params setObject:toGroup.name forKey:@"to_group_name"];
        [params setObject:toGroup._id forKey:@"to_group_id"];
        [params setObject:@"group" forKey:@"message_target_type"];
    }
    else {
        successBlock(false, @"No recipients set.");
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imageData = UIImageJPEGRepresentation(image,0.8);
        NSString *returnString = [self uploadFileSynchronously:imageData fliename:@"avatar.jpg"];
        
        
        UIImage *thumbImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(ImageMessageThumbSize, ImageMessageThumbSize)];
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage,0.8);
        NSString *thumbId = [self uploadFileSynchronously:thumbData fliename:@"avatarThumb.jpg"];
        
        if([returnString rangeOfString:@"error"].location == NSNotFound){

            [self setDefaultHeaderValues];
            
            [params setObject:returnString forKey:@"picture_file_id"];
            [params setObject:thumbId forKey:@"picture_thumb_file_id"];

            [[HUHTTPClient sharedClient] doPost:apiName
                                  operationType:AFJSONParameterEncoding
                                         params:params
                                    resultBlock:^(id result) {
                                        
                                        NSDictionary *responseDictionary = (NSDictionary *)result;
                                        
                                        if([[responseDictionary objectForKey:@"ok"] intValue] == 1){
                                        
                                            if (successBlock) {
                                                successBlock(YES, nil);
                                            }
                                            return;
                                        }
                                        if (successBlock) {
                                            successBlock(false, @"Failed to send message.");
                                        }
                                        return;
                                    }
                                   failureBlock:^(NSError *error) {
                                                     
                                       if (errorBlock) {
                                           errorBlock(error.localizedDescription);
                                       }
                                   }
                            uploadProgressBlock:nil
                          downloadProgressBlock:nil];
        
        }
        else {
            if (errorBlock) {
                errorBlock(@"Failed to send message.");
            }
        }
    });
}

- (void)postImageComment:(ModelMessage *) message
                  byUser:(ModelUser *)user
                 comment:(NSString *)comment
                 success:(DMUpdateDocumentBlock)successBlock
                   error:(DMErrorBlock)errorBlock{
    
    
    message.modified = [Utils getUTCFormateDateInLong];
    [message addComment:user comment:comment];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:message._id forKey:@"message_id"];
    [params setObject:comment forKey:@"comment"];

    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"sendComment"
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(id result) {
                                
                                NSDictionary *responseDictionary = (NSDictionary *)result;
                                if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                                                 
                                    [self updateModified:message._id success:nil error:nil];
                                                 
                                    if (successBlock) {
                                        successBlock(YES, responseDictionary);
                                    }
                                    return;
                                }
                                if (successBlock) {
                                    successBlock(false, nil);
                                }
                                return;
                            }
                           failureBlock:^(NSError *error) {
                               if (errorBlock) {
                                   errorBlock(error.localizedDescription);
                               }
                           }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

- (void)updateModified:(NSString *)objectID
               success:(DMUpdateDocumentBlock)successBlock
                 error:(DMErrorBlock)errorBlock{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@", objectID];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
          
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               [responseDictionary setValue:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
            
                               [[HUHTTPClient sharedClient] doPost:@""
                                                     operationType:AFJSONParameterEncoding
                                                            params:responseDictionary
                                                       resultBlock:nil
                                                      failureBlock:nil
                                               uploadProgressBlock:nil
                                             downloadProgressBlock:nil];
                           }
                          failureBlock:nil
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

- (void)sendEmoticonMessage:(int) targetType
                     toUser:(ModelUser *)toUser
                    toGroup:(ModelGroup *)toGroup
                       from:(ModelUser *)fromUser
               emoticonData:(NSDictionary *)data
                    success:(DMUpdateBlock)successBlock
                      error:(DMErrorBlock)errorBlock{
    
    NSString *emoticonId = [data objectForKey:@"_id"];
    NSString *emoticonIdentifier = [data objectForKey:@"identifier"];
    NSString *emoticonImageUrl = [Utils generateEmoticonURL:data];
    
    if(emoticonId == nil || emoticonIdentifier == nil || emoticonImageUrl == nil) {
        errorBlock(@"Invalid emoticon data");
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"message" forKey:@"type"];
    
    [params setObject:MessageTypeEmoticon forKey:@"message_type"];
    
    [params setObject:emoticonIdentifier forKey:@"body"];
    
    [params setObject:fromUser._id forKey:@"from_user_id"];
    
    [params setObject:fromUser.name forKey:@"from_user_name"];
    
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
    
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
    
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
    
    NSString *apiName = @"sendMessageToUser";
    
    if(toUser != nil) {
        
        [params setObject:toUser.name forKey:@"to_user_name"];
        [params setObject:toUser._id forKey:@"to_user_id"];
        [params setObject:@"user" forKey:@"message_target_type"];
        
    }
    else if(toGroup != nil){
        apiName = @"sendMessageToGroup";
        [params setObject:toGroup.name forKey:@"to_group_name"];
        [params setObject:toGroup._id forKey:@"to_group_id"];
        [params setObject:@"group" forKey:@"message_target_type"];
        
    }
    else{
        successBlock(false, @"No recipients set.");
    }
    
    [params setObject:emoticonImageUrl forKey:@"emoticon_image_url"];
    
    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] doPost:apiName
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(id result) {
                                              
                                NSDictionary *responseDictionary = (NSDictionary *)result;
                                if([[responseDictionary objectForKey:@"ok"] intValue] == 1){
                                    
                                    if (successBlock) {
                                        successBlock(YES, nil);
                                    }
                                    return;
                                }
                                if (successBlock) {
                                    successBlock(false, @"Failed to send message.");
                                }
                                return;
                            }
                           failureBlock:^(NSError *error) {
                                             
                               if (errorBlock) {
                                   errorBlock(error.localizedDescription);
                               }
                           }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}
 
- (void)loadImage:(NSString *)imageUrl
          success:(DMLoadImageBlock)successBlock
            error:(DMErrorBlock)errorBlock {
        
    if (!imageUrl) {
        return;
    }
    
    if([imageUrl isEqualToString:@""])
        return;
    
    UIImage *image = [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:imageUrl]];


    if (image && successBlock) {
        successBlock(image);
        return;
    }
    

    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] imageFromURL:[NSURL URLWithString:imageUrl]
                                   completion:^(NSURL *imageURL, UIImage *image) {
                                   
                                       if (image && successBlock) {
                                           successBlock(image);
                                           return;
                                       }
                                       else {
                                           if(errorBlock) {
                                               errorBlock(nil);
                                           }
                                           return;
                                       }
                                   }];
}

- (void)loadCategoryIconByName:(NSString *)categoryName
                       success:(DMLoadImageBlock)successBlock
                         error:(DMErrorBlock)errorBlock{
    
    
    void(^errorBlockFindCategories)(id result) = ^(NSString *errStr){
        errorBlock(errStr);
    };
    

    
    void(^successBlockLoadImage)(id result) = ^(UIImage *image){
        
        successBlock(image);
        
    };

    void(^successBlockFindCategories)(id result) = ^(NSArray *groupCategories)
	{
        
        for(ModelGroupCategory *category in groupCategories){
            
            if(category.title == nil)
                continue;
            
            if([category.title isEqualToString:categoryName]){
                
                [[DatabaseManager defaultManager] loadImage:category.imageUrl success:successBlockLoadImage error:errorBlockFindCategories];
                
            }
            
        }
        
    };
    
    [[DatabaseManager defaultManager] findGroupCategories:successBlockFindCategories error:errorBlockFindCategories];
    
}

- (void)loadEmoticons:(NSString *)imageUrl
                toBtn:(CSButton *)button
              success:(DMLoadImageBlock)successBlock
                error:(DMErrorBlock)errorBlock {
    
    UIImage *image = [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:imageUrl]];
    
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
        successBlock(image);
        return;
    }
    
    [self setDefaultHeaderValues];

    [[HUHTTPClient sharedClient] imageFromURL:[NSURL URLWithString:imageUrl]
                                                 completion:^(NSURL *imageURL, UIImage *image) {
                                                     
                                                     if (image) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             
                                                             [button setImage:image forState:UIControlStateNormal];
                                                             successBlock(image);
                                                         });
                                                     }
                                                     else {
                                                         errorBlock(nil);
                                                     }
                                                 }];
}

- (UIImage *) readFromCache:(NSString *)url {
    
    return [[HUHTTPClient sharedClient] imageWithUrl:[NSURL URLWithString:url]];
}

-(void) clearCache {
	
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    for (NSString *filename in fileArray)  {
        [fileMgr removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
    }
    
}

-(void)getCommentsByMessage:(ModelMessage *) message
                       page:(int) page
                    success:(DMArrayBlock)successBlock
                      error:(DMErrorBlock)errorBlock{
    
    int skip = page * PagingMessageFetchNum;
    
    NSString *url = [NSString stringWithFormat:@"comments/%@/%d/%d",
                     message._id,
                     PagingMessageFetchNum,
                     skip];

    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:url
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               
                               NSArray *ary = [responseDictionary objectForKey:@"rows"];
                               NSMutableArray *resultAry = [[NSMutableArray alloc] init];
                               
                               for(int i = 0; i < [ary count] ; i++){
                                   
                                   NSDictionary *tmpDic2 = [ary objectAtIndex:i];
                                   ModelComment *comment = [ModelComment objectWithDictionary:[tmpDic2 objectForKey:@"value"]];
                                   [resultAry addObject:comment];
                                   
                               }
                               if (successBlock) {
                                   successBlock(resultAry);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                              CSLog(@"%@", [error description]);
                              errorBlock(error.localizedDescription);
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(void)getCommentsCountByMessage:(ModelMessage *) message
                    success:(DMFindOneBlock)successBlock
                      error:(DMErrorBlock)errorBlock{
    
    NSString *strUrl = [NSString stringWithFormat:@"commentsCount/%@",message._id];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               NSDictionary *responseDictionary = (NSDictionary *)result;
                               
                               if([responseDictionary objectForKey:@"rows"] != nil){
                                   
                                   if([[responseDictionary objectForKey:@"rows"] count] > 0 && [[responseDictionary objectForKey:@"rows"] objectAtIndex:0] != nil){
                                       
                                       if([[[responseDictionary objectForKey:@"rows"] objectAtIndex:0] objectForKey:@"value"] != nil){
                                       
                                           NSString *number = [NSString stringWithFormat:@"%@",[[[responseDictionary objectForKey:@"rows"] objectAtIndex:0] objectForKey:@"value"]];
                                           if (successBlock) {
                                               successBlock(number);
                                           }
                                           return;
                                       }
                                   }
                               }
                               if (successBlock) {
                                   successBlock(nil);
                               }
                           }
     
                          failureBlock:^(NSError *error) {
                              
                              if (errorBlock) {
                                  errorBlock(error.localizedDescription);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

#pragma mark - Video Methods

-(void)sendVideoMessage:(ModelUser *)toUser
                toGroup:(ModelGroup *)toGroup
                   from:(ModelUser *)fromUser
                fileURL:(NSURL *)videoUrl
                  title:(NSString *)title
                success:(DMUpdateBlock)successBlock
                  error:(DMErrorBlock)errorBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSData *videoData = [NSData dataWithContentsOfFile:videoUrl.path];
        NSString *returnString = [self uploadFileSynchronously:videoData fliename:@"video.mp4" contentType:@"video/mp4"];
            
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:@"message" forKey:@"type"];
        [params setObject:MessageTypeVideo forKey:@"message_type"];
        
        if(title != nil)
            [params setObject:title forKey:@"body"];
        else
            [params setObject:@"" forKey:@"body"];

        [params setObject:fromUser._id forKey:@"from_user_id"];
        [params setObject:fromUser.name forKey:@"from_user_name"];
        [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
        [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
        [params setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
        
        NSString *apiName = @"sendMessageToUser";
        
        if(toUser != nil) {
            
            [params setObject:toUser.name forKey:@"to_user_name"];
            [params setObject:toUser._id forKey:@"to_user_id"];
            [params setObject:@"user" forKey:@"message_target_type"];
        }
        else if(toGroup != nil) {
            apiName = @"sendMessageToGroup";
            [params setObject:toGroup.name forKey:@"to_group_name"];
            [params setObject:toGroup._id forKey:@"to_group_id"];
            [params setObject:@"group" forKey:@"message_target_type"];
        }
        else{        
            successBlock(false, @"No recipients set.");
        }
        
        
        [params setObject:returnString forKey:@"video_file_id"];
        
        [self setDefaultHeaderValues];
        
        [[HUHTTPClient sharedClient] doPost:apiName
                              operationType:AFJSONParameterEncoding
                                     params:params
                                resultBlock:^(id result) {
                                    
                                    NSDictionary *responseDictionary = (NSDictionary *)result;
                                    
                                    if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                                                      
                                        if (successBlock) {
                                            successBlock(YES, nil);
                                        }
                                        return;
                                    }
                                    if (successBlock) {
                                        successBlock(false, @"Failed to send message");
                                    }
                                    return;
                                }
                               failureBlock:^(NSError *error) {
                                   if (errorBlock) {
                                       errorBlock(error.localizedDescription);
                                   }
                               }
                        uploadProgressBlock:nil
                      downloadProgressBlock:nil];
    });
}

#pragma mark - Audio Methods

- (void)sendVoiceMessage:(ModelUser *)toUser
                 toGroup:(ModelGroup *)toGroup
                    from:(ModelUser *)fromUser
                 fileURL:(NSURL *)videoUrl
                   title:(NSString *)title
                 success:(DMUpdateBlock)successBlock
                   error:(DMErrorBlock)errorBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *voiceData = [NSData dataWithContentsOfFile:videoUrl.path];
        NSString *returnString = [self uploadFileSynchronously:voiceData fliename:@"voice.wav" contentType:@"audio/wav"];
        
        if([returnString rangeOfString:@"error"].location == NSNotFound){
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:@"message" forKey:@"type"];
            [params setObject:MessageTypeVoice forKey:@"message_type"];

            if(title != nil)
                [params setObject:title forKey:@"body"];
            else
                [params setObject:@"" forKey:@"body"];
            
            [params setObject:fromUser._id forKey:@"from_user_id"];
            [params setObject:fromUser.name forKey:@"from_user_name"];
            [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
            [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
            
            NSString *apiName = @"sendMessageToUser";
            
            if(toUser != nil) {
                
                [params setObject:toUser.name forKey:@"to_user_name"];
                [params setObject:toUser._id forKey:@"to_user_id"];
                [params setObject:@"user" forKey:@"message_target_type"];
            }
            else if(toGroup != nil) {
                apiName = @"sendMessageToGroup";
                [params setObject:toGroup.name forKey:@"to_group_name"];
                [params setObject:toGroup._id forKey:@"to_group_id"];
                [params setObject:@"group" forKey:@"message_target_type"];
            }
            else{
                successBlock(false, @"No recipients set.");
            }
            
            [params setObject:returnString forKey:@"voice_file_id"];
            
            [self setDefaultHeaderValues];
            
            [[HUHTTPClient sharedClient] doPost:apiName
                                  operationType:AFJSONParameterEncoding
                                         params:params
                                    resultBlock:^(id result) {
                                        
                                        NSDictionary *responseDictionary = (NSDictionary *)result;
                                        
                                        if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                                            
                                            if (successBlock) {
                                                successBlock(YES, nil);
                                            }
                                            return;
                                        }
                                        
                                        if (successBlock) {
                                            successBlock(false, @"Failed to send message");
                                        }
                                        return;
                                    }
                                   failureBlock:^(NSError *error) {
                                       
                                       if (errorBlock) {
                                           errorBlock(error.localizedDescription);
                                       }
                                   }
                            uploadProgressBlock:nil
                          downloadProgressBlock:nil];
        }
        else {
            if (errorBlock) {
                errorBlock(@"Failed to send message.");
            }
        }
    });
}

- (void)loadVoice:(NSString *)loadVoice
          success:(DMLoadVoice)successBlock
            error:(DMErrorBlock)errorBlock {
    
    if (!loadVoice || !successBlock) {
        errorBlock(nil);
    }
    
    [[HUHTTPClient sharedClient] fileFromURL:[NSURL URLWithString:loadVoice]
                                  completion: ^(NSURL *irl, NSData *data){
        
                                      if(data == nil) {
                                      
                                          if (errorBlock) {
                                              errorBlock(@"Failed to load audio.");
                                          }
                                      }
                                      else {
                                          if (successBlock) {
                                              successBlock(data);
                                          }
                                      }
    }];
}

- (void)loadVideo:(NSString *)loadVideo
          success:(DMLoadVoice)successBlock
            error:(DMErrorBlock)errorBlock {
    
    if (!loadVideo || !successBlock) {
        errorBlock(nil);
    }
    
    [[HUHTTPClient sharedClient] fileFromURL:[NSURL URLWithString:loadVideo]
                                  completion: ^(NSURL *irl, NSData *data){
        
                                      if(data == nil) {
                                          if (errorBlock) {
                                              errorBlock(@"Failed to load video.");
                                          }
                                      }
                                      else {
                                          if (successBlock) {
                                              successBlock(data);
                                          }
                                      }
    }];
}

#pragma mark - Location Methods

-(void)sendLocationMessageOfType:(int)targetType
                          toUser:(ModelUser *)toUser
                         toGroup:(ModelGroup *)toGroup
                            from:(ModelUser *)fromUser
                    withLocation:(CLLocation *)location
                         success:(DMUpdateBlock)successBlock
                           error:(DMErrorBlock)errorBlock {
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"message" forKey:@"type"];
    [params setObject:MessageTypeLocation forKey:@"message_type"];
    [params setObject:fromUser._id forKey:@"from_user_id"];
    [params setObject:fromUser.name forKey:@"from_user_name"];
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
    [params setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"modified"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
    [params setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [params setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    [params setObject:@"" forKey:@"body"];
    
    NSString *apiName = @"sendMessageToUser";
    if(targetType == TargetTypeUser) {
        
        [params setObject:toUser.name forKey:@"to_user_name"];
        [params setObject:toUser._id forKey:@"to_user_id"];
        [params setObject:@"user" forKey:@"message_target_type"];
    }    
    else if(targetType == TargetTypeGroup) {
        apiName = @"sendMessageToGroup";
        [params setObject:toGroup.name forKey:@"to_group_name"];
        [params setObject:toGroup._id forKey:@"to_group_id"];
        [params setObject:@"group" forKey:@"message_target_type"];
    }

    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:apiName
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:^(id result) {
                                
                                NSDictionary *responseDictionary = (NSDictionary *)result;
                                
                                if([[responseDictionary objectForKey:@"ok"] intValue] == 1) {
                                    
                                    if (successBlock) {
                                        successBlock(YES, nil);
                                    }
                                    return;
                                }
                                if (successBlock) {
                                    successBlock(false, @"Failed to send message");
                                }
                            }
                           failureBlock:^(NSError *error) {
                                          
                               if (errorBlock) {
                                   errorBlock(error.localizedDescription);
                               }
                           }
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

#pragma mark - Recent activity

-(void) recentActivityForUser:(ModelUser *)user
					  success:(DMFindOneBlock)successBlock
						error:(DMErrorBlock)errorBlock {
	
	[self recentActivityForUserId:user._id success:successBlock error:errorBlock];
}

-(void) recentActivityForUserId:(NSString *)userId
						success:(DMFindOneBlock)successBlock
						  error:(DMErrorBlock)errorBlock {
	
    NSString *strUrl = [NSString stringWithFormat:@"activitySummary"];
    
    [self setDefaultHeaderValues];
	
	CSResultBlock block = ^(NSDictionary *result) {
		
		NSArray *rows = [result objectForKeyPath:@"rows"];
		if (!rows) {
			if (errorBlock) errorBlock(@"Invalid response!");
            return;
		}
		
		if (rows.count != 0) {
			result = [[rows objectAtIndex:0] objectForKeyPath:@"value"];
			
			//NOTE: for now recent activity is saved on one place, assuming logined user
			//IDEA: recent activity could be saved inside ModelUser in case you will ever
			//		need to store other users activity
			ModelRecentActivity *activity = [ModelRecentActivity objectWithDictionary:result];
			self.recentActivity = activity;
			
			if (successBlock) successBlock(activity);
		} else {
			
			ModelRecentActivity *activity = [ModelRecentActivity objectWithDictionary:@{}];
			self.recentActivity = activity;
            
            if (successBlock) successBlock(activity);
		}
		
	};
	
    CSErrorBlock errorBlockLocal = ^(NSError *error) {
        if(errorBlock)
            errorBlock(error.localizedDescription);
    };

    
    [[HUHTTPClient sharedClient] doGet:strUrl
                         operationType:AFJSONParameterEncoding
                           resultBlock:block
                          failureBlock:errorBlockLocal
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}


-(void) insertWatchinGroupLog:(NSString *) userId
                      groupId:(NSString *) groupId{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groupId forKey:@"group_id"];
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"watchGroup"
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:nil
                           failureBlock:nil
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
    

}

-(void) deleteWatchinGroupLog:(NSString *) userId{
    
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"unWatchGroup"
                          operationType:AFJSONParameterEncoding
                                 params:nil
                            resultBlock:nil
                           failureBlock:nil
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
    
    
}


-(void) doLogout:(CSResultBlock) successBlock{
    
    NSString *method = [self getURL:@"unregistToken"
                     withParameters:@{@"user_id":[[UserManager defaultManager] getLoginedUser]._id}];
    
    [[HUHTTPClient sharedClient] doGet:method
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               if (successBlock) {
                                  successBlock(result);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (successBlock) {
                                  successBlock(error);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(void) report:(ModelMessage *)message success:(CSResultBlock) successBlock{
    
    NSString *method = [self getURL:@"reportViolation"
                     withParameters:@{@"message_id":message._id}];
    
    [[HUHTTPClient sharedClient] doGet:method
                         operationType:AFJSONParameterEncoding
                           resultBlock:^(id result) {
                               
                               if (successBlock) {
                                   successBlock(result);
                               }
                           }
                          failureBlock:^(NSError *error) {
                              
                              if (successBlock) {
                                  successBlock(error);
                              }
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(void) setDeleteOnMessageId:(NSString*)messageId
                  deleteType:(int)deleteType
                     success:(DMFindOneBlock)successBlock {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:messageId forKey:@"message_id"];
    [params setObject:[NSString stringWithFormat:@"%d", deleteType] forKey:@"delete_type"];
        
    [self setDefaultHeaderValues];
    
    [[HUHTTPClient sharedClient] doPost:@"setDelete"
                          operationType:AFJSONParameterEncoding
                                 params:params
                            resultBlock:successBlock
                           failureBlock:nil
                    uploadProgressBlock:nil
                  downloadProgressBlock:nil];
}

-(void) getServerListWithSuccess:(DMArrayBlock)successBlock
                        andError:(DMErrorBlock)errorBlock
{
    NSString *method = [self getURL:ServerListAPIURL withParameters:nil];
    
    [[HUHTTPClient sharedClient] doGet:method
                         operationType:AFJSONParameterEncoding
                           resultBlock:successBlock
                          failureBlock:^(NSError *error) {
                              //successBlock(error);
                          }
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}

-(void) test{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"watching_group_log" forKey:@"type"];
    [params setObject:@"sss" forKey:@"user_id"];
    [params setObject:@"bbb" forKey:@"group_id"];
    [params setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"created"];
    
    
    [[HUHTTPClient sharedClient] setDefaultHeader:@"user_id" value:@"create_user"];

    [[HUHTTPClient sharedClient] doPost:@"test.php"
                          operationType:AFJSONParameterEncoding
                                 params:params
                           resultBlock:nil
                          failureBlock:nil
                   uploadProgressBlock:nil
                 downloadProgressBlock:nil];
}


@end
