//
//  CSPhotoGallery.h
//  CSPhotoGallery
//
//  Created by Giga Bernat on 7/17/12.
//  Copyright (c) 2012 __Clover-Studio__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSPhotoGallery;

@protocol CSPhotoGalleryDataSource <NSObject>

-(NSInteger) numberOfPhotosInPhotoGallery:(CSPhotoGallery *)photoGallery;
-(UIImage *) imageForIndex:(NSUInteger) index inPhotoGallery:(CSPhotoGallery *) photoGallery;

@end

@interface CSPhotoGallery : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id<CSPhotoGalleryDataSource> dataSource;
@property (nonatomic) BOOL showsPageControll;
//@property (nonatomic) BOOL canPinchToZoom;
@property (nonatomic) BOOL canDoubleTapToZoom;

-(void) reloadImages;
-(void) setVisiblePhoto:(NSInteger) photoIndex;
-(void) setVisiblePhoto:(NSInteger)photoIndex animated:(BOOL) animated;

@end
