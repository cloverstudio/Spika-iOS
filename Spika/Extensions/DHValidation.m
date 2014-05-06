//
//  DHValidation.m
//  ceol
//
//  Created by Ben McRedmond on 24/05/2009.
//  Copyright 2009 Ben McRedmond. All rights reserved.
//

#import <stdarg.h>
#import "DHValidation.h"

// Basic Validators
NSString * const DHValidateAlpha = @"validateAlpha:";
NSString * const DHValidateAlphaSpaces = @"validateAlphaSpaces:";
NSString * const DHValidateAlphaNumeric = @"validateAlphanumeric:";
NSString * const DHValidateAlphaNumericDash = @"validateAlphanumericDash:";
NSString * const DHValidateName = @"validateName:";
NSString * const DHValidateNotEmpty = @"validateNotEmpty:";
NSString * const DHValidateEmail = @"validateEmail:";

// Validations that take second parameters
NSString * const DHValidateMatchesConfirmation = @"validateMatchesConfirmation:";
NSString * const DHValidateMinimumLength = @"validateMinimumLength:";
NSString * const DHValidateCustomAsync = @"asyncValidationMethod:";
NSString * const DHValidateCustom = @"customValidationMethod:";
NSString * const DHCancelAsync = @"cancelAsync:";

@implementation DHValidation

- (id) init {        
    return [self initWithErrorMessages:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Letters only",                        DHValidateAlpha,
                        @"Letters and Spaces Only",             DHValidateAlphaSpaces,
                        @"Letters and Numbers Only",            DHValidateAlphaNumeric,
                        @"Letters, Numbers and Dashes Only",    DHValidateAlphaNumericDash,
                        @"Letters only",                        DHValidateName,
                        @"Can't be empty",                      DHValidateNotEmpty,
                        @"Invalid Email Address",               DHValidateEmail, 
                        @"Does not match confirmation",         DHValidateMatchesConfirmation, 
                        @"",                                    DHValidateCustomAsync, 
                        @"",                                    DHValidateCustom, 
                        @"",                                    DHCancelAsync, nil]];
}

- (id) initWithErrorMessages: (NSDictionary *) errors {
    self = [super init];
    
    if(self)
    {
        errorTable = [[NSMutableDictionary alloc] initWithCapacity:7];
        asyncErrorFields = [[NSMutableDictionary alloc] initWithCapacity:1];
        errorStrings = [errors mutableCopy];
    }
    
    return self;
}

- (void) validateRule: (NSString * const) rule candidate: (id) candidate tag: (NSString *) tag  {
    [self validateRuleWithParamater:rule candidate: candidate tag:tag parameter:nil];
}

- (void) validateRuleWithParamater: (NSString * const) rule candidate: (id) candidate tag: (NSString *) tag parameter: (id) parameter {
    SEL selector = NSSelectorFromString([rule stringByAppendingString:@"parameter:"]);
    BOOL isValid;
    
    // Check if this method takes a paramter
    if([self respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        isValid = [self performSelector:selector withObject:candidate withObject:parameter];
    }
    else
    {
        selector = NSSelectorFromString(rule);
        isValid = [self performSelector:selector withObject:candidate];
#pragma clang diagnostic pop
    }
    
    [self modifyErrorTable:tag method:rule isValid:isValid];
    if(!isValid) [tempErrors addObject:[errorStrings objectForKey:rule]];
}

- (void) modifyErrorTable: (NSString *) tag method: (NSString * const) method isValid: (BOOL) isValid {
    // Check whether there's an entry already in the error table
    if([errorTable objectForKey:tag] == nil)
        [errorTable setObject:[NSMutableDictionary dictionaryWithCapacity:1] forKey:tag];
    
    // Update the 'table'
    [[errorTable objectForKey:tag] setObject:[NSNumber numberWithBool:isValid] forKey:method];
}

- (int) errorCount {
    int errors = 0;
    
    NSEnumerator *enumerator = [errorTable objectEnumerator];
    NSEnumerator *innerEnumerator;
    
    // The only objects in our table should be mutable dictionaries
    NSMutableDictionary *value;
    NSNumber *innerValue;    

    while((value = [enumerator nextObject]))
    {
        innerEnumerator = [value objectEnumerator];
        while((innerValue = [innerEnumerator nextObject]))
        {
            if(![innerValue boolValue]) ++errors;
        }
    }
    
    return errors;
}

- (int) errorCountForTag: (NSString *) tag {
    int errors = 0;
    
    NSEnumerator *enumerator = [[errorTable objectForKey:tag] objectEnumerator];
    NSNumber *value;
    
    while((value = [enumerator nextObject]))
    {
        if(![value boolValue]) ++errors;
    }
    
    return errors;
}

- (void) reset {
    [errorTable removeAllObjects];
}

// ======================
// = Validation Methods =
// ======================
- (BOOL) validateAlpha: (NSString *) candidate {
    return [self validateStringInCharacterSet:candidate characterSet:[NSCharacterSet letterCharacterSet]];
}

- (BOOL) validateAlphaSpaces: (NSString *) candidate {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet letterCharacterSet];
    [characterSet addCharactersInString:@" "];
    return [self validateStringInCharacterSet:candidate characterSet:characterSet];
}

- (BOOL) validateAlphanumeric: (NSString *) candidate {
    return [self validateStringInCharacterSet:candidate characterSet:[NSCharacterSet alphanumericCharacterSet]];
}

- (BOOL) validateAlphanumericDash: (NSString *) candidate {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"-_."];
    return [self validateStringInCharacterSet:candidate characterSet:characterSet];
}

- (BOOL) validateName: (NSString *) candidate {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"'- "];
    return [self validateStringInCharacterSet:candidate characterSet:characterSet];
}

- (BOOL) validateStringInCharacterSet: (NSString *) string characterSet: (NSMutableCharacterSet *) characterSet {
    // Since we invert the character set if it is == NSNotFound then it is in the character set.
    return ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) ? NO : YES;
}

- (BOOL) validateNotEmpty: (NSString *) candidate {
    return ([candidate length] == 0) ? NO : YES;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 

    return [emailTest evaluateWithObject:candidate];
}

- (BOOL) validateMatchesConfirmation: (NSString *) candidate parameter: (NSString *) confirmation {
    return [candidate isEqualToString:confirmation];
}

- (BOOL) validateMinimumLength: (NSString *) candidate parameter: (int) length {
    [errorStrings setObject:[NSString stringWithFormat:@"Not longer than %d characters", length] forKey:DHValidateMinimumLength];
    return ([candidate length] >= length) ? YES : NO;
}

@end
