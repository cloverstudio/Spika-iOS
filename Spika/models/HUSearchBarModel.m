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

#import "HUSearchBarModel.h"
#import "NSDictionary+KeyPath.h"

@implementation HUSearchBarModel

-(id) initWithDictionary:(NSDictionary *)dictionary {
    
    if (self = [super init]) {
        
        self.parameters = dictionary;
    }
    
    return self;
}

-(NSString *) text {
    return [self.parameters objectForKeyPath:@"text"];
}

-(HUSearchBarModelType) type {
    return [[self.parameters objectForKeyPath:@"type"] integerValue];
}

-(UIKeyboardType) keyboardType {
    return [[self.parameters objectForKeyPath:@"keyboardType"] integerValue];
}

-(id) firstValue {
    return [self.parameters objectForKeyPath:@"value1"];
}

-(id) secondValue {
    return [self.parameters objectForKeyPath:@"value2"];
}

@end

@implementation HUSearchBarModel (Factory)

+(HUSearchBarModel *) selectionNamed:(NSString *)selectionName firstChoiceNamed:(NSString *)firstChoice secondChoiceNamed:(NSString *)secondChoice {
    
    NSAssert(selectionName && firstChoice && secondChoice, @"One of the provided parameters is NULL");
    
    NSDictionary *dict = @{@"text": selectionName, @"value1" : firstChoice, @"value2" : secondChoice, @"type" : @(HUSearchBarModelTypeSelection)};
    
    return [[HUSearchBarModel alloc] initWithDictionary:dict];
}

+(HUSearchBarModel *) textFieldWithPlaceholderText:(NSString *)placeholderText {
    
    return [HUSearchBarModel textFieldWithPlaceholderText:placeholderText keyboardType:UIKeyboardTypeDefault];
}

+(HUSearchBarModel *) textFieldWithPlaceholderText:(NSString *)placeholderText keyboardType:(UIKeyboardType)keyboardType {
    
    NSAssert(placeholderText, @"One of the provided parameters is NULL");
    
    NSDictionary *dict = @{@"text": placeholderText, @"type" : @(HUSearchBarModelTypeTextField), @"keyboardType" : @(keyboardType)};
    
    return [[HUSearchBarModel alloc] initWithDictionary:dict];
    
}

@end