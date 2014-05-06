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

///returns the application center dependent on the status bar orientation
+ (CGPoint) center
{
    CGRect frame = [CSKit frame];
    return CGPointMake(frame.size.width / 2, frame.size.height / 2);
}

+(BOOL) isIPhone5
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize screenSize = [CSKit frame].size;
        return (screenSize.width > 480 || screenSize.height > 480);
    }
    
    return NO;
}

#pragma mark - UINavigationController
///iOS 3.0
///Creates an array of UINavigationControllers with rootViewControllers of classNames
///@param classNames an array of NSString containing names of view controller classes
///@return an autoreleased NSArray containing UINavigationControllers
+ (NSArray*) navigationControllersFromViewControllerClassNames:(NSArray*) classNames
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:classNames.count];
    for (NSString *className in classNames)
    {
        [array addObject:[self viewControllerWithNavigationFromString:className]];
    }
    return [NSArray arrayWithArray: array];
}

///iOS 3.0
///Creates an array of CSNavigationControllers with rootViewControllers of classNames
///@param classNames an array of NSString containing names of view controller classes
///@return an autoreleased NSArray containing CSNavigationControllers
+ (NSArray *) csNavigationControllersFromViewControllerClassNames:(NSArray*) classNames
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:classNames.count];
    for (NSString *className in classNames)
    {
        [array addObject:[self csViewControllerWithNavigationFromString:className]];
    }
    return [NSArray arrayWithArray: array];
}

///iOS 3.0
///Creates a UINavigationController instance with UIViewController of class className as it's rootViewController
///It also asigns the viewController's tabBarItem to navigationController's tabBarItem for easier use in UITabBarController environment
///@param className name of the view controllers class
///@return an autoreleased instance of UINavigationController
+ (UINavigationController *) viewControllerWithNavigationFromString:(NSString*) className
{
    UIViewController *viewController = [self viewControllerFromString:className];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.tabBarItem = viewController.tabBarItem;
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    return navigationController;
}

///iOS 3.0
///Creates a CSNavigationController instance with UIViewController of class className as it's rootViewController
///It also asigns the viewController's tabBarItem to navigationController's tabBarItem for easier use in UITabBarController environment
///@param className name of the view controllers class
///@return an autoreleased instance of CSNavigationController
+ (id) csViewControllerWithNavigationFromString:(NSString*) className
{
    UIViewController *viewController = [self viewControllerFromString:className];
    id navigationController = [[NSClassFromString(@"CSNavigationController") alloc] initWithRootViewController:viewController];
    [navigationController setTabBarItem: viewController.tabBarItem];
    [[navigationController navigationBar] setTintColor:[UIColor blackColor]];
    return navigationController;
}

#pragma mark - UIViewController

///iOS 3.0
///Creates a UIViewController instance of class className
///@param className name of the view controllers class
///@return an autoreleased instance of UINavigationController
+ (UIViewController *) viewControllerFromString:(NSString*) className
{
    Class class = NSClassFromString(className);
    UIViewController *viewController = (UIViewController*)[[class alloc] init];
    return viewController;
}

///iOS 3.0
///Creates an array of UIViewControllers of classNames
///@param classNames an array of NSString containing names of view controller classes
///@return an autoreleased NSArray containing UIViewControllers
+ (NSArray *) viewControllersFromClassNames:(NSArray*) classNames
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *className in classNames)
    {
        [array addObject:[self viewControllerFromString:className]];
    }
    return [NSArray arrayWithArray: array];
}

#pragma mark - UIImageView

///iOS 3.0
///Creates an UIImageView with given image name from library
///@param NSString with the name of the picture in the library
///@return an autoreleased UIImageView
+ (UIImageView *) imageViewWithImageNamed:(NSString *)imageName
{
    return [self imageViewWithImageNamed:imageName highlightedImageNamed:nil];
}

///iOS 3.0
///@method imageViewWithImage
///creates an UIImageView with frame (0, 0, image.size.width, image.size.height)
///@param image image to add to imageView
///@param highlightedImage highlighted image to set to imageview
///@return an autoreleased UIImageView
+ (UIImageView *) imageViewWithImage:(UIImage*)image
                    highlightedImage:(UIImage*) highlightedImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setHighlightedImage:highlightedImage];
    [imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    return imageView;
}

///iOS 3.0
///@method imageViewWithImageNamed:highlightedImageNamed:
///creates an UIImageView with frame (0, 0, image.size.width, image.size.height)
///@param imageName imageName to set to imageView
///@param highlightedImageName highlightedimageName to set to imageview
///@return an autoreleased UIImageView
+ (UIImageView *) imageViewWithImageNamed:(NSString*)imageName
                    highlightedImageNamed:(NSString*) highlightedImageName;
{
    return [self imageViewWithImage:[UIImage imageNamed:imageName]
                   highlightedImage:[UIImage imageNamed:highlightedImageName]];
}

///iOS 3.0
///@method imageViewWithImageNamed:highlightedImageNamed:
///creates an UIImageView witth frame (0, 0, image.size.width, image.size.height)
///@param imageName imageName to set to imageView
///@param highlightedImageName highlightedimageName to set to imageview
///@param origin frame.origin coordinate in view
///@return an autoreleased UIImageView
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

///iOS 3.0
///Creates an UIButton with two images, each for specific state
///@param NSString with the name of the picture in the library
///@return an autoreleased UIButton with images
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

///iOS 3.0
///Creates an UIButton with two images, each for specific state
///@param normal NSString with the name of the picture in the library
///@param highlighted NSString with the name of the picture in the library
///@param target selector target for UIControlEventTouchUpInside
///@param selector method for UIControlEventTouchUpInside
///@param center center coordinate in view
///@return an autoreleased UIButton with images
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


///iOS 3.0
///Creates a UIButton with two images, each for specific state
///@param normal NSString with the name of the picture in the library
///@param highlighted NSString with the name of the picture in the library
///@param target selector target for UIControlEventTouchUpInside
///@param selector method for UIControlEventTouchUpInside
///@param origin frame.origin coordinate in view
///@return an autoreleased UIButton with images
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

///iOS 3.0
///Creates an UITableView with UITableViewStylePlain
///@param frame frame in the view
///@param delegate UITableViewDelegate
///@param dataSource UITableViewDataSource
///@return an autoreleased UITableView
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

///iOS 3.0
///Creates an UITableView with UITableViewStyleGrouped
///@param frame frame in the view
///@param delegate UITableViewDelegate
///@param dataSource UITableViewDataSource
///@return an autoreleased UITableView
+ (UITableView *) tableViewGroupedWithFrame:(CGRect) frame
                                   delegate:(id<UITableViewDelegate>) delegate
                                 dataSource:(id<UITableViewDataSource>) dataSource
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.delegate = delegate;
    tableView.dataSource = dataSource;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return tableView;
}

#pragma mark - UILabel

///iOS 3.0
///Creates a UILabel with transparent background and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param text text to display
///@return an autoreleased UILabel
+ (UILabel *) labelWithFrame:(CGRect) frame
                        font:(UIFont*)font
                        text:(NSString*) text
{
    return [self labelWithFrame:frame font:font textColor:[UIColor blackColor] text:text];
}

///iOS 3.0
///Creates a UILabel with transparent background and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param textColor textColor to use
///@param text text to display
///@return an autoreleased UILabel
+ (UILabel *) labelWithFrame:(CGRect) frame
                        font:(UIFont*)font
                   textColor:(UIColor*)textColor
                        text:(NSString*) text
{
    return [self labelWithFrame:frame font:font textColor:textColor textAlignment:NSTextAlignmentLeft text:text];
}

///iOS 3.0
///Creates label with size fitted to text. Label is located at point parameter.
///@param font font of displayed text
///@param text text to display
///@param point origin of label
///@param constraintSize constraint size of label
+ (UILabel *) labelWithFont:(UIFont *)font
                    forText:(NSString *) text
                    atPoint:(CGPoint) point
         withConstraintSize:(CGSize) constraintSize {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.numberOfLines = 0;
    label.text = text;
    
    CGSize size = [text sizeForBoundingSize:CGSizeMake(constraintSize.width, MAXFLOAT)
                                       font:font];
    [label setFrame:CGRectMake(point.x, point.y, size.width, size.height)];
    
    return label;
}

///iOS 3.0
///Creates a UILabel with transparent background and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param textColor textColor to use
///@param textAlignment textAlignment to use
///@param text text to display
///@return an autoreleased UILabel
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

///iOS 3.0
///Creates a UIBarButtonItem with UIButton as a custom button
///@param normal NSString with the name of the picture in the library
///@param highlighted NSString with the name of the picture in the library
///@param target selector target for UIControlEventTouchUpInside
///@param selector method for UIControlEventTouchUpInside
///@return an autoreleased UIbBrButtonItem
+ (UIBarButtonItem *) barButtonItemWithNormalImageNamed:(NSString*) normal
                                            highlighted:(NSString*) highlighted
                                                 target:(id) target
                                               selector:(SEL) selector
{
    UIButton *button = [self buttonWithNormalImageNamed:normal highlightedImage:highlighted target:target selector:selector center:CGPointZero];
    return [self barButtonItemWithButton:button];
}

///iOS 3.0
///Creates a UIBarButtonItem with UIButton as a custom button
///@param button a button to form the UIBarButtonItemWith
///@return an autoreleased UIBarButtonItem
+ (UIBarButtonItem *) barButtonItemWithButton:(UIButton*) button
{
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - UITextView

///iOS 3.0
///Creates a transparent UITextView
///@param frame frame in the view
///@param font font to use
///@param editable is textView to be editable or not
///@return an autoreleased UIbBrButtonItem
+(UITextView *) textViewWithFrame:(CGRect) frame
                             font:(UIFont*) font
                         editable:(BOOL) editable
{
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    [textView setFont:font];
    [textView setEditable:editable];
    [textView setBackgroundColor:[UIColor clearColor]];
    return textView;
}

#pragma mark - UITableViewCell

///iOS 3.0
///@method tableViewCellDefault
///creates a tableviewcell with UITableViewCellStyleDefault
///@param reuseIdentifier reuseIdentifier
///@return an autoreleased UITableViewCell
+ (UITableViewCell *) tableViewCellDefault:(NSString*)reuseIdentifier
                                 tableView:(UITableView*)tableView
{
    return [self tableViewCellCustom:reuseIdentifier className:@"UITableViewCell" tableView:tableView];
}

///iOS 3.0
///@method tableView:cellDefault:className:
///tries to dequeue the cell from tableView and then if there is no cell
///creates a UITableViewCell with UITableViewCellStyleDefault
///@param tableView tableView to deque the cell from
///@param reuseIdentifier reuseIdentifier
///@param className class of the UITableViewCell. This needs to be a UITableViewCell subclass
///@return an autoreleased UITableViewCell
+ (UITableViewCell *) tableViewCellCustom:(NSString*)reuseIdentifier
                                className:(NSString*) className
                                tableView:(UITableView*)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[NSClassFromString(className) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

///iOS 3.0
///@method scrollViewWithFrame:contentSize:delegate:
///creates a UIScrollView
///@param frame frame in view
///@param contentSize contentSize in scrollView
///@param delegate UIScrollViewDelegate
///@return an autoreleased UIScrollView

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

///iOS 3.0
///@method alertViewShowWithTitle:message:delegate:cancelButton:otherButton:
///creates and shows UIAlertView
///@param title alertView title
///@param message alertView message
///@param delegate UIAlertViewDelegate
///@param cancelButton cancel button title
///@param otherButton other button title
///@return an autoreleased UIAlertView

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

///iOS 3.0
///Creates an alert view with unlimited progress UIActivityIndicatorView indicator
///@param title title to display
///@param delegate UIAlertViewDelegate
///@return an autoreleased UIAlertView
+ (UIAlertView *) alertViewUnlimitedProgressShow:(NSString*) title
                                        delegate:(id<UIAlertViewDelegate>) delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.title = title;
    [alertView show];
    UIActivityIndicatorView *activityindicator = [self activityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge
                                                                           center:CGPointMake(140, 64)];
    [alertView addSubview:activityindicator];
    return alertView;
}

///iOS 3.0
///Creates an alert view with timer which dissappears after duration of time
///@param title title to display
///@param message message to display
///@parap duration time interval which tells how long to display the alert
///@return an autoreleased UIAlertView
+ (UIAlertView *) alertViewTimedShowWithTitle:(NSString*) title
                                      message:(NSString*) message
                                     duration:(NSTimeInterval) duration
{
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.title = title;
    alertView.message = message;
    [alertView show];
    [NSTimer scheduledTimerWithTimeInterval:duration target:alertView selector:@selector(dismissWithClickedButtonIndex:animated:) userInfo:nil repeats:NO];
    return alertView;
}


#pragma mark - CSTextView

///iOS 3.0
///Creates a transparent CSTextView
///@param frame frame in the view
///@return an autoreleased CSTextView
+ (id) csTextViewWithFrame:(CGRect) frame
{
    id textView = [[NSClassFromString(@"CSTextView") alloc] initWithFrame:frame];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setEditable:NO];
    return textView;
}

#pragma mark - UITextField

///iOS 3.0
///Creates a text field with trandparent background color and black text color
///@param frame frame in the view
///@param font font to use
///@param text text to display
///@param placeholder placeholder to display
///@return an autoreleased UITextField
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

#pragma mark - UISearchBar

///iOS 3.0
///Creates a search bar with delegate, tint color
///@param frame frame in the view
///@param delegate id<UISearhBarDelegate>
///@param tintColor tintColor to display
///@return an autoreleased UISearchBar
+ (UISearchBar *) searchBarWithFrame:(CGRect) frame
                            delegate:(id<UISearchBarDelegate>) delegate
                           tintColor:(UIColor*) tintColor
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:frame];
    [searchBar setTintColor:tintColor];
    [searchBar setDelegate:delegate];
    return searchBar;
}

#pragma mark - UIActivityIndicatorView

///iOS 3.0
///Creates an activity indicator which is already running
///@param style UIActivityIndicatorViewStyle
///@return an autoreleased UIActivityIndicatorView
+ (UIActivityIndicatorView *) activityIndicatorWithStyle:(UIActivityIndicatorViewStyle) style
                                                  center:(CGPoint) center
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [activityIndicator setCenter:center];
    [activityIndicator startAnimating];
    return activityIndicator;
}

#pragma mark - UIView

///iOS 3.0
///Creates a view with frame [CSKit frame]
+ (UIView *) view
{
    return [[UIView alloc] initWithFrame:[CSKit frame]];
}

+ (UIView *) viewWithFrame:(CGRect) frame {

    return [[UIView alloc] initWithFrame:frame];
}




@end
