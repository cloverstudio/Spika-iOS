//
//  CSImageScrollView.h
//  StoragePipe
//
//  Created by Giga Bernat on 5/2/12.
//  Copyright (c) 2012 __Clover-Studio__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Availability.h>


NS_CLASS_AVAILABLE_IOS(4_0) @interface CSImageScrollView : UIScrollView <UIScrollViewDelegate>

//default 0. use it as aditional tag property
@property (nonatomic) NSInteger index;

//tells you if CSImageScrollView has image to display
@property (nonatomic, readonly) BOOL hasImage;

//default YES. if YES user can double tap to zoom
@property (nonatomic, readwrite) BOOL canDoubleTapToZoom;

///iOS 4.0
///Creates a custom CSTabBarItem
///@param image image that will be displayed in CSImageScrollView
-(void) setImage:(UIImage *)image;

///iOS 4.0
///Removes visible image from CSImageScrollView
-(void) removeImage;

///iOS 4.0
///@return current UIImage in CSImageScrollView
-(UIImage *)visibleImage;


///iOS 4.0
///@return current frame of image that is displayed in CSImageScrollView. Origin coordinates are relative to CSImageScrollView
-(CGRect) visibleImageFrame;

@end
