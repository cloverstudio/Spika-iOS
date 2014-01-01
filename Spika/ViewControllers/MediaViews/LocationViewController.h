/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
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

#import "HUBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Models.h"


@interface LocationViewController : HUBaseViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    
    ModelMessage *_message;
}

@property (nonatomic, strong) CLLocationManager *locationManager;



@property (nonatomic, strong) UIBarButtonItem *rightButtonItem;
//@property (nonatomic, strong) ModelMessage *message;
@property (nonatomic) int targetMode;
@property (nonatomic, strong) ModelUser *targetUser;
@property (nonatomic, strong) ModelGroup *targetGroup;
@property (nonatomic, strong) CLLocation *sendersLocation;

// should Location serchFor current location or should it load the location from message
@property (nonatomic) BOOL shouldSearchForLocation;

//initializes to acquire current locaion
- (id) initWithTargetUser:(ModelUser*)targetUser targetGroup:(ModelGroup*)targetGroup targetMode:(int)targetMode;
//          initWithMessage:(ModelMessage *)message andTargetMode:(int) targetMode;

//Initializes view to see frends loation
- (id)initWithMessage:(ModelMessage *)message;

@end



