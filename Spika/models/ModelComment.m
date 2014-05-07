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

#import "ModelComment.h"

@implementation ModelComment

+ (NSDictionary *) objectToDictionary:(ModelComment *)comment {
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    if(comment == nil)
        return nil;
    
    if(comment._id != nil)
        [tmpDic setObject:comment._id forKey:@"_id"];
    
    if(comment._rev!= nil)
        [tmpDic setObject:comment._rev forKey:@"_rev"];
    
    [tmpDic setObject:comment.comment forKey:@"comment"];
    [tmpDic setObject:comment.user_id forKey:@"user_id"];
    [tmpDic setObject:comment.user_name forKey:@"user_name"];
    [tmpDic setObject:comment.message_id forKey:@"message_id"];
    [tmpDic setObject:@(comment.created) forKey:@"created"];
    [tmpDic setObject:comment.avatarThumbFileId forKey:@"avatar_thumb_file_id"];
        
    return tmpDic;
}

+(NSString *) objectToJson:(ModelComment *)comment{
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[ModelComment objectToDictionary:comment]
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}

+ (id) objectWithJson:(NSString *)strJSON{
    
    NSError *error = nil;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:&error];
    
    if (error)
        CSLog(@"%@", [error description]);
    
    return [ModelComment objectWithDictionary:jsonDict];
    
}

+ (id) objectWithDictionary:(NSDictionary *)dic{
    
    ModelComment *comment = [[ModelComment alloc] init];
    
    if([dic objectForKey:@"_id"] != nil && ![[dic objectForKey:@"_id"] isEqual:[NSNull null]]){
        comment._id = [dic objectForKey:@"_id"];
    }else{
        comment._id = @"";
    }
    
    if([dic objectForKey:@"_rev"] != nil){
        comment._rev = [dic objectForKey:@"_rev"];
    }else{
        comment._rev = @"";
    }
    
    if([dic objectForKey:@"user_name"] != nil){
        comment.user_name = [dic objectForKey:@"user_name"];
    }else{
        comment.user_name = @"";
    }
    
    if([dic objectForKey:@"user_id"] != nil){
        comment.user_id = [dic objectForKey:@"user_id"];
    }else{
        comment.user_id = @"";
    }
    
    
    if([dic objectForKey:@"created"] != nil && ![[dic objectForKey:@"created"] isEqual:@""]){
        comment.created = [[dic objectForKey:@"created"] longValue];
    }else{
        comment.created = 0;
    }
    
    
    if([dic objectForKey:@"comment"] != nil){
        comment.comment = [dic objectForKey:@"comment"];
    }else{
        comment.comment = @"";
    }
    
    if([dic objectForKey:@"avatar_thumb_file_id"] != nil) {
        comment.avatarThumbUrl =  [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_thumb_file_id"]];
        comment.avatarThumbFileId = [dic objectForKey:@"avatar_thumb_file_id"];
    }else{
        comment.avatarThumbFileId = @"";
        comment.avatarThumbUrl = @"";
    }

    
    return comment;
}

-(id) copy {
	return [ModelComment objectWithDictionary:[ModelComment objectToDictionary:self]];
}

@end
