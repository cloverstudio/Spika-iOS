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

#import "UserManager.h"
#import "DatabaseManager.h"

UserManager *_UserManager;

@implementation UserManager

+(UserManager *)defaultManager {
    
	@synchronized([UserManager class]) {
        
		if (!_UserManager)
			_UserManager = [[self alloc] init];
		
		return _UserManager;
	}
	
	return nil;
}

- (void) setLoginedUser:(ModelUser *)user {
    
    if (!user) {
        _loginedUser = nil;
    }
    else {
        _loginedUser = [ModelUser objectWithJson:[ModelUser objectToJson:user]];
    }
}

- (ModelUser *) getLoginedUser {
    
    return _loginedUser;
}

-(void) reloadUserData {
    [self reloadUserDataWithCompletion:nil];
}

-(void) reloadUserDataWithCompletion:(CSResultBlock)block {
    
    ModelUser *user = [self getLoginedUser];
    
    if (user) {
        [[DatabaseManager defaultManager] reloadUser:user success:^(ModelUser *result) {
            [self setLoginedUser:result];
            if (block) block(result);
        } error:^(NSString *errorString) {
            if (block) block(nil);
        }];
    }
}

@end

@implementation UserManager (Helper)

+(void) reloadRecentActivity {
	
	[[DatabaseManager defaultManager] recentActivityForUser:[UserManager defaultManager].getLoginedUser
													success:nil
													  error:nil];
	
}

+(BOOL) messageBelongsToUser:(ModelMessage *)message {
    
    if (message == nil)
        return NO;
    
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    BOOL isUser = [user._id isEqualToString:message.from_user_id];
    
    return isUser;
}

+(BOOL) commentBelongsToUser:(ModelComment *)comment {
    
    if (comment == nil)
        return YES;
    
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    BOOL isUser = [user._id isEqualToString:comment.user_id];
    
    return isUser;
}


+(BOOL) groupBelongsToUser:(ModelGroup *)group {
    
    if (group == nil)
        return NO;
    
    ModelUser *user = [[UserManager defaultManager] getLoginedUser];
    BOOL isUser = [user._id isEqualToString:group.userId];
    
    return isUser;
}

@end