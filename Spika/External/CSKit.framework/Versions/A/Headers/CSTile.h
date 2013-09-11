//
//  CSTile.h
//  CSTileView
//
//  Created by Marko Hlebar on 4/11/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTile : UIView
{
    UIImageView *_backgroundImageView;
}

///@property reuseIdentifier
///sets the reuseIdentifier for CSTileView to use to efficiently reuse tiles which are not visible
///@default nil
@property (nonatomic, copy) NSString *reuseIdentifier;

///@property highlighted
///sets the tile to highlighted state
///if backgroundImageHighlighted and highlightedTextColor are set, then background and all labels also go to highlighted state
///@default NO
@property (nonatomic) BOOL highlighted;

///@property backgroundImage
///sets the background image for tile
///@default nil
@property (nonatomic, retain) UIImage *backgroundImage;

///@property backgroundImageHighlighted
///sets the background highlighted image for tile
///@default nil
@property (nonatomic, retain) UIImage *backgroundImageHighlighted;

///@property textColor
///sets the textColor for all UILabels which are subviews to tile
///@default nil
@property (nonatomic, retain) UIColor *textColor;

///@property textColorHiglighted
///sets the highlightedTextColor for all UILabels which are subviews to tile
///@default nil
@property (nonatomic, retain) UIColor *textColorHiglighted;

///@method initWithReuseIdentifier
///@param reuseIdentifier the reuseIdentifier for CSTileView to use to efficiently reuse tiles which are not visible
///@return CSTile instance
-(id) initWithReuseIdentifier:(NSString*) reuseIdentifier;

///@method tileWillBecomeVisible
///this method is called when the tile is about to become visible. Show images etc...
-(void) tileWillBecomeVisible;

///@method tileWillBecomeInvisible
///this method is called when the tile is about to become invisible. Remove images etc...
-(void) tileWillBecomeInvisible;
@end
