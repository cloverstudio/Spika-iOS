//
//  CSURLCache.m
//  CSUtilities
//
//  Created by marko.hlebar on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSURLCache.h"

@interface CSURLCache () {

    NSCache     *_imagesCache;
}

#pragma mark - Directory Options
- (void) createDirectory;
- (NSString*) cachePlist;
- (BOOL) clearDataOfSize:(NSUInteger) size;
- (NSDictionary*) URLDictionary;

#pragma mark - Files Manipulation
- (void) addFilePath:(NSString *)filePath forURL:(NSURL*) url;
- (void) removeFilePath:(NSString *) filePath;

#pragma mark - Paths
- (NSString*) cachePath;

#pragma mark - Cache
- (NSCache *) imagesCache;
- (void) removeImagesCache;

@end

@implementation CSURLCache
@synthesize directoryPath = _directoryPath;
@synthesize cacheSize = _cacheSize;
@synthesize urlDictionary = _urlDictionary;
@synthesize shouldUseFastCache = _shouldUseFastCache;

#pragma mark - Memory Management

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];

    [self removeObserver:self
              forKeyPath:@"directoryPath"];
}

#pragma mark - Initialization

- (id) initWithRelativeDirectoryPath:(NSString*) relativePath {
    
    if (self = [super init]) {
        
        [self addObserver:self forKeyPath:@"directoryPath" options:0 context:NULL];
                        
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                                diskCapacity:0
                                                                    diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        if (relativePath) {
            self.directoryPath = relativePath;
        }
        
        self.cacheSize = 1024*1024*20; ///20MB default
        
        self.shouldUseFastCache = YES;
        
        __weak id this = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *aNotification) {
                                                      
                                                          __strong CSURLCache *strongThis = this;
                                                          [strongThis.imagesCache removeAllObjects];
                                                      }];
    }
    
    return self;
}

- (id) init {
    
    return [self initWithRelativeDirectoryPath:nil];
}

#pragma mark - Observing

- (void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"directoryPath"]) {
        
        [self createDirectory];
        self.urlDictionary = [self URLDictionary];
    }
    else if ([keyPath isEqualToString:@"shouldUseFastCache"]) {
    
        if (!_shouldUseFastCache)
            [self removeImagesCache];
        
        else
            [self imagesCache];
    }
}

#pragma mark - Directory Options

- (void) clearDirectory {
    
    @synchronized(self) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [self cachePath];  
        NSMutableArray *files = [NSMutableArray arrayWithArray: [fileManager contentsOfDirectoryAtPath:cachePath error:nil]];

        for (NSString *relativePath in files) {
            
            NSString *fullPath = [cachePath stringByAppendingPathComponent:relativePath];
            [fileManager removeItemAtPath:fullPath error:nil];
        }
        self.urlDictionary = [self URLDictionary];
        
        if (_shouldUseFastCache) {
            [[self imagesCache] removeAllObjects];
        }
    }
}

- (NSUInteger) size {
  
    NSUInteger sum = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:[self cachePath] error:&error];
    
    for (NSString *filePath in files) {
        
        NSString *fullPath = [[self cachePath] stringByAppendingPathComponent:filePath];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
        NSUInteger size = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];
        sum += size;
    }
    
    return sum;
}

#pragma mark - Public

#pragma mark - Saving PNG Images

- (void) cachePNGImage:(UIImage *)image
                   URL:(NSURL *)url {
    
    [self cacheData:UIImagePNGRepresentation(image) URL:url];
}

- (void) cachePNGImage:(UIImage *)image
               request:(NSURLRequest *)request {
    
    [self cacheData:UIImagePNGRepresentation(image)
                URL:request.URL];
}

#pragma mark - Saving JPEG Images

- (void) cacheJPEGImage:(UIImage *) image
                    URL:(NSURL *) url
     compressionQuality:(CGFloat) compressionQuality {
    
    [self cacheData:UIImageJPEGRepresentation(image, compressionQuality) URL:url];
}

- (void) cacheJPEGImage:(UIImage *)image
                request:(NSURLRequest *) request
     compressionQuality:(CGFloat) compressionQuality {
    
    [self cacheData:UIImageJPEGRepresentation(image, compressionQuality) URL:request.URL];
}

#pragma mark - Saving NSData

- (void) cacheData:(NSData *)data URL:(NSURL *)url {
    
    [self cacheData:data URL:url filename:[NSString stringWithFormat:@"%lf%@",
                                           [NSDate timeIntervalSinceReferenceDate],
                                           [[url absoluteString] lastPathComponent]]];
}

- (void) cacheData:(NSData *)data
               URL:(NSURL *) url
          filename:(NSString *) filename {
    
    @synchronized(self) {
    
        if (_shouldUseFastCache) {
            [[self imagesCache] setObject:data forKey:url];
        }
        
        ///if size of data exceeds cacheSize, just return
        if (![self clearDataOfSize:[data length]])
            return;
        
        NSString *dataPath = [[self cachePath] stringByAppendingPathComponent:filename];
        if ([data writeToFile:dataPath atomically:YES]) {
            
            [self addFilePath:dataPath forURL:url];
        }
        else {
            NSLog(@"error adding song");
        }
    }
}

- (void) cacheData:(NSData *) data request:(NSURLRequest *) request {
    
    @synchronized(self) {
    
        if (_shouldUseFastCache) {
            [[self imagesCache] setObject:data forKey:request.URL];
        }
        
        [self cacheData:data URL:request.URL];
    }
}

#pragma mark - Getting UIImages

- (UIImage *) imageForURL:(NSURL *) url {
    
    @synchronized(self) {
        
        NSCache *cache = [self imagesCache];
        
        if (_shouldUseFastCache) {
            
            id image = [cache objectForKey:url];
            
            if (image) {
                
                return ([image isKindOfClass:[UIImage class]] ?
                        (UIImage *)image :
                        ([image isKindOfClass:[NSData class]] ? [UIImage imageWithData:(NSData *)image] : nil));
            }
        }
        
        NSString *path = [self.urlDictionary objectForKey:[url absoluteString]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (_shouldUseFastCache) {
                [cache setObject:image forKey:url];
            }
            
            return [UIImage imageWithContentsOfFile:path];
        }
        
        return nil;
    }
}

- (UIImage *) imageForRequest:(NSURLRequest *) request {
    return [self imageForURL:request.URL];
}

- (UIImage *)fastCacheImageForURL:(NSURL *)url {

    @synchronized(self) {
        
        id image = [[self imagesCache] objectForKey:url];
        return ([image isKindOfClass:[UIImage class]] ?
                (UIImage *)image :
                ([image isKindOfClass:[NSData class]] ? [UIImage imageWithData:(NSData *)image] : nil));
    }
}

- (UIImage *)fastCacheImageForRequest:(NSURLRequest *)request {
    return [self fastCacheImageForURL:request.URL];
}

#pragma mark - Getting NSData

- (NSData *) dataForURL:(NSURL *) url {
    
    @synchronized(self) {
    
        NSCache *cache = [self imagesCache];
        if ([cache objectForKey:url]) {
            return [cache objectForKey:url];
        }
        
        return [NSData dataWithContentsOfFile:[self.urlDictionary objectForKey:[url absoluteString]]];
    }
}

- (NSData *) dataForRequest:(NSURLRequest*) request {
    return [self dataForURL:request.URL];
}

- (NSData *)fastCacheDataForURL:(NSURL *)url {

    @synchronized(self) {
        return [[self imagesCache] objectForKey:url];
    }
}

- (NSData *)fastCacheDateForRequest:(NSURLRequest *)request {
    return [self fastCacheDataForURL:request.URL];
}

#pragma mark - Private

#pragma mark - Directory Options

- (void) createDirectory {
    
    @synchronized(self) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [self cachePath];
        if (![fileManager fileExistsAtPath:cachePath]) {
            
            NSError *error = nil;
            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            NSLog(@"error creating directory %@ %@", [self cachePath], [error localizedDescription]);
        }
    }
}

///clears the oldest files in cache
- (BOOL) clearDataOfSize:(NSUInteger) size {
    
    if (size > self.cacheSize) return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *files = [NSMutableArray arrayWithArray: [fileManager contentsOfDirectoryAtPath:[self cachePath] error:nil]];
    
    while ([self size] + size > self.cacheSize) {
        
        if (files.count == 0) break;
        
        NSMutableString *oldestFullPath = [NSMutableString string];
        NSDate *oldestDate = [[NSDate date] copy];
        NSString *oldestFilePath = nil;   
        NSString *cachePath = [self cachePath];
        
        ///delete oldest files from the cache.
        for (NSString *filePath in files) {
            
            NSString *fullPath = [cachePath stringByAppendingPathComponent:filePath];
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
            NSDate *date = (NSDate*)[attributes objectForKey:NSFileCreationDate];
            
            if ([oldestDate compare:date] == NSOrderedDescending) {
                
                oldestDate = [date copy];
                [oldestFullPath setString:fullPath];
                oldestFilePath = filePath;
            }
        }
        
        [fileManager removeItemAtPath:oldestFullPath error:nil];
        [files removeObject:oldestFilePath];
        [self removeFilePath:oldestFullPath];
    }
    
    return YES;
}

- (NSDictionary *) URLDictionary {
    
    return [NSDictionary dictionaryWithContentsOfFile:[self cachePlist]];
}

- (NSString *) cachePlist {
    
    return [[self cachePath] stringByAppendingPathComponent:@"cache.plist"];
}

#pragma mark - Files Manipulation

- (void) addFilePath:(NSString *)filePath forURL:(NSURL *) url {
    
    @synchronized(self) {
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.urlDictionary];
        [dictionary setObject:filePath forKey:[url absoluteString]];
        if ([dictionary writeToFile:[self cachePlist] atomically:YES]) {
            
            self.urlDictionary = dictionary;
        }
        else {
            
            NSLog(@"error writing to file %@", [self cachePlist]);
        }
    }
}

- (void) removeFilePath:(NSString*) filePath {
    
    @synchronized(self) {
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.urlDictionary];
        for (NSString *key in [dictionary allKeys]) {
            
            NSString *path = [dictionary objectForKey:key];
            if ([path isEqualToString:filePath]) {
                
                [dictionary removeObjectForKey:key];
                break;
            }
        }
        
        if ([dictionary writeToFile:[self cachePlist] atomically:YES]) {
            
            self.urlDictionary = dictionary;
        }
        else {
            
            NSLog(@"error writing to file %@", [self cachePlist]);
        }
    }
}

#pragma mark - Paths

- (NSString *) cachePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:self.directoryPath];
}

#pragma mark - Cache

- (NSCache *) imagesCache {

    @synchronized(self) {
    
        if (!_imagesCache) {
            _imagesCache = [[NSCache alloc] init];
        }
        return _imagesCache;
    }

}

- (void) removeImagesCache {
    
    @synchronized(self) {
        [_imagesCache removeAllObjects];
        _imagesCache = nil;
    }
}

@end
