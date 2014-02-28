//
//  HUCachedImageLoader.h
//  Spika
//
//  Created by Ken Yasue on 23/02/14.
//
//

#import <Foundation/Foundation.h>
#import "Models.h"

typedef void(^HUImageResultBlock)(UIImage *image);
typedef void(^HUImageResultBlockWithUser)(UIImage *image,ModelUser *user);
typedef void(^HUImageResultBlockWithGroup)(UIImage *image,ModelGroup *group);

@interface HUCachedImageLoader : NSObject

+(void) imageFromUrl:(NSString *)fileId completionHandler:(HUImageResultBlock)block ;
+(void) thumbnailFromUserId:(NSString *)userId completionHandler:(HUImageResultBlock)block ;
+(void) thumbnailFromGroupId:(NSString *)userId completionHandler:(HUImageResultBlock)block ;

+(void) thumbnailFromUser:(ModelUser *)user completionHandler:(HUImageResultBlockWithUser)block;
+(void) thumbnailFromGroup:(ModelGroup *)group completionHandler:(HUImageResultBlockWithGroup)block;

@end
