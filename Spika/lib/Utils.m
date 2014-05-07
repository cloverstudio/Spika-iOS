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

#import <CommonCrypto/CommonDigest.h>
#import "Utils.h"
#import "UserManager.h"
#import "StrManager.h"
#import "NSData+Base64.h"
#import "NSDateFormatter+SharedFormatter.h"


@implementation Utils

+(NSString *) urlencode:(NSString *)baseStr{

    //encoding
    NSString *escapedUrlString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                     NULL,
                                                                                     (CFStringRef)baseStr,
                                                                                     NULL,
                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                     kCFStringEncodingUTF8 );
    
    return escapedUrlString;
}

+(NSString *) urldecode:(NSString *)baseStr{
    
    NSString *decodedUrlString = (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
       NULL,
       (CFStringRef) baseStr,
       CFSTR(""),
       kCFStringEncodingUTF8);
    
    return decodedUrlString;
}


+(int) getDisplayWidth{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    return screenWidth;
}

+(int) getDisplayHeight{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    return screenHeight;
}

+ (NSTimeInterval)getUTCFormateDate{
    NSDate *date = [NSDate date];
    return [date timeIntervalSince1970];
}

+ (double)getUTCFormateDateInDouble{
   
    double unixtimestamp = [Utils getUTCFormateDate];
    return unixtimestamp;
}

+ (long)getUTCFormateDateInLong {
	
	long unixtimestamp = [Utils getUTCFormateDate];
	return unixtimestamp;
}

+(NSString *)generateMessageInfoText:(ModelMessage *)message{
    return [Utils generateMessageInfoTextWithCreated:message.created withName:message.from_user_name withId:message._id];
}

+(NSString *)generateMessageInfoTextWithCreated:(long)created withName:(NSString *)name withId:(NSString *)userId{
    NSTimeInterval _interval=created;
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSString *dateStr = [Utils formatDate:messageDate];
    NSString *userStr = @"";
    
    ModelUser *loginedUser = [[UserManager defaultManager] getLoginedUser];
    if([loginedUser._id isEqualToString:userId]){
        userStr = [StrManager _:@"You"];
    }else{
        userStr = name;
    }
    
    NSString *infoText = [NSString stringWithFormat:[StrManager _:@"Posted %@ by %@"],dateStr,userStr];
    return infoText;
}

+(NSString*) formatDate:(NSDate*) date {
    NSDateFormatter *formatter = [NSDateFormatter sharedFormatter];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:date];
	NSString *dateStr = @"";
	if (timeDiff < 60 * 60) {
        
        if((NSInteger)(timeDiff / 60) <= 1){
            dateStr = [NSString stringWithFormat:[StrManager _:@"%d min ago"], (NSInteger)(timeDiff / 60)];
        }else{
            dateStr = [NSString stringWithFormat:[StrManager _:@"%d mins ago"], (NSInteger)(timeDiff / 60)];
        }
	} else if (timeDiff < 60 * 60 * 24) {
        
        if((NSInteger)timeDiff / (60 * 60) <= 1){
            dateStr = [NSString stringWithFormat:[StrManager _:@"%d hour ago"], (NSInteger)(timeDiff / (60 * 60))];
        }else{
            dateStr = [NSString stringWithFormat:[StrManager _:@"%d hours ago"], (NSInteger)(timeDiff / (60 * 60))];
        }
	} else {
		[formatter setDateFormat:[StrManager _:kDefaultTimeStampFormat]];
		dateStr = [formatter stringFromDate:date];
	}
    return dateStr;
}

+(NSArray *) mergeMessagesForApperaToWall:(NSArray *)newMessages oldMessages:(NSArray *)oldMessages{
    
    NSMutableArray* tmpNewMessages = [NSMutableArray arrayWithArray:newMessages];
    [tmpNewMessages addObjectsFromArray: oldMessages];
    
    return [Utils filterMessagesForApperaToWall:tmpNewMessages];
}

+(NSArray *) filterMessagesForApperaToWall:(NSArray *)messages{
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // erase duplicate
    for(int i = 0 ; i < [messages count]; i++){
        
        BOOL isExist = NO;
        
        ModelMessage *message = [messages objectAtIndex:i];
        
        for(int ii = 0; ii < [result count] ; ii++){
            
            ModelMessage *message2 = [result objectAtIndex:ii];
            
            if([message._id isEqualToString:message2._id]){
                isExist = YES;
                break;
            }

        }
        
        if(!isExist){
            [result addObject:message];
        }else{
            
            
        }
        
    }
    
    // erase not valid messages
    NSMutableArray *removeTarget = [[NSMutableArray alloc] init];

    for(int i = 0; i < [result count] ; i++){
        
        ModelMessage *message = [result objectAtIndex:i];
        
        if(message.valid == NO)
            [removeTarget addObject:message];
        
    }
    
    for(int ii = 0; ii < [removeTarget count] ; ii++){
        [result removeObject:[removeTarget objectAtIndex:ii]];
    }

    NSArray *sortedAry = [result sortedArrayUsingComparator:^NSComparisonResult(ModelMessage *a, ModelMessage *b) {
        return a.modified> b.modified;
    }];
    
    int fetchNum = PagingMessageFetchNum;
    if(fetchNum > sortedAry.count)
        fetchNum = sortedAry.count;
    
    return sortedAry;
    
    //return [sortedAry subarrayWithRange:NSMakeRange(0, fetchNum)];
}

+(NSDictionary *) generateAttachmentJsonForImage:(UIImage *)image fileName:(NSString *)fileName{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:@"image/jpeg" forKey:@"content_type"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *encodedString = [imageData base64EncodedString];
    [dic setObject:encodedString forKey:@"data"];
    
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
    
    [dic2 setObject:dic forKey:fileName];
    
    return dic2;
}

+(NSDictionary *) generateAttachmentJsonForVideo:(NSURL *)videoPathURL fileName:(NSString *)fileName{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
    NSData *videoData = [NSData dataWithContentsOfURL:videoPathURL];
    NSString *encodedString = [videoData base64EncodedString];

    [dic setObject:[NSString stringWithFormat:@"%d",[videoData length]] forKey:@"Content-Length"];
    [dic setObject:@"video/quicktime" forKey:@"Content-Type"];
    [dic setObject:encodedString forKey:@"data"];
    
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
    
    [dic2 setObject:dic forKey:fileName];
    
    return dic2;
}

+ (NSDictionary *)generateAttachmentJsonForVoice:(NSURL *)voicePathURL fileName:(NSString *)fileName {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    NSData *voiceData = [NSData dataWithContentsOfFile:voicePathURL.path];
    NSString *encodedString = [voiceData base64EncodedString];
    
    [dic setObject:[NSString stringWithFormat:@"%d",[voiceData length]] forKey:@"length"];
    [dic setObject:@"audio/wav" forKey:@"content_type"];
    [dic setObject:encodedString forKey:@"data"];
    
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
    
    [dic2 setObject:dic forKey:fileName];
    
    return dic2;
    
}


+(NSString *)generateAttachmentURL:(NSDictionary *)data{
    
    NSString *fileName = @"";
    
    for(NSString *key in [data objectForKey:@"_attachments"]){
        fileName = [NSString stringWithString:key];
    }
    
    return [NSString stringWithFormat:@"%@%@/%@",DatabaseURL,[data objectForKey:@"_id"],fileName];
    
}

+(NSString *)generateEmoticonURL:(NSDictionary *)data{
    
    NSString *fileName = @"";
    
    for(NSString *key in [data objectForKey:@"_attachments"]){
        fileName = [NSString stringWithString:key];
    }
    
    return [NSString stringWithFormat:@"%@/Emoticon/%@",DatabaseURL,[data objectForKey:@"_id"]];
    
}

+(CGSize) fitSize:(CGSize) originalSize toSize:(CGSize) toSize{
    
    float scale = (float)toSize.width / (float)originalSize.width;
    
    return CGSizeMake(
        originalSize.width * scale,
        originalSize.height * scale
    );
    
}

+ (NSString *)convertOnlineStatusKeyForDB:(NSString *) origStatus{
    return [origStatus lowercaseString];
}

+ (NSString *)convertOnlineStatusKeyForDisplay:(NSString *) origStatus{
    return [origStatus capitalizedString];
}

+(NSString *)getKeyForLocalizedString:(NSString *)localizedString{
    
    NSArray* languageList = [NSLocale preferredLanguages];
	NSString *lang = [languageList objectAtIndex:0];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Localizable"
                                                     ofType:@"strings"
                                                inDirectory:nil
                                            forLocalization:lang];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSArray *temp = [dict allKeysForObject:localizedString];
    
    if(temp.count > 0){
        NSString *key = [temp objectAtIndex:0];
        return key;
    }
    
    return nil;
    
}

+(int) getKeyboardHeight{
    return 216;
}

+(int) heightByText:(NSString *)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size{
   
    if(IOS_NEWER_OR_EQUAL_TO_7){
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              nil];
        
        CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
        
        return frame.size.height;
    }
    else{
        return [text sizeForBoundingSize:size font:font].height;
    }
    
}

+(NSString *)MD5:(NSString*)keyString
{
    unsigned char hash[16];
    CC_MD5([keyString cStringUsingEncoding:NSUTF8StringEncoding], (int)strlen([keyString cStringUsingEncoding:NSUTF8StringEncoding]), hash);
    NSString *hashString = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",hash[0],hash[1],hash[2],hash[3],hash[4],hash[5],hash[6],hash[7],hash[8],hash[9],hash[10],hash[11],hash[12],hash[13],hash[14],hash[15]];
    return hashString;
}


@end
