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

@class ModelMessage, ModelUser;

@protocol HUAvatarModel;

typedef void(^HUUsersResultBlock)(id<HUAvatarModel> model);
typedef void(^HUUsersImageResultBlock)(UIImage *image, NSIndexPath *indexPath);

@interface HUAvatarManager : NSObject

+(void) avatarImageForId:(NSString *)userId atIndexPath:(NSIndexPath *)indexPath width:(float) width completionHandler:(HUUsersImageResultBlock)block ;
+(void) avatarImageFromMessage:(ModelMessage *)message atIndexPath:(NSIndexPath *)indexPath width:(float) width completionHandler:(HUUsersImageResultBlock)block ;
+(void) avatarImageForUrl:(NSString *)aURL atIndexPath:(NSIndexPath *)indexPath width:(float) width completionHandler:(HUUsersImageResultBlock)block ;

+(ModelUser *) userForMessage:(ModelMessage *)message;
//+(id<HUAvatarModel>) modelForModelId:(NSString *)modelId;

+(void) findModelForModelId:(NSString *)modelId completion:(HUUsersResultBlock)block;
+(void) findModelForModelId:(NSString *)modelId forClasses:(NSMutableArray *)array completion:(HUUsersResultBlock)block;
+(void) removeModelByID:(NSString *)modelId;

+(void) clearCacheIfNeed;
+(void) clearCache;

@end

@interface HUAvatarManager (ModelsHelper)

+(void) avatarImageForUser:(ModelUser *)user completionHandler:(HUUsersImageResultBlock)block;
+(void) avatarImageForMessage:(ModelMessage *)message atIndexPath:(NSIndexPath *)indexPath completionHandler:(HUUsersImageResultBlock)block;

@end

@protocol HUAvatarModel <NSObject>

-(NSString *) modelId;
-(NSString *) imageUrl;
-(NSString *) thumbImageUrl;
-(void) findModelWithCompletion:(CSResultBlock)block;
+(void) findModelWithModelId:(NSString *)modelId completion:(CSResultBlock)block;

@end
