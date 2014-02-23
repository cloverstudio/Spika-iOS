//
//  HUCachedImageLoader.h
//  Spika
//
//  Created by Ken Yasue on 23/02/14.
//
//

#import <Foundation/Foundation.h>

typedef void(^HUImageResultBlock)(UIImage *image);

@interface HUCachedImageLoader : NSObject

+(void) imageFromUrl:(NSString *)fileId completionHandler:(HUImageResultBlock)block ;
+(void) thumbnailFromUserId:(NSString *)userId completionHandler:(HUImageResultBlock)block ;
+(void) thumbnailFromGroupId:(NSString *)userId completionHandler:(HUImageResultBlock)block ;


@end
