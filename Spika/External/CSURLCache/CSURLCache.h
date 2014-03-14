//
//  CSURLCache.h
//  CSUtilities
//
//  Created by marko.hlebar on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <UIKit/UIImage.h>

NS_CLASS_AVAILABLE_IOS(4_0)
@interface CSURLCache : NSObject

@property (nonatomic, copy) NSString *directoryPath;
@property (nonatomic, copy) NSDictionary *urlDictionary;
@property (nonatomic, readwrite) NSUInteger cacheSize;

/*
 *  Set whather you want to use fast caching with NSCache
 *  If YES then CSURLCache will chache images
 *  In case of memory warning all images are removed from cache
 *  Default is YES
 */
@property (nonatomic, readwrite) BOOL shouldUseFastCache;

#pragma mark - Initialization

/**
 Designated initializer
 
 @param path The name of directory you want to use for caching your data. If directory does not exist CSURLCache will create it.
 */
- (id) initWithRelativeDirectoryPath:(NSString *) path;

#pragma mark - Saving PNG Images

/**
 Caches given PNG image for given url. Cache will name image in format "current timestamp + url's lastPathComponent".
 
 @param image The image that needs to be cached.
 @param url The url key that will be used for caching
 */
- (void) cachePNGImage:(UIImage *)image
                   URL:(NSURL *)url;

/**
 Caches given PNG image for given request. Cache will name image in format "current timestamp + request.url lastPathComponent".
 
 @param image The image that needs to be cached.
 @param request The request key that will be used for caching
 */
- (void) cachePNGImage:(UIImage *)image
               request:(NSURLRequest *)request;

#pragma mark - Saving JPEG Images

/**
 Caches given JPEG image for given url. Cache will name image in format "current timestamp + url's lastPathComponent".
 
 @param image The image that needs to be cached.
 @param url The url key that will be used for caching
 @param compressionQuality A compression quality that will be used for caching. Value can have range 0(most)..1(least)
 */
- (void) cacheJPEGImage:(UIImage *)image
                    URL:(NSURL *)url
    compressionQuality:(CGFloat)compressionQuality;

/**
 Caches given JPEG image for given request. Cache will name image in format "current timestamp + request.url lastPathComponent".
 
 @param image The image that needs to be cached.
 @param request The request key that will be used for caching
 @param compressionQuality A compression quality that will be used for caching. Value can have range 0(most)..1(least)
 */
- (void) cacheJPEGImage:(UIImage *)image
                request:(NSURLRequest *)request
     compressionQuality:(CGFloat)compressionQuality;

#pragma mark - Saving NSData

/**
 Caches given data for given url. Cache will name data in format "current timestamp + url's lastPathComponent".
 
 @param data The data that needs to be cached.
 @param url The url key that will be used for caching
 */
- (void) cacheData:(NSData *) data
               URL:(NSURL *) url;

/**
 Caches given data for given url. Cache will name data with given filename param
 
 @param data The data that needs to be cached.
 @param url The url key that will be used for caching
 @param filename Then name used for naming data in cache. This value must not be nil.
 */
- (void) cacheData:(NSData *)data
               URL:(NSURL *)url
          filename:(NSString *)filename;

/**
 Caches given data for given request. Cache will name data in format "current timestamp + request.url lastPathComponent".
 
 @param data The data that needs to be cached.
 @param request The request key that will be used for caching
 */
- (void) cacheData:(NSData *)data
           request:(NSURLRequest *)request;

#pragma mark - Getting UIImages

/**
 Finds image for given url key in cache.
 
 @param url The url which was used for cache image
 
 @return A image object if exists in cache. If image is not in cache returns nil.
 */
- (UIImage *) imageForURL:(NSURL *)url;

/**
 Finds image for given request key in cache.
 
 @param request The request which was used for cache image
 
 @return A image object if exists in cache. If image is not in cache returns nil.
 */
- (UIImage *) imageForRequest:(NSURLRequest *)request;

/**
 *  Finds image for given URL in memory cache
 *
 *  @param url The url which was used for cache image
 *
 *  @return A image object if exists in cache. If image is not in cache returns nil.
 */
- (UIImage *)fastCacheImageForURL:(NSURL *)url;

/**
 *  Finds image for given request in memory cache.
 *
 *  @param url The request which was used for cache image.
 *
 *  @return A image object if exists in cache. If image is not in cache returns nil.
 */
- (UIImage *)fastCacheImageForRequest:(NSURLRequest *)request;

#pragma mark - Getting NSData

/**
 Finds data for given url key in cache.
 
 @param url The url which was used for cache data
 
 @return A data object if exists in cache. If data is not in cache returns nil.
 */
- (NSData *) dataForURL:(NSURL *) url;

/**
 Finds data for given request key in cache.
 
 @param request The request which was used for cache data
 
 @return A data object if exists in cache. If data is not in cache returns nil.
 */
- (NSData *) dataForRequest:(NSURLRequest *)request;

/**
 *  Finds data for given URL in memory cache.
 *
 *  @param url The url which was used for cache data.
 *
 *  @return A data object if exists in cache. If data is not in cache returns nil.
 */
- (NSData *)fastCacheDataForURL:(NSURL *)url;

/**
 *  Finds data for given request in memory cache.
 *
 *  @param request The request which was used for cache data.
 *
 *  @return A data object if exists in cache. If data is not in cache returns nil.
 */
- (NSData *)fastCacheDateForRequest:(NSURLRequest *)request;

#pragma mark - Directory Options

/**
 Clears whole directory. If shouldUseFastCache is set to YES, fast cache will also be erased.
 */
- (void) clearDirectory;

/**
 
 @return A unsigned integer value of cache directory size.
 */
- (NSUInteger) size;

@end
