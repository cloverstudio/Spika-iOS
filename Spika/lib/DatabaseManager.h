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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Models.h"
#import "HUOfflinePushNotification.h"
#import "HUHTTPClient.h"

#define TargetTypeUser 1
#define TargetTypeGroup 2

typedef void (^DMFindOneBlock)(id result);
typedef void (^DMArrayBlock)(NSArray *);
typedef void (^DMArrayPagingBlock)(NSArray *results, NSInteger totalResults);
typedef void (^DMUpdateBlock)(BOOL, NSString *);
typedef void (^DMUpdateDocumentBlock)(BOOL, NSDictionary *result);
typedef void (^DMErrorBlock)(NSString *errorString);
typedef void (^DMLoadImageBlock)(UIImage *image);
typedef void (^DMLoadVoice)(NSData *data);


@interface DatabaseManager : NSObject

@property (nonatomic, strong, readonly) HUOfflinePushNotification *offlineNotificationModel;
@property (nonatomic, strong) ModelRecentActivity *recentActivity;

+(DatabaseManager *) defaultManager;

#pragma mark - check methods
-(NSDictionary *) checkUniqueSynchronous:(NSString *) key
              value:(NSString *) value;

-(NSString *)sendReminderSynchronous:(NSString *)email;



#pragma mark - User Methods

-(void) loginUserByEmail:(NSString *)email
                password:(NSString *)password
                 success:(DMFindOneBlock)successBlock
                   error:(DMErrorBlock)errorBlock;

-(void)findUserByEmail:(NSString *)email
               success:(DMFindOneBlock)successBlock
                 error:(DMErrorBlock)errorBlock;

-(void)createUserByEmail:(NSString *)email
                    name:(NSString *)name
                password:(NSString *)password
                 success:(DMUpdateBlock)successBlock
                   error:(DMErrorBlock)errorBlock;

-(void)saveUserAvatarImage:(ModelUser *)toUser
                 image:(UIImage *)image
               success:(DMUpdateBlock)successBlock
                 error:(DMErrorBlock)errorBlock;

-(void)findUsers:(DMArrayBlock)successBlock
           error:(DMErrorBlock)errorBlock;

-(void) findUsersContainingString:(NSString*) string
                          fromAge:(NSNumber*) fromAge
                            toAge:(NSNumber*) toAge
                           gender:(HUGender) gender
                          success:(DMArrayBlock) successBlock
                            error:(DMErrorBlock) errorBlock;

-(void)findUsersContainingString:(NSString *)string
                         success:(DMArrayBlock)successBlock
                           error:(DMErrorBlock)errorBlock;

-(void)reloadUser:(ModelUser *)user
          success:(DMFindOneBlock)successBlock
            error:(DMErrorBlock)errorBlock;

-(void)findUserWithID:(NSString *)userId
              success:(DMFindOneBlock)successBlock
                error:(DMErrorBlock)errorBlock;

-(void)findUserByName:(NSString *)userName
              success:(DMFindOneBlock)successBlock
                error:(DMErrorBlock)errorBlock;

- (void)findUserListByGroupID:(NSString *)groupId
                   count:(int)count
                  offset:(int)offset
                 success:(DMArrayPagingBlock)successBlock
                   error:(DMErrorBlock)errorBlock;

-(void)findUserContactList:(ModelUser *)user
                   success:(DMFindOneBlock)successBlock
                     error:(DMErrorBlock)errorBlock;

-(void)updateUser:(ModelUser *)toUser
         oldEmail:(NSString *)oldEmail
          success:(DMUpdateBlock)successBlock
            error:(DMErrorBlock)errorBlock;

-(void)updateUserAddRemoveContacts:(ModelUser *)user
                         contactId:(NSString *)contactId
                           success:(DMUpdateBlock)successBlock
                             error:(DMErrorBlock)errorBlock;

-(void)saveUserPushNotificationToken:(ModelUser *)toUser
                               token:(NSString *)token
                             success:(DMUpdateBlock)successBlock
                               error:(DMErrorBlock)errorBlock;

-(void)updatePassword:(ModelUser *)toUser
                               newPassword:(NSString *)password
                             success:(DMUpdateBlock)successBlock
                               error:(DMErrorBlock)errorBlock;

#pragma mark - Group Methods
-(void)loadGroups:(DMArrayBlock)successBlock
            error:(DMErrorBlock)errorBlock;

-(void)findGroupByName:(NSString *)name
               success:(DMFindOneBlock)successBlock
                 error:(DMErrorBlock)errorBlock;

-(void)createGroup:(NSString *)name
       description:(NSString *)description
          password:(NSString *)password
        categoryID:(NSString *)categoryID
        categoryName:(NSString *)categoryName
              ower:(ModelUser *)user
       avatarImage:(UIImage *)avatarImage
           success:(DMUpdateBlock)successBlock
             error:(DMErrorBlock)errorBlock;

- (void)findGroupByID:(NSString *)groupId
              success:(DMFindOneBlock)successBlock
                error:(DMErrorBlock)errorBlock;

- (void)findGroupsByCategoryId:(NSString *)groupCategoryId
              success:(DMArrayBlock)successBlock
                error:(DMErrorBlock)errorBlock;

- (void)addGroupToFavorite:(ModelGroup *)group
                    toUser:(ModelUser *)user
                   success:(DMUpdateBlock)successBlock
                     error:(DMErrorBlock)errorBlock;

- (void)removeGroupFromFavorite:(ModelGroup *)group
                    toUser:(ModelUser *)user
                   success:(DMUpdateBlock)successBlock
                     error:(DMErrorBlock)errorBlock;

-(void)updateGroup:(ModelGroup *)newGroup
       avatarImage:(UIImage *)avatarImage
           success:(DMUpdateBlock)successBlock
             error:(DMErrorBlock)errorBlock;

-(void)reloadGroup:(ModelGroup *)group
          success:(DMFindOneBlock)successBlock
             error:(DMErrorBlock)errorBlock;

-(void)deleteGroup:(ModelGroup *)newGroup
           success:(DMUpdateBlock)successBlock
             error:(DMErrorBlock)errorBlock;

-(void)getUsersInGroup:(ModelGroup *)group
           success:(DMFindOneBlock)successBlock
             error:(DMErrorBlock)errorBlock;

-(void) findUserFavoriteGroups:(ModelUser *)user
                       success:(DMFindOneBlock)successBlock
                         error:(DMErrorBlock)errorBlock;

- (void)saveGroupAvatarImage:(ModelGroup *)toGroup
                       image:(UIImage *)image
                     success:(DMUpdateBlock)successBlock
                       error:(DMErrorBlock)errorBlock;

-(void) findGroupCategories:(DMArrayBlock)successBlock
                         error:(DMErrorBlock)errorBlock;

-(void)findOneGroupByName:(NSString *)userName
               success:(DMFindOneBlock)successBlock
                 error:(DMErrorBlock)errorBlock;

#pragma mark - Message Methods

-(void)sendTextMessage:(int) targetType
                toUser:(ModelUser *)toUser
               toGroup:(ModelGroup *)toGroup
                  from:(ModelUser *)fromUser
               message:(NSString *)message
               success:(DMUpdateBlock)successBlock
                 error:(DMErrorBlock)errorBlock;

-(void)findUserMessagesByUser:(ModelUser *) user
                      partner:(ModelUser *) partner
                         page:(int) page
                      success:(DMArrayBlock)successBlock
                        error:(DMErrorBlock)errorBlock;

-(void)findMessagesByGroup:(ModelGroup *) group
                      page:(int) page
                      success:(DMArrayBlock)successBlock
                     error:(DMErrorBlock)errorBlock;

-(void)reloadMessage:(ModelMessage *)message
             success:(DMFindOneBlock)successBlock
               error:(DMErrorBlock)errorBlock;

#pragma mark - Emoticons

- (void)loadEmoticons:(DMArrayBlock)successBlock
                error:(DMErrorBlock)errorBlock;

#pragma mark - Image Methods

-(void)sendImageMessage:(ModelUser *)toUser
                toGroup:(ModelGroup *)toGroup
                   from:(ModelUser *)fromUser
                  image:(UIImage *)image
                success:(DMUpdateBlock)successBlock
                  error:(DMErrorBlock)errorBlock;

-(void)postImageComment:(ModelMessage *) message
                 byUser:(ModelUser *)user
                comment:(NSString *)comment
                success:(DMUpdateDocumentBlock)successBlock
                  error:(DMErrorBlock)errorBlock;

-(void)sendEmoticonMessage:(int) targetType
                    toUser:(ModelUser *)toUser
                   toGroup:(ModelGroup *)toGroup
                      from:(ModelUser *)fromUser
              emoticonData:(NSDictionary *)data
                   success:(DMUpdateBlock)successBlock
                     error:(DMErrorBlock)errorBlock;

- (void)loadImage:(NSString *)imageUrl
          success:(DMLoadImageBlock)successBlock
            error:(DMErrorBlock)errorBlock;

- (void)loadCategoryIconByName:(NSString *)categoryName
          success:(DMLoadImageBlock)successBlock
            error:(DMErrorBlock)errorBlock;

- (void)loadEmoticons:(NSString *)imageUrl
                toBtn:(CSButton *)button
              success:(DMLoadImageBlock)successBlock
                error:(DMErrorBlock)errorBlock;

-(void)getCommentsByMessage:(ModelMessage *) message
                       page:(int) page
                    success:(DMArrayBlock)successBlock
                      error:(DMErrorBlock)errorBlock;

-(void)getCommentsCountByMessage:(ModelMessage *) message
                         success:(DMFindOneBlock)successBlock
                           error:(DMErrorBlock)errorBlock;



-(UIImage *) readFromCache:(NSString *)url;
-(void) clearCache;

#pragma mark - Video Methods

-(void)sendVideoMessage:(ModelUser *)toUser
                toGroup:(ModelGroup *)toGroup
                   from:(ModelUser *)fromUser
                fileURL:(NSURL *)videoUrl
                  title:(NSString *)title
                success:(DMUpdateBlock)successBlock
                  error:(DMErrorBlock)errorBlock;

#pragma mark - Audio Methods

- (void)sendVoiceMessage:(ModelUser *)toUser
                 toGroup:(ModelGroup *)toGroup
                    from:(ModelUser *)fromUser
                 fileURL:(NSURL *)videoUrl
                   title:(NSString *)title
                 success:(DMUpdateBlock)successBlock
                   error:(DMErrorBlock)errorBlock;

- (void)loadVoice:(NSString *)loadVoice
          success:(DMLoadVoice)successBlock
            error:(DMErrorBlock)errorBlock;

- (void)loadVideo:(NSString *)loadVoice
          success:(DMLoadVoice)successBlock
            error:(DMErrorBlock)errorBlock;

#pragma mark - Location Methods

-(void)sendLocationMessageOfType:(int)targetType
                          toUser:(ModelUser *)toUser
                         toGroup:(ModelGroup *)toGroup
                            from:(ModelUser *)fromUser
                    withLocation:(CLLocation *)location
                         success:(DMUpdateBlock)successBlock
                           error:(DMErrorBlock)errorBlock;

#pragma mark - Recent activity

-(void) recentActivityForUser:(ModelUser *)user
					  success:(DMFindOneBlock)successBlock
						error:(DMErrorBlock)errorBlock;

-(void) recentActivityForUserId:(NSString *)userId
						success:(DMFindOneBlock)successBlock
						  error:(DMErrorBlock)errorBlock;

-(void) insertWatchinGroupLog:(NSString *) userId
                      groupId:(NSString *) groupdId;

-(void) deleteWatchinGroupLog:(NSString *) userId;

-(void) doLogout:(CSResultBlock) successBlock;
-(void) report:(ModelMessage *)message success:(CSResultBlock) successBlock;

-(void) setDeleteOnMessageId:(NSString *)_id deleteType:(int)deleteType success:(DMFindOneBlock)successBlock;

-(void) getServerListWithSuccess:(DMArrayBlock)successBlock
                andError:(DMErrorBlock)errorBlock;

-(void) test;

@end
