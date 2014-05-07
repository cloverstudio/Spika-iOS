//
//  HUCachedImageLoader.m
//  Spika
//
//  Created by Ken Yasue on 23/02/14.
//
//

#import "HUCachedImageLoader.h"
#import "DatabaseManager.h"
#import "Constants.h"

@implementation HUCachedImageLoader

+(void) imageFromUrl:(NSString *)url completionHandler:(HUImageResultBlock)block{
    
    //get last url path
    NSArray *urlElements = [url componentsSeparatedByString: @"/"];
    NSString *fileId = urlElements.lastObject;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *filePath =  [cachePath stringByAppendingPathComponent:fileId];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if(fileExists){
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        block(img);
        return;
    }
    
    [[DatabaseManager defaultManager] loadImage:url success:^(UIImage *image) {
        
        // save to file
        NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        [imageData writeToFile:filePath atomically:YES];
        
        block(image);
        
    } error:^(NSString *error) {
        NSLog(@"Error occured:%@",error);
    }];
}

+(void) thumbnailFromUserId:(NSString *)userId completionHandler:(HUImageResultBlock)block{
    
    [[DatabaseManager defaultManager] findUserWithID:userId success:^(id result) {
        
        ModelUser *user = (ModelUser *)result;
        
        [HUCachedImageLoader imageFromUrl:user.thumbImageUrl completionHandler:^(UIImage *image) {
            block(image);
        }];
        
    } error:^(NSString *errorString) {
        block(nil);
    }];
    
}


+(void) thumbnailFromGroupId:(NSString *)groupId completionHandler:(HUImageResultBlock)block{
    
    [[DatabaseManager defaultManager] findGroupByID:groupId success:^(id result) {
        
        ModelGroup *group = (ModelGroup *) result;
        
        [HUCachedImageLoader imageFromUrl:group.thumbImageUrl completionHandler:^(UIImage *image) {
            block(image);
        }];
        
    } error:^(NSString *errorString) {
        block(nil);
    }];
    
}

+(void) thumbnailFromUser:(ModelUser *)user completionHandler:(HUImageResultBlockWithUser)block{
    
    [HUCachedImageLoader imageFromUrl:user.thumbImageUrl completionHandler:^(UIImage *image) {
        block(image,user);
    }];
    
}

+(void) thumbnailFromGroup:(ModelGroup *)group completionHandler:(HUImageResultBlockWithGroup)block{
    
    [HUCachedImageLoader imageFromUrl:group.thumbImageUrl completionHandler:^(UIImage *image) {
        block(image,group);
    }];
    
}

@end
