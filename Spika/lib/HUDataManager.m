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

#import "HUDataManager.h"
#import "DHValidation.h"

@implementation HUDataManager

+(HUDataManager *) defaultManager
{
	@synchronized(self)
	{
        static HUDataManager *_instance = nil;
        
		if (!_instance)
			_instance = [[self alloc] init];
		
		return _instance;
	}
	
	return nil;
}

#pragma mark - Initialization

-(id)init
{
    if (self = [super init])
	{
		
    }
    
    return self;
}

-(BOOL)isPasswordOkay:(NSString *)password
{
	if (password == nil)
		return NO;
	
    DHValidation *validator = [[DHValidation alloc] init];
    
    BOOL alphanumericTest = [validator validateAlphanumeric:password];
    
	NSUInteger passLength = password.length;
	
	return alphanumericTest && passLength >= 6;
}

-(BOOL)isNameOkay:(NSString *)name
{
	if (name == nil)
		return NO;
	
	return name.length > 1;
}

-(BOOL)isEmailOkay:(NSString *)email{
    DHValidation *validator = [[DHValidation alloc] init];
    return [validator validateEmail:email];
}

@end
