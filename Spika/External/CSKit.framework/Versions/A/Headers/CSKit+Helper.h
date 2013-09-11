//
//  CSKit+Helper.h
//  CSKit
//
//  Created by marko.hlebar on 9/4/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSKit : NSObject

///Returns a lorem ipsum string
+(NSString*) loremIpsum;

///Prints all font families and fonts available to the app
+(void) printFonts;

///returns the application frame dependent on the status bar orientation
+(CGRect) frame;

///returns the application center dependent on the status bar orientation
+(CGPoint) center;

///returns YES if iPhone has screen larger than 480p
+(BOOL) isIPhone5;

/*
///iOS 3.0
///Creates a custom CSTabBarItem
///@param image normal image
///@param selectedImage image when the tab is selected
///@return an autoreleased instance of CSTabBarItem
+(id)csTabBarItemWithImage:(UIImage *)image
             selectedImage:(UIImage *)selectedImage;
*/

#pragma mark - TabBarItem
 
///iOS 5.0
///Creates a custom UITabBarItem
///@param image normal image
///@param selectedImage image when the tab is selected
///@param title title of the tab
///@param font custom font to use. nil for default
///@return an autoreleased instance of UITabBarItem
+(UITabBarItem *)tabBarItemWithImage:(UIImage *)image
                       selectedImage:(UIImage *)selectedImage
                               title:(NSString *)title
                                font:(UIFont *)font;

///iOS 3.0
///Creates a custom UITabBarItem
///@param imageName imageName
///@param title title of the tab
///@param tag tag of the tab
///@return an autoreleased instance of UITabBarItem
+(UITabBarItem *)tabBarItemWithImageNamed:(NSString *)imageName
                                    title:(NSString *)title
                                      tag:(NSInteger) tag;


#pragma mark - UINavigationController

///iOS 3.0
///Creates an array of UINavigationControllers with rootViewControllers of classNames
///@param classNames an array of NSString containing names of view controller classes
///@return an autoreleased NSArray containing UINavigationControllers
+(NSArray*) navigationControllersFromViewControllerClassNames:(NSArray*) classNames;

///iOS 3.0
///Creates an array of CSNavigationControllers with rootViewControllers of classNames
///@param classNames an array of NSString containing names of view controller classes
///@return an autoreleased NSArray containing CSNavigationControllers
+(NSArray*) csNavigationControllersFromViewControllerClassNames:(NSArray*) classNames;

///iOS 3.0
///Creates a UINavigationController instance with UIViewController of class className as it's rootViewController
///It also asigns the viewController's tabBarItem to navigationController's tabBarItem for easier use in UITabBarController environment
///@param className name of the view controllers class
///@return an autoreleased instance of UINavigationController
+(UINavigationController*) viewControllerWithNavigationFromString:(NSString*) className;

///iOS 3.0
///Creates a CSNavigationController instance with UIViewController of class className as it's rootViewController
///It also asigns the viewController's tabBarItem to navigationController's tabBarItem for easier use in UITabBarController environment
///@param className name of the view controllers class
///@return an autoreleased instance of CSNavigationController
+(id) csViewControllerWithNavigationFromString:(NSString*) className;

#pragma mark - UIViewController

///iOS 3.0
///Creates a UIViewController instance of class className
///@param className name of the view controllers class
///@return an autoreleased instance of UINavigationController
+(UIViewController*) viewControllerFromString:(NSString*) className;

///iOS 3.0
///Creates an array of UIViewControllers of classNames
///@param classNames an array of NSString containing names of view controller classes
///@return an autoreleased NSArray containing UIViewControllers
+(NSArray*) viewControllersFromClassNames:(NSArray*) classNames;

#pragma mark - UIImageView

///iOS 3.0
///Creates a UIImageView with given image name from library
///@param NSString with the name of the picture in the library
///@return an autoreleased UIImageView
+(UIImageView*) imageViewWithImageNamed:(NSString*)imageName;

///iOS 3.0
///@method imageViewWithImage:highlightedImage:
///creates an UIImageView witth frame (0, 0, image.size.width, image.size.height)
///@param image image to set to imageView
///@param highlightedImage highlighted image to set to imageview
///@return an autoreleased UIImageView
+(UIImageView*) imageViewWithImage:(UIImage*)image highlightedImage:(UIImage*) highlightedImage;

///iOS 3.0
///@method imageViewWithImageNamed:highlightedImageNamed:
///creates an UIImageView witth frame (0, 0, image.size.width, image.size.height)
///@param imageName imageName to set to imageView
///@param highlightedImageName highlightedimageName to set to imageview
///@return an autoreleased UIImageView
+(UIImageView*) imageViewWithImageNamed:(NSString*)imageName highlightedImageNamed:(NSString*) highlightedImageName;

///iOS 3.0
///@method imageViewWithImageNamed:highlightedImageNamed:
///creates an UIImageView witth frame (0, 0, image.size.width, image.size.height)
///@param imageName imageName to set to imageView
///@param highlightedImageName highlightedimageName to set to imageview
///@param origin frame.origin coordinate in view
///@return an autoreleased UIImageView
+(UIImageView*) imageViewWithImageNamed:(NSString*)imageName highlightedImageNamed:(NSString*) highlightedImageName origin:(CGPoint) origin;

#pragma mark - UIButton

///iOS 3.0
///Creates a UIButton with two images, each for specific state
///@param NSString with the name of the picture in the library
///@return an autoreleased UIButton with images
+(UIButton*) buttonWithNormalImageNamed:(NSString*)normalImage highlightedImage:(NSString*)highlightedImage;


///iOS 3.0
///Creates a UIButton with two images, each for specific state
///@param normal NSString with the name of the picture in the library
///@param highlighted NSString with the name of the picture in the library
///@param target selector target for UIControlEventTouchUpInside
///@param selector method for UIControlEventTouchUpInside
///@param center center coordinate in view
///@return an autoreleased UIButton with images
+(UIButton*) buttonWithNormalImageNamed:(NSString*) normal highlightedImage:(NSString*) highlighted target:(id) target selector:(SEL) selector center:(CGPoint) center;

///iOS 3.0
///Creates a UIButton with two images, each for specific state
///@param normal NSString with the name of the picture in the library
///@param highlighted NSString with the name of the picture in the library
///@param target selector target for UIControlEventTouchUpInside
///@param selector method for UIControlEventTouchUpInside
///@param origin frame.origin coordinate in view
///@return an autoreleased UIButton with images
+(UIButton*) buttonWithNormalImageNamed:(NSString*) normal highlightedImage:(NSString*) highlighted target:(id) target selector:(SEL) selector origin:(CGPoint) origin;

#pragma mark - UITableView

///iOS 3.0
///Creates a UITableView with UITableViewStylePlain
///@param frame frame in the view
///@param delegate UITableViewDelegate
///@param dataSource UITableViewDataSource
///@return an autoreleased UITableView
+(UITableView*) tableViewPlainWithFrame:(CGRect) frame delegate:(id<UITableViewDelegate>) delegate dataSource:(id<UITableViewDataSource>) dataSource;

///iOS 3.0
///Creates a UITableView with UITableViewStyleGrouped
///@param frame frame in the view
///@param delegate UITableViewDelegate
///@param dataSource UITableViewDataSource
///@return an autoreleased UITableView
+(UITableView*) tableViewGroupedWithFrame:(CGRect) frame delegate:(id<UITableViewDelegate>) delegate dataSource:(id<UITableViewDataSource>) dataSource;

#pragma mark - UILabel

///iOS 3.0
///Creates a UILabel with transparent background, textAlignment = UITextAlignmentLeft and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param text text to display
///@return an autoreleased UILabel
+(UILabel*) labelWithFrame:(CGRect) frame font:(UIFont*)font text:(NSString*) text;

///iOS 3.0
///Creates a UILabel with transparent background, textAlignment = UITextAlignmentLeft and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param textColor textColor to use
///@param text text to display
///@return an autoreleased UILabel
+(UILabel*) labelWithFrame:(CGRect) frame font:(UIFont*)font textColor:(UIColor*)textColor text:(NSString*) text;

///iOS 3.0
///Creates label with size fitted to text. Label is located at point parameter.
///@param font font of displayed text
///@param text text to display
///@param point origin of label
///@param constraintSize constraint size of label
+ (UILabel *) labelWithFont:(UIFont *)font forText:(NSString *) text atPoint: (CGPoint) point withConstraintSize: (CGSize) constraintSize;

///iOS 3.0
///Creates a UILabel with transparent background and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param textColor textColor to use
///@param textAlignment textAlignment to use
///@param text text to display
///@return an autoreleased UILabel
+(UILabel*) labelWithFrame:(CGRect) frame font:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(UITextAlignment) textAlignment text:(NSString*) text;

#pragma mark - UIBarButtonItem

///iOS 3.0
///Creates a UIBarButtonItem with UIButton as a custom button
///@param normal NSString with the name of the picture in the library
///@param highlighted NSString with the name of the picture in the library
///@param target selector target for UIControlEventTouchUpInside
///@param selector method for UIControlEventTouchUpInside
///@return an autoreleased UIBarButtonItem
+(UIBarButtonItem*) barButtonItemWithNormalImageNamed:(NSString*) image
                                          highlighted:(NSString*) highlighted
                                               target:(id) target
                                             selector:(SEL) selector;

///iOS 3.0
///Creates a UIBarButtonItem with UIButton as a custom button
///@param button a button to form the UIBarButtonItemWith
///@return an autoreleased UIBarButtonItem
+(UIBarButtonItem*) barButtonItemWithButton:(UIButton*) button;

///iOS 4.0
///Creates a custom CSBarButtonItem with UIActivityIndicatorView added as subview
+(UIBarButtonItem *) barButtonItemWithActivitiIndicator;

///iOS 4.0
///Creates a custom CSBarButtonItem
///@param UIActivityIndicatorViewStyle style of UIActivityIndicatorView
+(UIBarButtonItem *) barButtonItemWithActivitiIndicator:(UIActivityIndicatorViewStyle)indicatorStyle;

///iOS 4.0
///Creates a custom CSBarButtonItem
///@param CGFloat widht of fixed item
+(UIBarButtonItem *) barButtonItemWithFixedSpace:(CGFloat) width;

#pragma mark - UITextView

///iOS 3.0
///Creates a transparent UITextView
///@param frame frame in the view
///@param font font to use
///@param editable is textView to be editable or not
///@return an autoreleased UITextView
+(UITextView*) textViewWithFrame:(CGRect) frame
                            font:(UIFont*) font
                        editable:(BOOL) editable;

#pragma mark - UITableViewCell

///iOS 3.0
///@method tableViewCellDefault:tableView:
///tries to dequeue the cell from tableView and then if there is no cell
///creates a UITableViewCell with UITableViewCellStyleDefault
///@param reuseIdentifier reuseIdentifier
///@param tableView tableView to deque the cell from
///@return an autoreleased UITableViewCell
+(UITableViewCell*) tableViewCellDefault:(NSString*)reuseIdentifier tableView:(UITableView*)tableView;

///iOS 3.0
///@method tableViewCellCustom:className:tableView:
///tries to dequeue the cell from tableView and then if there is no cell
///creates a UITableViewCell with UITableViewCellStyleDefault
///@param reuseIdentifier reuseIdentifier
///@param className class of the UITableViewCell. This needs to be a UITableViewCell subclass
///@param tableView tableView to deque the cell from
///@return an autoreleased UITableViewCell
+(UITableViewCell*) tableViewCellCustom:(NSString*)reuseIdentifier className:(NSString*) className tableView:(UITableView*)tableView;

/*
///iOS 3.0
///@method csSegmentedControlWithImages:highlightedImages:
///creates a CSSegmentedControl
///@param images array of images to set to segmented control
///@param highlightedImages array of highlighted images to set to segmented control
///@parma frame frame in view
///@param target selector target for UIControlEventValueChanged
///@param selector method for UIControlEventValueChanged
///@return an autoreleased CSSegmentedControl
+(id) csSegmentedControlWithImages:(NSArray*) images
                 highlightedImages:(NSArray*) highlightedImages
                             frame:(CGRect) frame
                            target:(id) target
                          selector:(SEL) selector;
*/

#pragma mark - UIScrollView

///iOS 3.0
///@method scrollViewWithFrame:contentSize:delegate:
///creates a UIScrollView
///@param frame frame in view
///@param contentSize contentSize in scrollView
///@param delegate UIScrollViewDelegate
///@return an autoreleased UIScrollView

+(UIScrollView*) scrollViewWithFrame:(CGRect) frame
                         contentSize:(CGSize) contentSize
                            delegate:(id<UIScrollViewDelegate>) delegate;


#pragma mark - UIAlertView

///iOS 3.0
///@method alertViewShowWithTitle:message:delegate:cancelButton:otherButton:
///creates and shows UIAlertView
///@param title alertView title
///@param message alertView message
///@param delegate UIAlertViewDelegate
///@param cancelButton cancel button title
///@param otherButton other button title
///@return an autoreleased UIAlertView

+(UIAlertView*) alertViewShowWithTitle:(NSString*) title
                               message:(NSString*) message
                              delegate:(id<UIAlertViewDelegate>) delegate
                          cancelButton:(NSString*) cancel
                           otherButton:(NSString*) other;

///iOS 3.0
///Creates an alert view with unlimited progress UIActivityIndicatorView indicator
///@param title title to display
///@param delegate UIAlertViewDelegate
///@return an autoreleased UIAlertView
+(UIAlertView*) alertViewUnlimitedProgressShow:(NSString*) title
                                      delegate:(id<UIAlertViewDelegate>) delegate;


///iOS 3.0
///Creates an alert view with timer which dissappears after duration of time
///@param title title to display
///@param message message to display
///@parap duration time interval which tells how long to display the alert
///@return an autoreleased UIAlertView
+(UIAlertView*) alertViewTimedShowWithTitle:(NSString*) title
                                    message:(NSString*) message
                                   duration:(NSTimeInterval) duration;

#pragma mark - CSTextView

///iOS 4.0
///Creates a transparent CSTextView
///@param frame frame in the view
///@return an autoreleased CSTextView
+(id) csTextViewWithFrame:(CGRect) frame;

#pragma mark - UITextField

///iOS 3.0
///Creates a text field with transparent background color and black text color
///@param frame frame in the view
///@param font font to use
///@param text text to display
///@param placeholder placeholder to display
///@return an autoreleased UITextField
+(UITextField*) textFieldWithFrame:(CGRect) frame
                              font:(UIFont*) font
                              text:(NSString*) text
                       placeholder:(NSString*) placeholder;

#pragma mark - UISearchBar
///iOS 3.0
///Creates a search bar with delegate, tint color
///@param frame frame in the view
///@param delegate id<UISearhBarDelegate>
///@param tintColor tintColor to display
///@return an autoreleased UISearchBar
+(UISearchBar*) searchBarWithFrame:(CGRect) frame
                          delegate:(id<UISearchBarDelegate>) delegate
                         tintColor:(UIColor*) tintColor;


#pragma mark - UIActivityIndicatorView

///iOS 3.0
///Creates an activity indicator which is already running
///@param style UIActivityIndicatorViewStyle
///@param center center point in view
///@return an autoreleased UIActivityIndicatorView
+(UIActivityIndicatorView*) activityIndicatorWithStyle:(UIActivityIndicatorViewStyle) style
                                                center:(CGPoint) center;

#pragma mark - UIView

///iOS 3.0
///Creates a view with frame [CSKit frame]
///@return an autoreleased UIView
+(UIView*) view;

///iOS 3.0
///Creates a view with given frame
///@param frame frame of view
///@return an autoreleased UIView
+ (UIView *) viewWithFrame:(CGRect) frame;


@end

