//
//  CSTextView.h
//  CSTextView
//
//  Created by Luka Fajl on 7.5.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CSTextView : UITextView {
    NSMutableArray *formats;
    NSString *savedText;
}

@end
