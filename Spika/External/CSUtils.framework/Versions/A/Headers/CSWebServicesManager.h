//
//  CSWebServicesManager.h
//  CSWebServicesManager
//
//  Created by Giga on 4/12/13.
//  Copyright (c) 2013 Clover-Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Availability.h>
#import "CSBlocks.h"

// These notifications are sent out when internet reachability changes
extern NSString * const CSWebServicesManagerInternerDidBecomeAvailableNotification;
extern NSString * const CSWebServicesManagerInternerDidBecomeUnavailableNotification;

@class CSURLCache;
@class AFHTTPRequestOperation;

typedef NS_ENUM(NSInteger, CSWebOperatonType) {
    
    CSWebOperatonTypeDefault = 0,
    CSWebOperatonTypeJSON,
    CSWebOperatonTypeXML
};

NS_CLASS_AVAILABLE_IOS(5_0)
@interface CSWebServicesManager : NSObject

@property (nonatomic, copy)         NSString                    *baseUrl; //Base url of your server. This value cannot be nil.
@property (nonatomic, copy)         NSString                    *authorizationHeaderUsername; //The HTTP basic auth username. Default value is nil.
@property (nonatomic, copy)         NSString                    *authorizationHeaderPassword; //The HTTP basic auth password. Default value is nil.
@property (nonatomic, copy)         NSDictionary                *headerValues; //The HTTP header value. NSDictonary key is used as header and value is used as value.
@property (nonatomic, copy)         NSString                    *localizedInternetError; //Localized error that will be shown as message in UIAlertView
@property (nonatomic, readwrite)    NSInteger                   maxNumberOfDataOperations; //The maximum number of concurrent data download operations. Default value is 2
@property (nonatomic, readwrite)    NSInteger                   maxNumberOfImagesOperations; //The maximum number of concurrent image download operations. Default value is 2.
@property (nonatomic, readonly)     __block BOOL                isInternetAvailable; //Indicates whether internet is reachable or not.
@property (nonatomic, readwrite)    BOOL                        shouldDisplayNoInternetAlert; //Configure do you want to show automated alert when you want to execute request operation, but internet is unreachable
@property (nonatomic, readwrite)    BOOL                        showNetworkActivityIndicator; //Configure do you want to show network activity indicator in status bar while request operation is executing. Default value is NO
@property (nonatomic, readwrite)    BOOL                        shouldUseFastCaching; //Configure do you want to use CSURLCache fast caching option
@property (nonatomic, readwrite)    dispatch_queue_priority_t   imagesCacheQueuePriority; //Configure priority you want to use for getting images from cache. DISPATCH_QUEUE_PRIORITY_BACKGROUND is default.

+ (CSWebServicesManager *)webServicesManager;

#pragma mark - Configuration

/**
 Adds content types to the set of acceptable MIME types for given type param class.
 
 @param contentTypes The content types to be added to the set of acceptable MIME types.
 @param operationType The type of operation.
 */
- (void) addAcceptableContentTypes:(NSSet *)contentTypes
                  forOperationType:(CSWebOperatonType)operationType;

#pragma mark - Cache Controll

/**
 Removes all images from cache.
 If shouldUseFastCaching is set to YES, fast cache will alse be erased.
 */
- (void) clearCache;

#pragma mark - Executing Requests

/**
 Executes POST request.
 
 @param apiPath The path you want to execute on server.
 @param operationType The type of operation you want to use.
 @param params The parameters to be encoded and set in the request HTTP body.
 @param resultBlock The block to be executed on the completion of a successful request. This block has no return value and takes one argument: the object constructed from the response data of the request.
 @param errorBlock The block to be executed on the completion of an unsuccessful request. This block has no return value and takes one argument: the error that occured during the request.
 @param uploadProgressBlock A block object to be called when an undetermined number of bytes have been uploaded to the server. This block has no return value and takes three arguments: the number of bytes written since the last time the upload progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 @param downloadProgressBlock A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes three arguments: the number of bytes written since the last time the download progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.

 @return A new AFHTTPRequestOperation request operation
 */
- (AFHTTPRequestOperation *) doPost:(NSString *) apiPath
                      operationType:(CSWebOperatonType) operationType
                             params:(NSDictionary *) params
                        resultBlock:(CSResultBlock) resultBlock
                       failureBlock:(CSErrorBlock) errorBlock
                uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
              downloadProgressBlock:(CSProgressBlock)downloadProgressBlock;

/**
 Executes PUT request.
 
 @param apiPath The path you want to execute on server.
 @param operationType The type of operation you want to use.
 @param params The parameters to be encoded and set in the request HTTP body.
 @param resultBlock The block to be executed on the completion of a successful request. This block has no return value and takes one argument: the object constructed from the response data of the request.
 @param errorBlock The block to be executed on the completion of an unsuccessful request. This block has no return value and takes one argument: the error that occured during the request.
 @param uploadProgressBlock A block object to be called when an undetermined number of bytes have been uploaded to the server. This block has no return value and takes three arguments: the number of bytes written since the last time the upload progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 @param downloadProgressBlock A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes three arguments: the number of bytes written since the last time the download progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 
 @return A new AFHTTPRequestOperation request operation
 */
- (AFHTTPRequestOperation *) doPut:(NSString *) apiPath
                     operationType:(CSWebOperatonType) operationType
                            params:(NSDictionary *) params
                       resultBlock:(CSResultBlock) resultBlock
                      failureBlock:(CSErrorBlock) errorBlock
               uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
             downloadProgressBlock:(CSProgressBlock)downloadProgressBlock;

/**
 Executes GET request.
 
 @param apiPath The path you want to execute on server. Parameters you want to send add to it.
 @param operationType The type of operation you want to use.
 @param resultBlock The block to be executed on the completion of a successful request. This block has no return value and takes one argument: the object constructed from the response data of the request.
 @param errorBlock The block to be executed on the completion of an unsuccessful request. This block has no return value and takes one argument: the error that occured during the request.
 @param uploadProgressBlock A block object to be called when an undetermined number of bytes have been uploaded to the server. This block has no return value and takes three arguments: the number of bytes written since the last time the upload progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 @param downloadProgressBlock A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes three arguments: the number of bytes written since the last time the download progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 
 @return A new AFHTTPRequestOperation request operation
 */
- (AFHTTPRequestOperation *) doGet:(NSString *) apiPath
                     operationType:(CSWebOperatonType) operationType
                       resultBlock:(CSResultBlock) resultBlock
                      failureBlock:(CSErrorBlock) errorBlock
               uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
             downloadProgressBlock:(CSProgressBlock)downloadProgressBlock;

/**
 Executes DELETE request.
 
 @param apiPath The path you want to execute on server.
 @param operationType The type of operation you want to use.
 @param params The parameters to be encoded and set in the request HTTP body.
 @param resultBlock The block to be executed on the completion of a successful request. This block has no return value and takes one argument: the object constructed from the response data of the request.
 @param errorBlock The block to be executed on the completion of an unsuccessful request. This block has no return value and takes one argument: the error that occured during the request.
 @param uploadProgressBlock A block object to be called when an undetermined number of bytes have been uploaded to the server. This block has no return value and takes three arguments: the number of bytes written since the last time the upload progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 @param downloadProgressBlock A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes three arguments: the number of bytes written since the last time the download progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 @return A new AFHTTPRequestOperation request operation
 */
- (AFHTTPRequestOperation *) doDelete:(NSString *) apiPath
                               params:(NSDictionary *) params
                        operationType:(CSWebOperatonType) operationType
                          resultBlock:(CSResultBlock) resultBlock
                         failureBlock:(CSErrorBlock) errorBlock
                  uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
                downloadProgressBlock:(CSProgressBlock)downloadProgressBlock;

@end

@interface CSWebServicesManager (ImageDownload)

/**
 Downloads image from given imageURL.
 If image exists in cache, will return image from cache using CSWebServicesManager imagesQueue.
 This method will cache image to imagesCache.
 
 @param imageURL The URL which holds the image.
 @param imageRequestBlock The block to be executed on the completion of successfull or unsuccessful request. This block has no return value and takes two argumens: the URL object which was provided as param from where image was downloaded, the image object. If request was unsuccessful image object will be nil.
 */
- (void) imageFromURL:(NSURL*) imageURL
           completion:(CSImageDownloadBlock) imageRequestBlock;

/**
 Finds image im imagesCache and sends it back using imageRequestBlock.
 Works on CSWebServicesManager imagesQueue.

 @param imageURL The URL which holds the image. 
 @param imageRequestBlock The block to be executed on the completion of successfull or unsuccessful request. This block has no return value and takes two argumens: the URL object which was provided as param from where image was downloaded, the image object. If request was unsuccessful image object will be nil.
 */
- (void) cachedImageWithUrl:(NSURL *) imageURL
                 completion:(CSImageDownloadBlock) imageRequestBlock;


/**
 Finds image in imagesCache and returns it back as return value.
 Use this method if you want to determen if your image is in imagesCache.

 @param imageURL The URL which holds the image. 
 
 @return A image object if exists in imagesCache. If image is not in imagesCache returns nil.
 
 */
- (UIImage *) imageWithUrl:(NSURL *) imageURL;

@end
