//
//  CSTileView.h
//  CSTileView
//
//  Created by Marko Hlebar on 4/11/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSPullToRefreshView <NSObject>
@required;
-(void) pullToRefresh;
-(void) releaseToRefresh;
-(void) refreshInProgress;
-(void) refreshDone;
@end

@class CSTile;
@class CSTileView;

///CSTileViewDataSource
///Provides a data source for the CSTileView
@protocol CSTileViewDataSource <NSObject>
@required
///Asks the data source for an instance of CSTile for index. required
///@param tileView The tile view object requesting this information.
///@param index Index of the requested tile.
///@return A dequeued instance od CSTile object.
-(CSTile*) tileView:(CSTileView*)tileView tileForIndex:(NSUInteger) index;

///Asks the data source for the number of tiles to display in the tile view. required
///@param tileView The tile view object requesting this information.
///@return Number of tiles to dispay.
-(NSUInteger) numberOfTilesInTileView:(CSTileView*) tileView;

///Asks the data source for a desired frame for tile at index. required
///The tile may send this request, but the tile view decides how much space each displayed tile gets
///@param tileView The tile view object requesting this information.
///@param index Index of the requested tile.
///@return Desired frame of the tile.
-(CGRect) tileView:(CSTileView*) tileView desiredFrameForTileAtIndex:(NSUInteger) index;
@optional

///Asks the data source for a header view for tile view.
///If nil is returned, the tile view doesn't show a header view.
///@param tileView The tile view object requesting this information.
///@return An instance of UIView of arbitrary size and content
-(UIView*) headerViewForTileView:(CSTileView*) tileView;

///Asks the data source for a footer view for tile view.
///If nil is returned, the tile view doesn't show a footer view.
///@param tileView The tile view object requesting this information.
///@return An instance of UIView of arbitrary size and content
-(UIView*) footerViewForTileView:(CSTileView*) tileView;

///Asks the data source for a pull to refresh view for tile view.
///If nil is returned, the tile view doesn't show a pull to refresh view.
///@param tileView The tile view object requesting this information.
///@return An instance of UIView of arbitrary size and content
-(UIView<CSPullToRefreshView>*) pullRefreshViewForTileView:(CSTileView*) tileView;

///Asks the data source if the pull refresh action is done for a tile view
///@param tileView The tile view object requesting this information.
///@return YES if done. 
-(BOOL) pullRefreshDoneForTileView:(CSTileView*) tileView;
@end

@protocol CSTileViewDelegate <UIScrollViewDelegate>
-(void) tileView:(CSTileView*)tileView didSelectTileAtIndex:(NSUInteger) index;
///pull to refresh
@optional
-(void) pullRefreshDataForTileView:(CSTileView*) tileView;
@end

typedef struct {
    NSUInteger index;
    CGRect frame;
    NSUInteger row;
    NSUInteger column;
} CSTileDef;

///CSTileView
///provides an interface for managing tiles of variable size in a view.
///The class respects the size of the tile provided in the 
//-(CGRect) desiredFrameForTileAtIndex:(NSUInteger) index;
///method based on the resizing method provided
///resizeMethod property determines how the tiles are resized when presented on the view
///CSTileViewResizeConstantSize takes the tileSize property of CSTileView as a constant size value
///for all tiles
///CSTileViewResizeConstantWidth takes the tileSize.width property of CSTileView as a constant width value
///and resizes the height of each tile based on it's width / height ratio
///CSTileViewResizeConstantHeight takes the tileSize.height property of CSTileView as a constant height value
///and resizes the width of each tile based on it's width / height ratio
///@default CSTileViewResizeConstantSize

typedef enum 
{
    CSTileViewResizeConstantSize,
    CSTileViewResizeConstantWidth,
    CSTileViewResizeConstantHeight
} CSTileViewResizeMethod;

@interface CSTileView : UIScrollView <UIScrollViewDelegate>
{
    @protected
    NSUInteger _numTiles;
    UIScrollView *_scrollView;
    NSMutableSet *_queuedTiles;
    NSMutableSet *_visibleTiles;
    NSMutableSet *_visibleIndices;
    
    NSMutableSet *_newVisibleIndices;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    NSMutableArray *_calculatedFrames;
    UIView *_headerView;
    UIView *_footerView;
    
    ///pull to refresh
    BOOL _isPullToRefresh;
    UIView<CSPullToRefreshView> *_pullToRefreshView;
    NSTimer *_pullToRefreshTimer;
    
    id <UIScrollViewDelegate> _forwardDelegate;
}

@property (nonatomic, readwrite) CSTileViewResizeMethod resizeMethod;
@property (nonatomic, assign) id <CSTileViewDataSource> dataSource;
@property (nonatomic, assign) id <CSTileViewDelegate> tileDelegate;
@property (nonatomic, readwrite) CGSize tileSize;
@property (nonatomic, readwrite) NSUInteger forwardPages;

-(CSTile*) dequeueTileWithReuseIdentifier:(NSString*) reuseIdentifier;
-(void) setNumberOfVisibleTilesHorizontally:(uint)width vertically:(uint)height;
-(void) reloadData;
-(void) addTiles;

@end
