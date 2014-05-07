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

#import "ModelGroupCategory.h"
#import "UserManager.h"
#import "NSDictionary+KeyPath.h"
#import "DatabaseManager.h"

@implementation ModelGroupCategory


+(NSDictionary *) toDic:(ModelGroupCategory *)groupCategory{
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    [tmpDic setObject:groupCategory._id forKey:@"_id"];
    [tmpDic setObject:groupCategory._rev forKey:@"_rev"];
    [tmpDic setObject:groupCategory.title forKey:@"title"];
    
    return tmpDic;
}

+(NSString *) toJSON:(ModelGroupCategory *)groupCategory{
    NSDictionary *tmpDic = [ModelGroupCategory toDic:groupCategory];
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:tmpDic
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}

+(ModelGroupCategory *) jsonToObj:(NSString *)strJSON{
    
    NSMutableDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:nil];
    return [ModelGroupCategory dicToObj:tmpDic];
    
}

+(ModelGroupCategory *) dicToObj:(NSDictionary *)dic{
    
    ModelGroupCategory *groupCategory = [[ModelGroupCategory alloc] init];
    
    if([dic objectForKey:@"_id"] != nil){
        groupCategory._id = [dic objectForKey:@"_id"];
    }
    else{
        groupCategory._id = @"";
    }
    
    if([dic objectForKey:@"_rev"] != nil){
        groupCategory._rev = [dic objectForKey:@"_rev"];
    }
    else{
        groupCategory._rev = @"";
    }

    if([dic objectForKey:@"title"] != nil){
        groupCategory.title = [dic objectForKey:@"title"];
    }
    else{
        groupCategory.title = @"";
    }
    
    if([dic objectForKey:@"avatar_file_id"] != nil){
        NSString *str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar_file_id"]];
        if(str.length > 0){
            groupCategory.imageUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_file_id"]];
        }
    }

    
    return groupCategory;
    
}


@end
