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

#include <objc/runtime.h>
#import "UINavigationItem+AutoScrollLabel.h"
#import "AutoScrollLabel.h"

@implementation UINavigationItem (AutoScrollLabel)


+ (void)load {

    method_exchangeImplementations(
                                   class_getInstanceMethod(self, @selector(setTitle:)),
                                   class_getInstanceMethod(self, @selector(setTitleAutoScroll:)));
     
    
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (id) initWithTitle:(NSString *)title{
    
    if(self = [super init]){
    
        AutoScrollLabel *autoScrollLabel=[[AutoScrollLabel alloc] initWithFrame:CGRectMake(0,0,320,44)];
        autoScrollLabel.textColor = [UIColor clearColor];
        autoScrollLabel.backgroundColor = [UIColor clearColor];
        autoScrollLabel.text = title;
        autoScrollLabel.font = kFontArialMTBoldOfSize(kFontSizeBig);
    
        self.titleView = autoScrollLabel;
    }
    return self;
}
#pragma clang diagnostic pop

- (void) setTitleAutoScroll:(NSString *)title{
    
    [self setTitleAutoScroll:title];
    
    if([self.titleView isKindOfClass:[AutoScrollLabel class]]){
        
        AutoScrollLabel *autoScrollLabel = (AutoScrollLabel *)self.titleView;
        autoScrollLabel.text = [title stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        autoScrollLabel.font = kFontArialMTBoldOfSize(kFontSizeBig);
        
        [autoScrollLabel sizeToFit];
        
    }

    
}

- (void) readjustLayout{

    if([self.titleView isKindOfClass:[AutoScrollLabel class]]){
        
        AutoScrollLabel *autoScrollLabel = (AutoScrollLabel *)self.titleView;
        [autoScrollLabel readjustLabels];
        autoScrollLabel.textColor = [UIColor whiteColor];
        
        
    }

    
}
@end
