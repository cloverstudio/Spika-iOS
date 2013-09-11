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

#import "NSString+Extensions.h"

//CS_CATEGORY_FIX(NSString_Extensions);

@implementation NSString (Extensions)

///@method isWhiteSpacesString
///checks if the string is consisted of whitespaces only
///@return YES if the string is whitespaces
-(BOOL) isWhiteSpacesString
{
    NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [string isEqualToString:@""];
}

///@method isValidEmail
///TODO: validate email according to http://www.faqs.org/rfcs/rfc822.html
///checks if the string is of form x@y.(2 or 3 letters)
///@return YES

- (BOOL) isValidEmail {

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}
/*-(BOOL) isValidEmail
 {
 NSInteger atLocation = [self rangeOfString:@"@"].location;
 if (atLocation == NSNotFound) return NO;
 ///there can be more than one dot in an email, check for ones after the @ sign
 NSString *dotString = [self substringFromIndex:atLocation];
 NSInteger dotLocation = [dotString rangeOfString:@"."].location;
 if (dotLocation == NSNotFound) return NO;
 
 NSString *domain = [dotString substringFromIndex:dotLocation+1];
 
 NSUInteger domainLength = [domain length];
 return (domainLength == 2 || domainLength == 3);
 }*/

@end
