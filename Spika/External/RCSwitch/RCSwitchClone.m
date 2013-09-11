/*
 Copyright (c) 2010 Robert Chin
 
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

#import "RCSwitchClone.h"


@implementation RCSwitchClone

- (void)initCommon
{
	[super initCommon];
	
	useImage = YES;
	NSArray *langs = [NSLocale preferredLanguages];
	if([langs count] > 0){
		NSString *langCode = [langs objectAtIndex:0];
		/* Note that the japanese localization for the switch will only load if you have
		 a Japanese Localizable.strings file in your app bundle. */
		if(![langCode isEqualToString:@"en"] && [langCode isEqualToString:@"ja"])
			useImage = NO;
	}	
	
	if(useImage){
		onImage = [[UIImage imageNamed:@"btn_slider_international_on"] retain];
		offImage = [[UIImage imageNamed:@"btn_slider_international_off"] retain];
	} else {
		onText = [UILabel new];
		onText.text = [[NSBundle bundleForClass:[UISwitch class]] localizedStringForKey:@"ON" value:nil table:nil];
		onText.textColor = [UIColor whiteColor];
		onText.font = [UIFont boldSystemFontOfSize:kFontSizeMiddium];
        onText.shadowOffset = CGSizeMake(0.0, -0.5);
		onText.shadowColor = [UIColor colorWithWhite:0.2 alpha:0.5];
		
		offText = [UILabel new];
		offText.text = [[NSBundle bundleForClass:[UISwitch class]] localizedStringForKey:@"OFF" value:nil table:nil];
		offText.textColor = [UIColor colorWithWhite:0.2 alpha:0.5];
		offText.font = [UIFont boldSystemFontOfSize:kFontSizeMiddium];
	}
}

- (void)dealloc
{
	[onText release];
	[offText release];
	[onImage release];
	[offImage release];
	[super dealloc];
}

- (void)drawUnderlayersInRect:(CGRect)aRect withOffset:(float)offset inTrackWidth:(float)trackWidth
{
	if(useImage){
		{
			CGPoint imagePoint = [self bounds].origin;
			imagePoint.x += 25.0 + (offset - trackWidth);
			imagePoint.y += 6.0;
			[onImage drawAtPoint:imagePoint];
			 
		}
		{
			CGPoint imagePoint = [self bounds].origin;
			imagePoint.x += -6 + (offset + trackWidth);
			imagePoint.y += 6.0;			
			[offImage drawAtPoint:imagePoint];			
		}
	} else {
		{
			CGRect textRect = [self bounds];
			textRect.origin.x += 14.0 + (offset - trackWidth);
			[onText drawTextInRect:textRect];	
		}
		
		{
			CGRect textRect = [self bounds];
			textRect.origin.x += -14 + (offset + trackWidth);
			[offText drawTextInRect:textRect];
		}
	}
}

@end
