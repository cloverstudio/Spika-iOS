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

///iOS 3.0
///Creates a UITableView with UITableViewStylePlain
///@param frame frame in the view
///@param delegate UITableViewDelegate
///@param dataSource UITableViewDataSource
///@return an autoreleased UITableView
+(UITableView*) tableViewPlainWithFrame:(CGRect) frame delegate:(id<UITableViewDelegate>) delegate dataSource:(id<UITableViewDataSource>) dataSource;

#pragma mark - UILabel

///iOS 3.0
///Creates a UILabel with transparent background and adjustsFontToFitWidth = YES
///@param frame frame in the view
///@param font font to use
///@param textColor textColor to use
///@param textAlignment textAlignment to use
///@param text text to display
///@return an autoreleased UILabel
+(UILabel*) labelWithFrame:(CGRect) frame font:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment) textAlignment text:(NSString*) text;

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

