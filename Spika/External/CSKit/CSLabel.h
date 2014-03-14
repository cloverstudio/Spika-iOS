//
//  CSLabel.h
//  AirVinyl
//
//  Created by Luka Fajl on 9.8.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSLabel : UILabel

@property (nonatomic, assign) UIColor *outlineColor, *underlineColor, *strikeoutColor;
@property (nonatomic, readwrite) uint outlineWidth, underlineWidth, underlineOffset, strikeoutWidth;
@property (nonatomic, readwrite) UIEdgeInsets margin;
-(void) sizeToFit;

@end
