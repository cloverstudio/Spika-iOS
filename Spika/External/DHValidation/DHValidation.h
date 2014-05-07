//
//  DHValidation.h
//  ceol
//
//  Created by Ben McRedmond on 24/05/2009.
//  Copyright 2009 Ben McRedmond. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DHValidateAlpha;
extern NSString * const DHValidateAlphaSpaces;
extern NSString * const DHValidateAlphaNumeric;
extern NSString * const DHValidateAlphaNumericDash;
extern NSString * const DHValidateName;
extern NSString * const DHValidateNotEmpty;
extern NSString * const DHValidateEmail;
extern NSString * const DHValidateMatchesConfirmation;
extern NSString * const DHValidateMinimumLength;
extern NSString * const DHValidateCustomAsync;
extern NSString * const DHValidateCustom;
extern NSString * const DHCancelAsync;

@interface DHValidation : NSObject {
    NSMutableDictionary *errorTable;
    NSMutableDictionary *errorStrings;
    
    NSMutableDictionary *asyncErrorFields;
    BOOL asyncInProgress;
    
    NSString *currentTag;
    
    id delegate;
    
    // Variables for this validation only
    NSMutableArray *tempErrors;
}

- (void) validateRule: (NSString * const) rule candidate: (id) candidate tag: (NSString *) tag;
- (void) validateRuleWithParamater: (NSString * const) rule candidate: (id) candidate tag: (NSString *) tag parameter: (id) parameter;
- (void) modifyErrorTable: (NSString *) tag method: (NSString * const) method isValid: (BOOL) isValid;
- (int) errorCount;
- (int) errorCountForTag: (NSString *) tag;
- (void) reset;


// Basic Validators
- (BOOL) validateAlpha: (NSString *) candidate;
- (BOOL) validateAlphaSpaces: (NSString *) candidate;
- (BOOL) validateAlphanumeric: (NSString *) candidate;
- (BOOL) validateAlphanumericDash: (NSString *) candidate;
- (BOOL) validateStringInCharacterSet: (NSString *) string characterSet: (NSMutableCharacterSet *) characterSet;
- (BOOL) validateNotEmpty: (NSString *) candidate;
- (BOOL) validateEmail: (NSString *) candidate;

// Complex validators (requires second parameter)
- (BOOL) validateMatchesConfirmation: (NSString *) candidate parameter: (NSString *) confirmation;
- (BOOL) validateMinimumLength: (NSString *) candidate parameter: (int) length;

@end