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

#import "NSURLConnection+SendAsync.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0

typedef void (^URLConnectionCompletionHandler)(NSURLResponse *response, NSData *data, NSError *error);

@interface URLConnectionDelegate : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, copy) URLConnectionCompletionHandler handler;

@end 

@implementation URLConnectionDelegate 

@synthesize response;
@synthesize data;
@synthesize queue;
@synthesize handler;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)theResponse {
    self.response = theResponse;
    [data setLength:0]; // reset data
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    [data appendData:theData]; // append incoming data
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.data = nil;
    if (handler) { [queue addOperationWithBlock:^{ handler(response, nil, error); }]; }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // TODO: Are we passing the arguments to the block correctly? Should we copy them?
    if (handler) { [queue addOperationWithBlock:^{ handler(response, data, nil); }]; }
}

@end

#import <objc/runtime.h>
#import "NSURLConnection+SendAsync.h"

// Dynamically add @property (nonatomic,readonly) UIViewController *presentingViewController.
void sendAsynchronousRequest4(id self, SEL _cmd, NSURLRequest *request, NSOperationQueue *queue,
                              URLConnectionCompletionHandler handler);

void sendAsynchronousRequest4(id self, SEL _cmd, NSURLRequest *request, NSOperationQueue *queue,
                              URLConnectionCompletionHandler handler) {
    
    URLConnectionDelegate *connectionDelegate = [[URLConnectionDelegate alloc] init];
    connectionDelegate.data = [NSMutableData data];
    connectionDelegate.queue = queue;
    connectionDelegate.handler = handler;

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request
                                                                delegate:connectionDelegate];
    NSAssert(connection, nil);
}

@implementation NSURLConnection (SendAsync)

+ (void)load {
    SEL sendAsyncSelector = @selector(sendAsynchronousRequest:queue:completionHandler:);
    if (![NSURLConnection instancesRespondToSelector:sendAsyncSelector]) {
        class_addMethod(object_getClass([self class]),
                        sendAsyncSelector, (IMP)sendAsynchronousRequest4, "v@:@@@");
    }
}

@end

#endif
