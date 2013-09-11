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

#import "HUAvatarManager.h"
#import "DatabaseManager.h"
#import "CSDispatcher.h"
#import "UIImage+Resize.h"

#define MODELS @[@"ModelUser",@"ModelGroup"]

typedef void(^HUModelResultBlock)(id<HUAvatarModel> model, NSMutableArray *remainingClasses);

@interface HUAvatarManager ()
@property (nonatomic, strong) NSMutableDictionary *models, *avatarIcons;
@property (readwrite) long lastClearCacheTimeStamp;
+(id) defaultAvatarManager;
@end

@implementation HUAvatarManager

#pragma mark - Initialization

+(id) defaultAvatarManager {
    static HUAvatarManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HUAvatarManager new];
    });
    return manager;
}

-(id) init {
    
    if (self = [super init]) {
    
        self.models = [NSMutableDictionary new];
        self.avatarIcons = [NSMutableDictionary new];
        self.lastClearCacheTimeStamp = [[NSDate date] timeIntervalSince1970];
    }
    
    return self;
}

#pragma mark - Public methods

+(void) avatarImageForId:(NSString *)modelId
             atIndexPath:(NSIndexPath *)indexPath
                   width:(float)width
       completionHandler:(HUUsersImageResultBlock)block {
    
    HUAvatarManager *manager = [HUAvatarManager defaultAvatarManager];
    
    id<HUAvatarModel> model = [manager.models objectForKey:modelId];
    if (model) {
        
        [HUAvatarManager avatarImageForUrl:[model thumbImageUrl] atIndexPath:indexPath width:width completionHandler:block];
        
    } else {
        
        [HUAvatarManager findModelForModelId:modelId forClasses:MODELS.mutableCopy completion:^(id<HUAvatarModel> result) {
            [CSDispatcher dispatchMainQueue:^{
                [HUAvatarManager avatarImageForUrl:result.thumbImageUrl atIndexPath:indexPath width:width completionHandler:block];
            }];
        }];

    }
}


+(void) avatarImageForUrl:(NSString *)aURL
              atIndexPath:(NSIndexPath *)indexPath
                    width:(float)width
            completionHandler:(HUUsersImageResultBlock)block {
    
    if(width == 0)
        width = 50;
    
    __block NSIndexPath *indexPathRef = indexPath;
    
    if(aURL == nil)
        return;
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"file=(.*)$" options:0 error:NULL];
//    NSTextCheckingResult *match = [regex firstMatchInString:aURL options:0 range:NSMakeRange(0, [aURL length])];
//    NSString *matchStr = [aURL substringWithRange:[match rangeAtIndex:1]];
    //if(matchStr == nil || [matchStr isEqualToString:@""])
    //    return;

    HUAvatarManager *manager = [HUAvatarManager defaultAvatarManager];
    UIImage *cachedImage = [manager.avatarIcons objectForKey:aURL];
    if (cachedImage) {
        block(cachedImage,indexPath);
        return;
    }
    
    [[DatabaseManager defaultManager] loadImage:aURL success:^(UIImage *image) {
        
		if (image == nil || image.size.height == 0) {
			NSLog(@"Image height is 0!");
		} else {
			CGFloat ratio = image.size.width / image.size.height;
			image = [image resizedImage:CGSizeMake(width, width / ratio)
				   interpolationQuality:kCGInterpolationHigh];
            
			[manager.avatarIcons setObject:image forKey:aURL];
			
			if ([NSThread isMainThread]) {
				if ([indexPathRef isEqual:indexPath] || indexPath == nil) {
					block(image,indexPath);
				} else {
					NSLog(@"Wrong index path!");
				}
			} else {
				[CSDispatcher dispatchMainQueue:^{
					if ([indexPathRef isEqual:indexPath] || indexPath == nil) {
						block(image, indexPath);
					} else {
						NSLog(@"Wrong index path!");
					}
				}];
			}
		}
        
    } error:^(NSString *error) {
        
        NSLog(@"Error occured:%@",error);
        
    }];
    
}

+(ModelUser *) userForMessage:(ModelMessage *)message {
    
    ModelUser *user = [[[HUAvatarManager defaultAvatarManager] models] objectForKey:message.from_user_id];
    ModelUser *userCopy = [ModelUser objectWithJson:[ModelUser objectToJson:user]];
    
    return userCopy;
}

+(void) findModelForModelId:(NSString *)modelId completion:(HUUsersResultBlock)block {
	
	[HUAvatarManager findModelForModelId:modelId forClasses:MODELS.mutableCopy completion:block];
}

+(void) findModelForModelId:(NSString *)modelId forClasses:(NSMutableArray *)array completion:(HUUsersResultBlock)block {
    
    NSMutableArray *classes = array;
    
    HUModelResultBlock resultBlock;
    resultBlock = ^(id<HUAvatarModel> model, NSMutableArray *remainingClasses) {
        if (model) {
            block(model);
        } else {
            if (remainingClasses) {
                [HUAvatarManager findModelForModelId:modelId forClasses:remainingClasses completion:block];
            }
        }
    };
    
    [HUAvatarManager _findModelForModelId:modelId classes:classes completion:resultBlock];
    
}

+(void) _findModelForModelId:(NSString *)userId classes:(NSMutableArray *)classes completion:(HUModelResultBlock)block {
    
    if (!block)
        return;
    
    HUAvatarManager *manager = [HUAvatarManager defaultAvatarManager];
    
    id<HUAvatarModel> model = [manager.models objectForKey:userId];
    if (model) {
        block(model, classes);
        return;
    }
    
    if (classes.count == 0)
        return;
    
    NSString *className = [classes objectAtIndex:0];
    [classes removeObjectAtIndex:0];
    
    [NSClassFromString(className) findModelWithModelId:userId completion:^(id<HUAvatarModel> fetchedModel) {
        
        
        if ([fetchedModel isKindOfClass:[ModelGroup class]]) {
            //NSLog(@"oO");
        }
        
        if (!fetchedModel) {
            block(nil, classes);
            return;
        }
        
        @synchronized(manager.models){

            [manager.models setObject:fetchedModel forKey:fetchedModel.modelId];
        }
        
        block(fetchedModel,nil);
        
    }];
    
}

+(void) removeModelByID:(NSString *)modelId{
    
    HUAvatarManager *manager = [HUAvatarManager defaultAvatarManager];
    [manager.models removeObjectForKey:modelId];
    
}
+(void) clearCacheIfNeed{
    HUAvatarManager *manager = [HUAvatarManager defaultAvatarManager];
    
    long now = [[NSDate date] timeIntervalSince1970];
    long diff = now - manager.lastClearCacheTimeStamp;
    
    if(diff > 60 * 60){
        manager.lastClearCacheTimeStamp = now;
        [manager.models removeAllObjects];
    }

}

+(void) clearCache{
    HUAvatarManager *manager = [HUAvatarManager defaultAvatarManager];
    
    [manager.models removeAllObjects];
    
}

@end

@implementation HUAvatarManager (ModelMessageHelper)

+(void) avatarImageForUser:(ModelUser *)user completionHandler:(HUUsersImageResultBlock)block {
    
    [HUAvatarManager avatarImageForId:user._id
                                   atIndexPath:nil
                                    width:kListViewSmallWidht
                             completionHandler:block];
    
}

+(void) avatarImageForMessage:(ModelMessage *)message atIndexPath:(NSIndexPath *)indexPath completionHandler:(HUUsersImageResultBlock)block {
    
    [HUAvatarManager avatarImageForId:message.from_user_id
                                   atIndexPath:indexPath
                                width:kListViewSmallWidht
                             completionHandler:block];
}


@end