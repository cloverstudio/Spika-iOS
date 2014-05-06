//
//  CSWebServicesManager.m
//  CSWebServicesManager
//
//  Created by Giga on 4/12/13.
//  Copyright (c) 2013 Clover-Studio. All rights reserved.
//

#import "CSWebServicesManager.h"
#import "CSUReachability.h"
#import "CSURLCache.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFXMLRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "XMLReader.h"

#define kTagNoInternetAlert     24992

static NSString * Base64EncodedStringFromString(NSString *string);

NSString * const CSWebServicesManagerInternerDidBecomeAvailableNotification     = @"com.cswebservicesmanager.internet_did_become_available.notification";
NSString * const CSWebServicesManagerInternerDidBecomeUnavailableNotification   = @"com.cswebservicesmanager.internet_did_become_unavailable.notification";

CSHTTPMethod const CSHTTPMethodGET          = @"GET";
CSHTTPMethod const CSHTTPMethodPOST         = @"POST";
CSHTTPMethod const CSHTTPMethodPUT          = @"PUT";
CSHTTPMethod const CSHTTPMethodDELETE       = @"DELETE";

@interface CSWebServicesManager () {

    NSOperationQueue    *_servicesQueue;
    NSMutableArray      *_alertsArray;
    
    AFHTTPClient        *_httpClient;
    
//    CSURLCache          *_urlCache; //Cache used for caching UIImages
    NSOperationQueue    *_imagesQueue; //NSOperationQueue used for downloading images
    dispatch_queue_t    _imagesCacheQueue; //GDC queue used for getting images from cache
}

#pragma mark - Executing Requests
- (AFHTTPRequestOperation *) doRequestWithType:(NSString *)type
                                 operationType:(CSWebOperatonType) operationType
                                           url:(NSString *)apiPath
                                        params:(NSDictionary *)params
                                   resultBlock:(CSResultBlock)resultBlock
                                    errorBlock:(CSErrorBlock)errorBlock
                           uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
                         downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock;

#pragma mark - Configuration
- (NSSet *) defaultAcceptableContentTypesForOperationType:(CSWebOperatonType)type;

#pragma mark InternetConnection
-(void) startCheckingInternetConnection;

#pragma mark - Errors
- (NSError *) noInternetError;

#pragma mark - Error Code Check
-(void) checkError:(NSError *)error;

#pragma mark - Hiding Alerts
-(void) hideAlertWithTag:(NSUInteger) tag
                animated:(BOOL) animated;

#pragma mark - Alerts
- (void) showNoInternetAlert;
- (void) hideNoInternetAlert;

@property (nonatomic, retain) CSUReachability *reachability;

@end

@implementation CSWebServicesManager

@synthesize baseUrl = _baseUrl;
@synthesize authorizationHeaderUsername = _authorizationHeaderUsername;
@synthesize authorizationHeaderPassword = _authorizationHeaderPassword;
@synthesize headerValues = _headerValues;
@synthesize maxNumberOfDataOperations = _maxNumberOfDataOperations;
@synthesize maxNumberOfImagesOperations = _maxNumberOfImagesOperations;
@synthesize isInternetAvailable = _isInternetAvailable;
@synthesize shouldDisplayNoInternetAlert = _shouldDisplayNoInternetAlert;
@synthesize showNetworkActivityIndicator = _showNetworkActivityIndicator;
@synthesize shouldUseFastCaching = _shouldUseFastCaching;
@synthesize localizedInternetError = _localizedInternetError;
@synthesize reachability = _reachability;
@synthesize imagesCacheQueuePriority = _imagesCacheQueuePriority;

+ (CSWebServicesManager *) webServicesManager {

    @synchronized(self) {
    
        static CSWebServicesManager *_instance = nil;
        if (!_instance) {
            _instance = [[self alloc] init];
        }
        return _instance;
    }
}

#pragma mark - Memory Management

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCSUReachabilityChangedNotification
                                                  object:nil];
    
    [self removeObserver:self
              forKeyPath:@"baseUrl"];
    
    [self removeObserver:self
              forKeyPath:@"maxNumberOfDataOperations"];
    
    [self removeObserver:self
              forKeyPath:@"maxNumberOfImagesOperations"];
    
    [self removeObserver:self
              forKeyPath:@"showNetworkActivityIndicator"];
    
    [self removeObserver:self
              forKeyPath:@"shouldUseFastCaching"];
    
    [self removeObserver:self
              forKeyPath:@"imagesCacheQueuePriority"];
}

#pragma mark - Initialization

- (id) init {
    
    if (self = [super init]) {
        
        [self startCheckingInternetConnection];
        
        _alertsArray = [[NSMutableArray alloc] init];
        
        _localizedInternetError = @"Internet connection is not available";
                
        _servicesQueue = [[NSOperationQueue alloc] init];
        _servicesQueue.maxConcurrentOperationCount = 2;
        
        _imagesQueue = [[NSOperationQueue alloc] init];
        _imagesQueue.maxConcurrentOperationCount = 2;
        
        _imagesCacheQueuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        
        _imagesCacheQueue = dispatch_get_global_queue(_imagesCacheQueuePriority, 0);
        
        _urlCache = [[CSURLCache alloc] initWithRelativeDirectoryPath:[NSString stringWithFormat:@"%@/images", [[NSBundle mainBundle] bundleIdentifier]]];
                
        //Configure AFNetworking acceptableContentTypes
        
        [[AFHTTPRequestOperation class] addAcceptableContentTypes:[self defaultAcceptableContentTypesForOperationType:CSWebOperatonTypeDefault]];
        
        [[AFJSONRequestOperation class] addAcceptableContentTypes:[self defaultAcceptableContentTypesForOperationType:CSWebOperatonTypeJSON]];
        
        [[AFXMLRequestOperation class] addAcceptableContentTypes:[self defaultAcceptableContentTypesForOperationType:CSWebOperatonTypeXML]];
        
        
        [self addObserver:self
               forKeyPath:@"baseUrl"
                  options:0
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"maxNumberOfDataOperations"
                  options:0
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"maxNumberOfImagesOperations"
                  options:0
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"showNetworkActivityIndicator"
                  options:0
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"shouldUseFastCaching"
                  options:0
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"imagesCacheQueuePriority"
                  options:0
                  context:NULL];
    }
    
    return self;
}

#pragma mark - Observer 

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {
    
    if ([keyPath isEqualToString:@"baseUrl"]) {
            
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_baseUrl]];
    }
    else if ([keyPath isEqualToString:@"maxNumberOfDataOperations"]) {
        
        _servicesQueue.maxConcurrentOperationCount = _maxNumberOfDataOperations;
    }
    else if ([keyPath isEqualToString:@"maxNumberOfImagesOperations"]) {
    
        _imagesQueue.maxConcurrentOperationCount = _maxNumberOfImagesOperations;
    }
    else if ([keyPath isEqualToString:@"showNetworkActivityIndicator"]) {
    
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:_showNetworkActivityIndicator];
    }
    else if ([keyPath isEqualToString:@"shouldUseFastCaching"]) {
    
        _urlCache.shouldUseFastCache = _shouldUseFastCaching;
    }
    else if ([keyPath isEqualToString:@"imagesCacheQueuePriority"]) {
    
        
        dispatch_set_target_queue(dispatch_get_global_queue(_imagesCacheQueuePriority, 0),
                                  _imagesCacheQueue);
    }
}

#pragma mark InternetConnection

- (void) startCheckingInternetConnection {
    
    if (self.reachability == nil) {
        
        _isInternetAvailable = NO;
        
        void (^reachableBlock)() = ^(CSUReachability * reachability) {
            [self checkReachability:reachability];
        };
         
        void (^unreachableBlock)() = ^(CSUReachability * reachability) {
            [self checkReachability:reachability];
        };
        
        self.reachability = [CSUReachability reachabilityWithHostname:@"www.example.com"];
        self.reachability.reachableBlock = reachableBlock;
        self.reachability.unreachableBlock = unreachableBlock;
        
        [_reachability startNotifier];
    }
}

- (void)checkReachability:(CSUReachability *)reachability {

    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
	
	if(remoteHostStatus == NotReachable) {
        
        _isInternetAvailable = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CSWebServicesManagerInternerDidBecomeUnavailableNotification
                                                            object:nil];
        
#ifdef DEBUG
        NSLog(@"Internet did become unavailable");
#endif
    }
	else if (remoteHostStatus == ReachableViaWiFi || remoteHostStatus == ReachableViaWWAN) {
        
        _isInternetAvailable = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CSWebServicesManagerInternerDidBecomeAvailableNotification
                                                            object:nil];
        
#ifdef DEBUG
        NSLog(@"Internet did become available");
#endif
    }
}

- (BOOL) isInternetAvailable {
    return [_reachability isReachable];
}

#pragma mark - Errors

- (NSError *) noInternetError {
    
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"Can't perform request. Internet connection is not available" forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:errorDetail];
}

#pragma mark - Error Code Check

-(void) checkError:(NSError *)error {
    
    if (error.code == NSURLErrorNotConnectedToInternet && _shouldDisplayNoInternetAlert) {
        
        [self showNoInternetAlert];
    }
}

#pragma mark - Executing Requests
#pragma mark - Private

- (AFHTTPRequestOperation *) doRequestWithType:(NSString *)type
                                 operationType:(CSWebOperatonType) operationType
                                           url:(NSString *)apiPath
                                      fileData:(NSData*) fileData
                                      fileName:(NSString*) fileName
                                      mimeType:(NSString*) mimeType
                                        params:(NSDictionary *)params
                                   resultBlock:(CSResultBlock)resultBlock
                                    errorBlock:(CSErrorBlock)errorBlock
                           uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
                         downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {
    
    if (![self isInternetAvailable]) {
        
        [self checkError:[self noInternetError]];
        
        if (errorBlock)
            errorBlock([self noInternetError]);
        
        return nil;
    }
    
    if (!_baseUrl) {
        NSLog(@"Cannot connect without BaseUrl!");
        return nil;
    }
    
    [_httpClient clearAuthorizationHeader];
    
    if (_authorizationHeaderUsername && _authorizationHeaderPassword) {
        
        [_httpClient setAuthorizationHeaderWithUsername:_authorizationHeaderUsername
                                               password:_authorizationHeaderPassword];
    }
    
    for (NSString *key in [_headerValues allKeys]) {
        
        [_httpClient setDefaultHeader:key
                                value:[_headerValues objectForKey:key]];
    }
    
    //This is very important because if we do not set "text/html" then JSON parser will always complain about it
    //And will not parse our resposne at all
    
    if (operationType == CSWebOperatonTypeDefault) {
        
        [_httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    }
    else if (operationType == CSWebOperatonTypeJSON) {
        
        [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        [_httpClient setParameterEncoding:AFJSONParameterEncoding];
    }
    else {
        
        [_httpClient registerHTTPOperationClass:[AFXMLRequestOperation class]];
    }
    
    apiPath = [apiPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = nil;
    
    if (fileData) {
        urlRequest = [_httpClient multipartFormRequestWithMethod:type
                                                            path:apiPath
                                                      parameters:params
                                       constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                           [formData appendPartWithFileData:fileData
                                                                       name:fileName
                                                                   fileName:fileName
                                                                   mimeType:mimeType];
                                       }];
    }
    else {
        urlRequest = [_httpClient requestWithMethod:type
                                               path:apiPath
                                         parameters:params];
    }
    
    AFHTTPRequestOperation *operation = [self requestOperationForType:operationType
                                                          withRequest:urlRequest];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([operation isKindOfClass:[AFXMLRequestOperation class]]) {
            
            NSError *error = nil;
            
            NSDictionary *responseDict = [XMLReader dictionaryForXMLData:operation.responseData
                                                                 options:XMLReaderOptionsProcessNamespaces
                                                                   error:&error];
            
            if (!error && resultBlock) {
                resultBlock(responseDict);
                return;
            }
            else if (error && errorBlock) {
                errorBlock(error);
                return;
            }
        }
        
        if (resultBlock)
            resultBlock(responseObject);
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError* error) {
                                         
                                         [self checkError:error];
                                         
                                         if (errorBlock)
                                             errorBlock(error);
                                     }
     ];
    
    [operation setUploadProgressBlock:uploadProgressBlock];
    [operation setDownloadProgressBlock:downloadProgressBlock];
    
    [_servicesQueue addOperation:operation];
    
    return (AFHTTPRequestOperation *)operation;

}

- (AFHTTPRequestOperation *) doRequestWithType:(NSString *)type
                                 operationType:(CSWebOperatonType) operationType
                                           url:(NSString *)apiPath
                                        params:(NSDictionary *)params
                                   resultBlock:(CSResultBlock)resultBlock
                                    errorBlock:(CSErrorBlock)errorBlock
                           uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
                         downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {
    
    return [self doRequestWithType:type
                     operationType:operationType
                               url:apiPath
                          fileData:nil
                          fileName:nil
                          mimeType:nil
                            params:params
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:uploadProgressBlock
             downloadProgressBlock:downloadProgressBlock];
}

- (id) requestOperationForType:(CSWebOperatonType)type withRequest:(NSURLRequest *)urlRequest {

    if (type == CSWebOperatonTypeDefault) {
        return [_httpClient HTTPRequestOperationWithRequest:urlRequest
                                                    success:nil failure:nil];
    }
    else if (type == CSWebOperatonTypeJSON) {
        return [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
    }
    else {
        return [[AFXMLRequestOperation alloc] initWithRequest:urlRequest];
    }
}

#pragma mark - Setter Override

- (void) setHeaderValues:(NSDictionary *)headerValues {

    @synchronized(self) {
    
        _headerValues = nil;
        _headerValues = [[NSDictionary alloc] initWithDictionary:headerValues];
    }
}

- (void) setParameterEncoding:(AFHTTPClientParameterEncoding)parameterEncoding {
    _httpClient.parameterEncoding = parameterEncoding;
}

- (AFHTTPClientParameterEncoding) parameterEncoding {
    return _httpClient.parameterEncoding;
}

#pragma mark - Configuration

- (void) addAcceptableContentTypes:(NSSet *)contentTypes
                  forOperationType:(CSWebOperatonType)operationType {

    if (operationType == CSWebOperatonTypeDefault) {
        
        [[AFHTTPRequestOperation class] addAcceptableContentTypes:contentTypes];
    }
    else if (operationType == CSWebOperatonTypeJSON) {
        
        
        [[AFJSONRequestOperation class] addAcceptableContentTypes:contentTypes];
    }
    else {
        
        [[AFXMLRequestOperation class] addAcceptableContentTypes:contentTypes];
    }
}

- (NSSet *) defaultAcceptableContentTypesForOperationType:(CSWebOperatonType)type {

    if (type == CSWebOperatonTypeDefault) {
        
        return [NSSet setWithObjects:@"text/html", @"text/plain", @"application/json", nil];
    }
    else if (type == CSWebOperatonTypeJSON) {
    
        
        return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    }
    else {
    
        return [NSSet setWithObjects:@"application/xml", @"text/xml", @"text/html", @"text/plain", nil];
    }
}

#pragma mark - Hiding Alerts

-(void) hideAlertWithTag:(NSUInteger) tag
                animated:(BOOL) animated {
    
    for (int i=0; i<_alertsArray.count; i++) {
        
        id object = [_alertsArray objectAtIndex:i];
        if (![object isKindOfClass:[UIAlertView class]])
            return;
        
        UIAlertView *alertView = [_alertsArray objectAtIndex:i];
        if (alertView.tag == tag) {
            
            [alertView dismissWithClickedButtonIndex:0 animated:animated];
            [_alertsArray removeObjectAtIndex:i];
            i--;
            return;
        }
    }
}

#pragma mark - Alerts

-(void) showNoInternetAlert {
    
    [self hideAlertWithTag:kTagNoInternetAlert animated:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                        message:_localizedInternetError
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = kTagNoInternetAlert;
    [_alertsArray addObject:alertView];
    [alertView show];
}

-(void) hideNoInternetAlert {
    
    [self hideAlertWithTag:kTagNoInternetAlert
                  animated:NO];
}


#pragma mark - Public

#pragma mark - Cache Controll

- (void) clearCache {

    [_urlCache clearDirectory];
}

#pragma mark - Executing Requests

-(AFHTTPRequestOperation*) doRequest:(NSString*) apiPath
                              method:(CSHTTPMethod) method
                              params:(NSDictionary*) params
                       operationType:(CSWebOperatonType) operationType
                         resultBlock:(CSResultBlock) resultBlock
                        failureBlock:(CSErrorBlock) errorBlock {
    return [self doRequestWithType:method
                     operationType:operationType
                               url:apiPath
                            params:params
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:nil
             downloadProgressBlock:nil];
    
}


- (AFHTTPRequestOperation *) doPost:(NSString *) apiPath
                      operationType:(CSWebOperatonType) operationType
                           fileData:(NSData*) fileData
                           fileName:(NSString*) fileName
                           mimeType:(NSString*) mimeType
                             params:(NSDictionary *) params
                        resultBlock:(CSResultBlock) resultBlock
                       failureBlock:(CSErrorBlock) errorBlock
                uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
              downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {

    return [self doRequestWithType:CSHTTPMethodPOST
                     operationType:operationType
                               url:apiPath
                          fileData:fileData
                          fileName:fileName
                          mimeType:mimeType
                            params:params
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:uploadProgressBlock
             downloadProgressBlock:downloadProgressBlock];
}

- (AFHTTPRequestOperation *) doPost:(NSString *) apiPath
                      operationType:(CSWebOperatonType) operationType
                             params:(NSDictionary *) params
                        resultBlock:(CSResultBlock) resultBlock
                       failureBlock:(CSErrorBlock) errorBlock
                uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
              downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {

    return [self doRequestWithType:CSHTTPMethodPOST
                     operationType:operationType
                               url:apiPath
                            params:params
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:uploadProgressBlock
             downloadProgressBlock:downloadProgressBlock];
}

- (AFHTTPRequestOperation *) doPut:(NSString *) apiPath
                     operationType:(CSWebOperatonType) operationType
                            params:(NSDictionary *) params
                       resultBlock:(CSResultBlock) resultBlock
                      failureBlock:(CSErrorBlock) errorBlock
               uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
             downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {

    return [self doRequestWithType:CSHTTPMethodPUT
                     operationType:operationType
                               url:apiPath
                            params:params
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:uploadProgressBlock
             downloadProgressBlock:downloadProgressBlock];
}


- (AFHTTPRequestOperation *) doGet:(NSString *) apiPath
                     operationType:(CSWebOperatonType) operationType
                       resultBlock:(CSResultBlock) resultBlock
                      failureBlock:(CSErrorBlock) errorBlock
               uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
             downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {

    return [self doRequestWithType:CSHTTPMethodGET  
                     operationType:operationType
                               url:apiPath
                            params:nil
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:uploadProgressBlock
             downloadProgressBlock:downloadProgressBlock];
}

- (AFHTTPRequestOperation *) doDelete:(NSString *) apiPath
                               params:(NSDictionary *) params
                        operationType:(CSWebOperatonType) operationType
                          resultBlock:(CSResultBlock) resultBlock
                         failureBlock:(CSErrorBlock) errorBlock
                  uploadProgressBlock:(CSUploadProgressBlock)uploadProgressBlock
                downloadProgressBlock:(CSDownloadProgressBlock)downloadProgressBlock {

    return [self doRequestWithType:CSHTTPMethodDELETE   
                     operationType:operationType
                               url:apiPath
                            params:params
                       resultBlock:resultBlock
                        errorBlock:errorBlock
               uploadProgressBlock:uploadProgressBlock
             downloadProgressBlock:downloadProgressBlock];
}

@end

#pragma mark - CSWebServicesManager (ImageDownload)

@implementation CSWebServicesManager (ImageDownload)

#pragma mark - Public

- (void) imageFromURL:(NSURL*) imageUrl
           completion:(CSImageDownloadBlock) completionHandler {
    
    void (^imageHandlerInternal)(NSURL *, UIImage *) = ^(NSURL *imageURL, UIImage *image) {
        
        if(image && completionHandler) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionHandler (imageURL, image);
            });
        }
        else
            [self downloadImage:imageUrl
                     completion:completionHandler];
    };
    
    [self cachedImageWithUrl:imageUrl
                  completion:imageHandlerInternal];
}

- (void) cachedImageWithUrl:(NSURL *) imageUrl
                completion:(CSImageDownloadBlock) imageRequestBlock {
    
    dispatch_async(_imagesCacheQueue, ^{
        
        UIImage *image = [_urlCache imageForURL:imageUrl];
        
        if (imageRequestBlock)
            imageRequestBlock(imageUrl, image);
    });
}

- (UIImage *) imageWithUrl:(NSURL *) imageUrl {
    
    return [_urlCache imageForURL:imageUrl];
}

#pragma mark - Private

- (void) downloadImage:(NSURL *)imageUrl
            completion:(CSImageDownloadBlock)completionHandler {
    
    if (!self.isInternetAvailable) return;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:imageUrl];
    
    if (_authorizationHeaderUsername && _authorizationHeaderPassword) {
        
        NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@",
                                          _authorizationHeaderUsername,
                                          _authorizationHeaderPassword];
        
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", Base64EncodedStringFromString(basicAuthCredentials)];
        
        [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    for (NSString *key in [_headerValues allKeys]) {
        
        [urlRequest setValue:[_headerValues objectForKey:key]
          forHTTPHeaderField:key];
    }
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:_imagesQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (data) {
             
             UIImage *downloadedImage = [UIImage imageWithData:data];
             if (downloadedImage) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if(completionHandler)
                         completionHandler(response.URL, downloadedImage);
                 });
                 
            
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){
                     [_urlCache cacheData:data URL:response.URL];
                 });
                 
             }
             else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if(completionHandler)
                         completionHandler(response.URL, nil);
                 });
             }
         }
         else {
             if(completionHandler)
                 completionHandler(response.URL, nil);
         }
     }];
}

@end

static NSString * Base64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}


