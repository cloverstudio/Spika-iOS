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

#import "HUHTTPClient.h"
#import "Constants.h"
#import "AFHTTPRequestOperationLogger.h"
#import "SBJSON.h"
#import "AFImageRequestOperation.h"
#import "NSString+MD5.h"
#import "AFHTTPClient+Synchronous.h"
#import "ModelUser.h"
#import "UserManager.h"

@implementation HUHTTPClient


+ (HUHTTPClient *)sharedClient {
    static HUHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HUHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:HttpRootURL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    
    self = [super initWithBaseURL:url];
    if (!self) {
        _baseURL = [NSString stringWithFormat:@"%@",url];
        return nil;
    }
    
    [self registerHTTPOperationClass:[HUHTTPClient class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Accept" value:@"audio/x-wav"];
    [self setDefaultHeader:@"Accept" value:@"audio/3gp"];
    [self setDefaultHeader:@"database" value:DatabaseName];

    _downloadingImageURL = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) setBaseUrl:(NSString *)url{

    
    
}

- (AFHTTPRequestOperation *) doPost:(NSString *) apiPath
                      operationType:(AFHTTPClientParameterEncoding) operationType
                             params:(NSDictionary *) params
                        resultBlock:(CSResultBlock) resultBlock
                       failureBlock:(CSErrorBlock) errorBlock
                uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
              downloadProgressBlock:(CSProgressBlock)downloadProgressBlock{
    
    [self setParameterEncoding:operationType];

    NSString* escapedUrlString =[apiPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [self postPath:escapedUrlString parameters:params
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               
               NSString* newStr = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
               
               SBJsonParser *parser = [[SBJsonParser alloc] init];
               id repr = [parser objectWithString:newStr];

               if(resultBlock)
                   resultBlock(repr);
               
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
               if(errorBlock)
                   errorBlock(error);
               
               NSString *responseBody = [error localizedRecoverySuggestion];
               SBJsonParser *parser = [[SBJsonParser alloc] init];
               id repr = [parser objectWithString:responseBody];
               
               if([repr isKindOfClass:[NSDictionary class]] && [repr objectForKey:@"message"] != nil){
                   [self handleLogicError:[repr objectForKey:@"message"]];
               }else{
                   [self handleCriticalError:error operation:operation];
               }
               
           }];

    
    return nil;
    
}

- (NSString *) doGetSynchronous:(NSURL *) url{
    
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];

    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:user._id forHTTPHeaderField:@"user_id"];
    [request setValue:user.token forHTTPHeaderField:@"token"];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    NSString* apiResponse = [NSString stringWithUTF8String:[data bytes]];

    return apiResponse;
}


- (AFHTTPRequestOperation *) doGet:(NSString *) apiPath
                     operationType:(AFHTTPClientParameterEncoding) operationType
                       resultBlock:(CSResultBlock) resultBlock
                      failureBlock:(CSErrorBlock) errorBlock
               uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
             downloadProgressBlock:(CSProgressBlock)downloadProgressBlock{

    [self setParameterEncoding:operationType];
    
    NSString* escapedUrlString =[apiPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self getPath:escapedUrlString parameters:nil
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               
               NSString* newStr = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
               
               SBJsonParser *parser = [[SBJsonParser alloc] init];
               id repr = [parser objectWithString:newStr];
               
               resultBlock(repr);
               
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               
               if(errorBlock)
                   errorBlock(error);
               
               NSString *responseBody = [error localizedRecoverySuggestion];
               SBJsonParser *parser = [[SBJsonParser alloc] init];
               id repr = [parser objectWithString:responseBody];
               
               if([repr isKindOfClass:[NSDictionary class]] && [repr objectForKey:@"message"] != nil){
                   [self handleLogicError:[repr objectForKey:@"message"]];
               }else{
                   [self handleCriticalError:error operation:operation];
               }

               
           }];
    
    
    return nil;
    
}


- (AFHTTPRequestOperation *) doPut:(NSString *) apiPath
                     operationType:(AFHTTPClientParameterEncoding) operationType
                            params:(NSDictionary *) params
                       resultBlock:(CSResultBlock) resultBlock
                      failureBlock:(CSErrorBlock) errorBlock
               uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
             downloadProgressBlock:(CSProgressBlock)downloadProgressBlock{
    
    
    [self setParameterEncoding:operationType];
    
    NSString* escapedUrlString =[apiPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self putPath:escapedUrlString parameters:params
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              
              NSString* newStr = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
              
              SBJsonParser *parser = [[SBJsonParser alloc] init];
              id repr = [parser objectWithString:newStr];
              
              resultBlock(repr);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if(errorBlock)
                  errorBlock(error);
              
              NSString *responseBody = [error localizedRecoverySuggestion];
              SBJsonParser *parser = [[SBJsonParser alloc] init];
              id repr = [parser objectWithString:responseBody];
              
              if([repr isKindOfClass:[NSDictionary class]] && [repr objectForKey:@"message"] != nil){
                  [self handleLogicError:[repr objectForKey:@"message"]];
              }else{
                  [self handleCriticalError:error operation:operation];
              }

              
          }];
    
    
    return nil;
    
}

- (AFHTTPRequestOperation *) doDelete:(NSString *) apiPath
                               params:(NSDictionary *) params
                        operationType:(AFHTTPClientParameterEncoding) operationType
                          resultBlock:(CSResultBlock) resultBlock
                         failureBlock:(CSErrorBlock) errorBlock
                  uploadProgressBlock:(CSProgressBlock)uploadProgressBlock
                downloadProgressBlock:(CSProgressBlock)downloadProgressBlock{
    
    
    [self setParameterEncoding:operationType];
    
    NSString* escapedUrlString =[apiPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self deletePath:escapedUrlString parameters:params
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              
              NSString* newStr = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
              
              SBJsonParser *parser = [[SBJsonParser alloc] init];
              id repr = [parser objectWithString:newStr];
              
              resultBlock(repr);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if(errorBlock)
                  errorBlock(error);
              
              NSString *responseBody = [error localizedRecoverySuggestion];
              SBJsonParser *parser = [[SBJsonParser alloc] init];
              id repr = [parser objectWithString:responseBody];
              
              if([repr isKindOfClass:[NSDictionary class]] && [repr objectForKey:@"message"] != nil){
                  [self handleLogicError:[repr objectForKey:@"message"]];
              }else{
                  [self handleCriticalError:error operation:operation];
              }

              
          }];
    
    
    return nil;
    
}

- (NSString *) getImageCacheName:(NSURL *) imageURL{
    
    NSString *md5String = [[NSString stringWithFormat:@"%@",imageURL] MD5String];
    NSString *fileName = [NSString stringWithFormat:@"%@%@",@"cachedimage-",md5String];
 return fileName;
}

- (void) imageFromURL:(NSURL*) imageURL
           completion:(CSImageDownloadBlock) imageRequestBlock{
    
    if(imageURL == nil)
        return;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    AFImageRequestOperation *operation;
    
    NSDictionary *headers = self.defaultHeaders;
    if(headers != nil){
        for(NSString *key in headers) {
            [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }        
    }
    
    if([_downloadingImageURL indexOfObject:[imageURL absoluteString]] != NSNotFound){
        return;
    }
    
    [_downloadingImageURL addObject:[imageURL absoluteString]];
    
    operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                     imageProcessingBlock:nil
                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                          
                          [_downloadingImageURL removeObject:[imageURL absoluteString]];

                          NSString *documentsDirectory = nil;
                          NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                          documentsDirectory = [paths objectAtIndex:0];
                          NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory,[self getImageCacheName:imageURL]];
                          
                          NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                          [imageData writeToFile:pathString atomically:YES];
                          
                          imageRequestBlock(imageURL,image);
                          
                          
                      } 
                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                          NSLog(@"%@", [error localizedDescription]);
                      }];
    
    [operation start];
    
}

- (UIImage *) imageWithUrl:(NSURL *) imageURL{
    
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@",documentsDirectory, [self getImageCacheName:imageURL]];

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pathString];
    
    if(fileExists){
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:pathString];
        
        if(data == nil)
            return nil;
        
        UIImage *ready = [[UIImage alloc] initWithData:data];
        return ready;
        
    }else{
        return nil;
    }
    
}

- (void) fileFromURL:(NSURL*) fileURL
          completion:(CSFileDownloadBlock) fileRequestBlock{
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    
    NSDictionary *headers = self.defaultHeaders;
    for(NSString *key in headers) {
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    [AFHTTPRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"audio/x-wav",@"audio/3gp",@"video/quicktime",@"video/mp4",nil]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

            fileRequestBlock(fileURL,operation.responseData);

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            fileRequestBlock(fileURL,nil);
        }
    ];
    
    [operation start];

    
}

- (void) handleLogicError:(NSString *)errStr {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NotificationLogicError object:errStr];
}

- (void) handleCriticalError:(NSError *)err operation:(AFHTTPRequestOperation *)operation{
    
    if([operation.response statusCode] == 404)
        return;
    
    if([operation.response statusCode] == 409)
        return;
    
    if([operation.response statusCode] == 403){
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:NotificationTokenExpiredError object:nil];
        return;
    }
    
    if([operation.response statusCode] == 503){
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:NotificationServiceUnavailable object:operation.responseString];
        return;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NotificationCriticalError object:nil];
    
    
}

@end
