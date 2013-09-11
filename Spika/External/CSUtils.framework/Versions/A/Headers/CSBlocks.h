//
//  CSBlocks.h
//  CSUtils
//
//  Created by Josip Bernat on 5/9/13.
//
//

#ifndef CSUtils_CSBlocks_h
#define CSUtils_CSBlocks_h

#import <UIKit/UIImage.h>

#pragma mark - Blocks
typedef void (^CSVoidBlock)(void);
typedef void (^CSBoolBlock)(BOOL yesOrNo);
typedef void (^CSArrayBlock)(NSArray *array);
typedef void (^CSDictionaryBlock)(NSDictionary *dictionary);
typedef void (^CSResultBlock)(id result);
typedef void (^CSImageBlock)(UIImage* image);
typedef void (^CSErrorBlock)(NSError* error);
typedef void (^CSProgressBlock)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void (^CSResponseBlock)(id responseObject, NSError* error);
typedef void (^CSImageDownloadBlock)(NSURL *imageURL, UIImage *image);

#endif
