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

#import "ModelMessage.h"

#import "Utils.h"

@implementation ModelMessage

+(NSDictionary *) toDic:(ModelMessage *)message{
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    if(message.comments == nil)
        message.comments = [[NSMutableArray alloc] init];
    
    [tmpDic setObject:message._id forKey:@"_id"];
    [tmpDic setObject:message._rev forKey:@"_rev"];
    [tmpDic setObject:message.type forKey:@"type"];
    [tmpDic setObject:message.message_type forKey:@"message_type"];
    [tmpDic setObject:message.message_target_type forKey:@"message_target_type"];
    [tmpDic setObject:message.from_user_id forKey:@"from_user_id"];
    [tmpDic setObject:message.from_user_name forKey:@"from_user_name"];
    [tmpDic setObject:message.to_user_id forKey:@"to_user_id"];
    [tmpDic setObject:message.to_user_name forKey:@"to_user_name"];
    [tmpDic setObject:message.group_id forKey:@"to_group_id"];
    [tmpDic setObject:message.group_name forKey:@"to_group_name"];
    [tmpDic setObject:message.pictureFileId forKey:@"picture_file_id"];
    [tmpDic setObject:message.pictureThumbFileId forKey:@"picture_thumb_file_id"];
    [tmpDic setObject:message.messageUrl forKey:@"message_url"];
    [tmpDic setObject:[NSNumber numberWithLong:message.created] forKey:@"created"];
    [tmpDic setObject:[NSNumber numberWithLong:message.modified] forKey:@"modified"];
    [tmpDic setObject:[NSNumber numberWithLong:message.readAt] forKey:@"read_at"];
    [tmpDic setObject:[NSNumber numberWithBool:message.valid] forKey:@"valid"];
    //[tmpDic setObject:message.attachmentsOrig forKey:@"_attachments"];
    [tmpDic setObject:message.comments forKey:@"comments"];
    [tmpDic setObject:message.emoticonImageURL forKey:@"emoticon_image_url"];
    [tmpDic setObject:[NSNumber numberWithDouble:message.longitude] forKey:@"longitude"];
    [tmpDic setObject:[NSNumber numberWithDouble:message.latitude] forKey:@"latitude"];
    [tmpDic setObject:message.avatarThumbFileId forKey:@"avatar_thumb_file_id"];
    [tmpDic setObject:[NSNumber numberWithInt:message.deleteAt] forKey:@"delete_at"];
    [tmpDic setObject:[NSNumber numberWithInt:message.deleteType] forKey:@"delete_type"];
    [tmpDic setObject:[NSNumber numberWithInt:message.comment_count] forKey:@"comment_count"];
    
    return tmpDic;
}

+ (NSString *) toJSON:(ModelMessage *)message {
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[ModelMessage toDic:message]
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}

+(ModelMessage *) jsonToObj:(NSString *)strJSON {
    
    NSError *error = nil;
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:&error];
    
    if (error) 
        CSLog(@"%@", [error description]);
    
    return [ModelMessage dicToObj:jsonDict];
    
}

+(ModelMessage *) dicToObj:(NSDictionary *)dic{
    
    ModelMessage *message = [[ModelMessage alloc] init];

    if([dic objectForKey:@"_id"] != nil){
        message._id = [dic objectForKey:@"_id"];
    }else{
        message._id = @"";
    }
    
    if([dic objectForKey:@"_rev"] != nil){
        message._rev = [dic objectForKey:@"_rev"];
    }else{
        message._rev = @"";
    }
    
    if([dic objectForKey:@"type"] != nil){
        message.type = [dic objectForKey:@"type"];
    }else{
        message.type = @"";
    }
    
    if([dic objectForKey:@"message_type"] != nil){
        message.message_type = [dic objectForKey:@"message_type"];
    }else{
        message.message_type = @"";
    }
    
    if([dic objectForKey:@"message_target_type"] != nil){
        message.message_target_type = [dic objectForKey:@"message_target_type"];
    }else{
        message.message_target_type = @"";
    }
    
    if([dic objectForKey:@"from_user_id"] != nil){
        message.from_user_id = [dic objectForKey:@"from_user_id"];
    }else{
        message.from_user_id = @"";
    }
    
    if([dic objectForKey:@"from_user_name"] != nil){
        message.from_user_name = [dic objectForKey:@"from_user_name"];
    }else{
        message.from_user_name = @"";
    }
    
    if([dic objectForKey:@"to_user_id"] != nil){
        message.to_user_id = [dic objectForKey:@"to_user_id"];
    }else{
        message.to_user_id = @"";
    }
    
    if([dic objectForKey:@"to_user_name"] != nil){
        message.to_user_name = [dic objectForKey:@"to_user_name"];
    }else{
        message.to_user_name = @"";
    }
    
    if([dic objectForKey:@"to_group_id"] != nil){
        message.group_id = [dic objectForKey:@"to_group_id"];
    }else{
        message.group_id = @"";
    }
    
    if([dic objectForKey:@"to_group_name"] != nil){
        message.group_name = [dic objectForKey:@"to_group_name"];
    }else{
        message.group_name = @"";
    }
    
    if([dic objectForKey:@"created"] != nil){
        message.created = [[dic objectForKey:@"created"] longValue];
    }else{
        message.created = 0;
    }
    
    if([dic objectForKey:@"modified"] != nil){
        message.modified = [[dic objectForKey:@"modified"] longValue];
    }else{
        message.modified = 0;
    }
    
    if([dic objectForKey:@"read_at"] != nil){
        message.readAt = [[dic objectForKey:@"read_at"] longValue];
    }else{
        message.readAt = 0;
    }
    
    if([dic objectForKey:@"body"] != nil){
        message.body = [dic objectForKey:@"body"];
    }else{
        message.body = @"";
    }
    
    if([dic objectForKey:@"message_url"] != nil){
        message.messageUrl = [dic objectForKey:@"message_url"];
    }else{
        message.messageUrl = @"";
    }
    
    if([message.body isKindOfClass:[NSNull class]]){
        message.body = @"";
    }
    
    if([message.messageUrl isKindOfClass:[NSNull class]]){
        message.messageUrl = @"";
    }
    
    if([dic objectForKey:@"picture_file_id"] != nil){
        message.imageUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"picture_file_id"]];
        message.pictureFileId = [dic objectForKey:@"picture_file_id"];
    }else{
        message.pictureFileId = @"";
    }

    
    if([dic objectForKey:@"picture_thumb_file_id"] != nil){
        message.imageThumbUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"picture_thumb_file_id"]];
        message.pictureThumbFileId = [dic objectForKey:@"picture_thumb_file_id"];
    }else{
        message.pictureThumbFileId = @"";
    }
    
    if([dic objectForKey:@"voice_file_id"] != nil){
        message.voiceUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"voice_file_id"]];
    }else{
        message.voiceUrl = @"";
    }
    
    if([dic objectForKey:@"video_file_id"] != nil){
        message.videoUrl = [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"video_file_id"]];
    }else{
        message.videoUrl = @"";
    }
    
    
    /*
    if([dic objectForKey:@"_attachments"] != nil){
        
        for(NSString *key in [dic objectForKey:@"_attachments"]){
            
            if([key isEqualToString:MessageTypeImageFileName]){
                
                if([[[[dic objectForKey:@"_attachments"] objectForKey:key] objectForKey:@"content_type"] isEqualToString:@"image/jpeg"]){
                    
                    message.imageUrl = [NSString stringWithFormat:@"%@%@/%@", DatabaseURL,message._id,MessageTypeImageFileName];
                }
            }
            
            if([key isEqualToString:MessageTypeVideoFileName]){
                message.videoUrl = [NSString stringWithFormat:@"%@%@/%@", DatabaseURL,message._id,MessageTypeVideoFileName];
            }
            
            if ([key isEqualToString:MessageTypeVoiceFileName]) {
                message.voiceUrl = [NSString stringWithFormat:@"%@%@/%@", DatabaseURL,message._id,MessageTypeVoiceFileName];
            }
            
        }
        
        message.attachmentsOrig = [dic objectForKey:@"_attachments"];

    }
     */
    
    if([dic objectForKey:@"valid"] != nil){
        message.valid = [[dic objectForKey:@"valid"] boolValue];
    }else{
        message.valid = NO;
    }

    if([dic objectForKey:@"comments"] != nil){
        message.comments = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"comments"]];
    }else{
        message.comments = [[NSMutableArray alloc] init];
    }

    if([dic objectForKey:@"emoticon_image_url"] != nil){
        message.emoticonImageURL = [dic objectForKey:@"emoticon_image_url"];
    }else{
        message.emoticonImageURL = @"";
    }
    
    if([dic objectForKey:@"latitude"] != nil){
        message.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    }else{
        message.latitude = 0;
    }
    
    if([dic objectForKey:@"longitude"] != nil){
        message.longitude = [[dic objectForKey:@"longitude"] doubleValue];
    }else{
        message.longitude = 0;
    }
    
    if([dic objectForKey:@"avatar_thumb_file_id"] != nil) {
        message.avatarThumbUrl =  [NSString stringWithFormat:@"%@%@?file=%@",HttpRootURL,FileDownloader,[dic objectForKey:@"avatar_thumb_file_id"]];
        message.avatarThumbFileId = [dic objectForKey:@"avatar_thumb_file_id"];
    }else{
        message.avatarThumbFileId = @"";
        message.avatarThumbUrl = @"";
    }
    
    if([dic objectForKey:@"delete_at"] != nil){
        message.deleteAt = [[dic objectForKey:@"delete_at"] intValue];
    }else{
        message.deleteAt = 0;
    }
    
    if([dic objectForKey:@"delete_type"] != nil){
        message.deleteType = [[dic objectForKey:@"delete_type"] intValue];
    }else{
        message.deleteType = 0;
    }

    if ([dic objectForKey:@"comment_count"] != nil) {
        message.comment_count = [[dic objectForKey:@"comment_count"] intValue];
    }else{
        message.comment_count = 0;
    }
    
    return message;
    
}

-(void) addComment:(ModelUser *)fromUser comment:(NSString *)comment{
    
    NSMutableDictionary *newComments = [[NSMutableDictionary alloc] init];
    
    [newComments setObject:fromUser._id forKey:@"user_id"];
    [newComments setObject:fromUser.name forKey:@"user_name"];
    [newComments setObject:comment forKey:@"comment"];
    [newComments setObject:[NSNumber numberWithLong:[Utils getUTCFormateDateInLong]] forKey:@"created"];
    
    [_comments addObject:newComments];

}

+(ModelMessage *) messageWithCommentDictionary:(ModelComment *)comment {
    
    ModelMessage *message = [ModelMessage new];
    message.from_user_name = comment.user_name;
    message.from_user_id = comment.user_id;
    message.body = comment.comment;
    message.created = comment.created;
    message.message_type = MessageTypeText;
    message.avatarThumbUrl = comment.avatarThumbUrl;
    message.avatarThumbFileId = comment.avatarThumbFileId;
    
    return message;
}

-(Class) tableViewCellClass {
    
    Class aClass = nil;
        
    if([self.message_type isEqualToString:MessageTypeImage]){
        aClass = NSClassFromString(@"MessageTypeImageCell");
            
    }else if([self.message_type isEqualToString:MessageTypeEmoticon]){
        aClass = NSClassFromString(@"MessageTypeEmoticonCell");
        
    }else if([self.message_type isEqualToString:MessageTypeVideo]){
        aClass = NSClassFromString(@"MessageTypeVideoCell");
        
    }else if([self.message_type isEqualToString:MessageTypeLocation]){
        aClass = NSClassFromString(@"MessageTypeLocationCell");
        
    }else if([self.message_type isEqualToString:MessageTypeVoice]){
        aClass = NSClassFromString(@"MessageTypeVoiceCell");
        
    }else if([self.message_type isEqualToString:MessageTypeNews]){
        aClass = NSClassFromString(@"MessageTypeNewsCell");
        
    }else{
        aClass = NSClassFromString(@"MessageTypeTextCell");
    }
        
    NSAssert(aClass != nil, @"Message contains invalid message type OR class name contains a typo");
        
    return aClass;
    
}

#pragma mark - NSCopying

-(ModelMessage *) copy {
    
    ModelMessage *copy = [[ModelMessage alloc] init];
    copy._id = self._id.copy;
    copy._rev = self._rev.copy;
    copy.type = self.type.copy;
    copy.body = self.body.copy;
    copy.messageUrl = self.messageUrl.copy;
    copy.message_type = self.message_type.copy;
    copy.message_target_type = self.message_target_type.copy;
    copy.from_user_id = self.from_user_id.copy;
    copy.from_user_name = self.from_user_name.copy;
    copy.to_user_id = self.to_user_id.copy;
    copy.to_user_name = self.to_user_name.copy;
    copy.group_id = self.group_id.copy;
    copy.group_name = self.group_name.copy;
    copy.created = self.created;
    copy.modified = self.modified;
    copy.valid = self.valid;
    copy.attachmentsOrig = self.attachmentsOrig.copy;
    copy.comments = self.comments.mutableCopy;
    copy.emoticonImageURL = self.comments.copy;
    copy.longitude = self.longitude;
    copy.latitude = self.latitude;
    copy.readAt = self.readAt;
    copy.pictureFileId = self.pictureFileId.copy;
    copy.pictureThumbFileId = self.pictureThumbFileId.copy;
    copy.avatarThumbFileId = self.avatarThumbFileId.copy;
    copy.avatarThumbUrl = self.avatarThumbUrl.copy;
    copy.deleteAt = self.deleteAt;
    copy.deleteType = self.deleteType;
    copy.comment_count = self.comment_count;
    
    return copy;
}

@end
