//
//  CSKit+Helper.m
//  CSKit
//
//  Created by marko.hlebar on 9/4/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSKit+Helper.h"

@implementation CSKit

///Returns a lorem ipsum string
+ (NSString *) loremIpsum
{
    return @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
}

///Prints all font families and fonts available to the app
+ (void) printFonts
{
	NSArray *fontFamilies = [UIFont familyNames];
	for (NSString *fontFamily in fontFamilies)
	{
		NSLog(@"%@", fontFamily);
		
		for (NSString *font in [UIFont fontNamesForFamilyName:fontFamily])
		{
			NSLog(@"    %@", font);
		}
	}
}

#pragma mark - Frames

///returns the application frame dependent on the status bae orientation
+ (CGRect) frame
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ?
    CGRectMake(0,0, frame.size.height, frame.size.width) : CGRectMake(0,0, frame.size.width, frame.size.height);
}

#pragma mark - UIImageView

+ (UIImageView *) imageViewWithImageNamed:(NSString *)imageName
{
    return [self imageViewWithImageNamed:imageName highlightedImageNamed:nil];
}

+ (UIImageView *) imageViewWithImage:(UIImage*)image
                    highlightedImage:(UIImage*) highlightedImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setHighlightedImage:highlightedImage];
    [imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    return imageView;
}

+ (UIImageView *) imageViewWithImageNamed:(NSString*)imageName
                    highlightedImageNamed:(NSString*) highlightedImageName;
{
    return [self imageViewWithImage:[UIImage imageNamed:imageName]
                   highlightedImage:[UIImage imageNamed:highlightedImageName]];
}

+ (UIImageView *) imageViewWithImageNamed:(NSString*)imageName
                    highlightedImageNamed:(NSString*) highlightedImageName
                                   origin:(CGPoint) origin
{
    UIImageView *imageView = [CSKit imageViewWithImageNamed:imageName highlightedImageNamed:highlightedImageName];
    CGRect frame = imageView.frame;
    frame.origin = origin;
    imageView.frame = frame;
    return imageView;
}

#pragma mark - UIButton

+ (UIButton *) buttonWithNormalImageNamed:(NSString *)normalImage
                         highlightedImage:(NSString *)highlightedImage {
    
    UIImage *imageNormal = [UIImage imageNamed:normalImage];
    UIImage *imageHighlight = [UIImage imageNamed:highlightedImage];
    
    UIButton *button;
    
    if (imageNormal.size.height > imageHighlight.size.height || imageNormal.size.width > imageHighlight.size.width)
        button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageNormal.size.width, imageNormal.size.height)];
    else
        button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageHighlight.size.width, imageHighlight.size.height)];
    
    [button setImage:imageNormal forState:UIControlStateNormal];
    [button setImage:imageHighlight forState:UIControlStateHighlighted];
    
    return button;
}

+ (UIButton *) buttonWithNormalImageNamed:(NSString*) normal
                         highlightedImage:(NSString*) highlighted
                                   target:(id) target
                                 selector:(SEL) selector
                                   center:(CGPoint) center
{
    UIButton *btn = [CSKit buttonWithNormalImageNamed:normal
                                     highlightedImage:highlighted
                                               target:target
                                             selector:selector
                                               origin:CGPointZero];
	[btn setCenter:center];
	return btn;
}

+ (UIButton *) buttonWithNormalImageNamed:(NSString*) normal
                         highlightedImage:(NSString*) highlighted
                                   target:(id) target
                                 selector:(SEL) selector
                                   origin:(CGPoint) origin
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect btnRect = CGRectMake(origin.x, origin.y, 64, 64);
	if (normal)
	{
		UIImage *btnImage = [UIImage imageNamed:normal];
		[btn setImage:btnImage forState:UIControlStateNormal];
		btnRect = CGRectMake(btnRect.origin.x, btnRect.origin.y, btnImage.size.width, btnImage.size.height);
	}
	if (highlighted)
	{
		UIImage *btnImageOn = [UIImage imageNamed:highlighted];
		[btn setImage:btnImageOn forState:UIControlStateHighlighted];
	}
	if (target && selector)
	{
		[btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	}
	[btn setFrame:btnRect];
    return btn;
}

#pragma mark - UITableView

+ (UITableView *) tableViewPlainWithFrame:(CGRect) frame
                                 delegate:(id<UITableViewDelegate>) delegate
                               dataSource:(id<UITableViewDataSource>) dataSource
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = delegate;
    tableView.dataSource = dataSource;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return tableView;
}

#pragma mark - UILabel

+ (UILabel *) labelWithFrame:(CGRect) frame
                        font:(UIFont*)font
                   textColor:(UIColor*)textColor
               textAlignment:(NSTextAlignment) textAlignment
                        text:(NSString*) text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.text = text;
    label.textColor = textColor;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = textAlignment;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

#pragma mark - UIBarButtonItem

+ (UIBarButtonItem *) barButtonItemWithNormalImageNamed:(NSString*) normal
                                            highlighted:(NSString*) highlighted
                                                 target:(id) target
                                               selector:(SEL) selector
{
    UIButton *button = [self buttonWithNormalImageNamed:normal highlightedImage:highlighted target:target selector:selector center:CGPointZero];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - UIScrollView

+ (UIScrollView *) scrollViewWithFrame:(CGRect) frame
                           contentSize:(CGSize) contentSize
                              delegate:(id<UIScrollViewDelegate>) delegate
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = contentSize;
    scrollView.delegate = delegate;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return scrollView;
}

#pragma mark - UIAlertView

+ (UIAlertView *) alertViewShowWithTitle:(NSString*) title
                                 message:(NSString*) message
                                delegate:(id<UIAlertViewDelegate>) delegate
                            cancelButton:(NSString*) cancel
                             otherButton:(NSString*) other
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:other, nil];
    [alertView show];
    return alertView;
}

#pragma mark - UITextField

+ (UITextField *) textFieldWithFrame:(CGRect) frame
                                font:(UIFont*) font
                                text:(NSString*) text
                         placeholder:(NSString*) placeholder
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setFont:font];
    [textField setText:text];
    [textField setPlaceholder:placeholder];
    return textField;
}

#pragma mark - UIView

+ (UIView *) view
{
    return [[UIView alloc] initWithFrame:[CSKit frame]];
}

+ (UIView *) viewWithFrame:(CGRect) frame {

    return [[UIView alloc] initWithFrame:frame];
}




@end
