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

#import "NSDictionary+KeyPath.h"

@implementation NSObject (KeyPath)

-(id) objectForKeyPath:(NSString *)keyPath {
	return nil;
}

@end

@implementation NSDictionary (KeyPath)

-(id) objectForKeyPath:(NSString *)keyPath {
    
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    
    id node = self;
    for (NSString *key in keys) {

        node = [node objectForKey:key];
        
        if ([node isKindOfClass:[NSDictionary class]]) {
            
            continue;
        } else if ([node isEqual:[NSNull null]]) {
            
            node = nil;
            break;
        } else if (node == nil) {
            
            break;
        } else {

            break;
        }
        
    }
    
    return node;
}

@end

@implementation NSMutableDictionary (KeyPath)

-(void) setObject:(id)object forKeyPath:(NSString *)keyPath {
    
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    
    id node = self;
    for (int i = 0; i < keys.count; i++) {
    
        NSString *key = [keys objectAtIndex:i];
        NSString *nextKey = i + 1 < keys.count ? [keys objectAtIndex:i+1] : nil;
        
        BOOL isLast = !nextKey ? YES : NO;
        
        id nextNode = [node objectForKey:key];
        if ([nextNode isEqual:[NSNull null]] || nextNode == nil) {
            [node setObject:isLast ? object : [NSMutableDictionary new] forKey:key];
            nextNode = [node objectForKey:key];
        }
        
        node = nextNode;
    }
    
}

@end