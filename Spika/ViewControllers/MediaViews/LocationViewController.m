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

#import "LocationViewController.h"
#import "LocationViewController+Style.h"
#import "Models.h"
#import "UserManager.h"
#import "DatabaseManager.h"
#import "CSToast.h"
#import "StrManager.h"
#import "MapViewAnnotation.h"
#import "MapViewBubbleAnnotation.h"
#import "HUMapBubbleView.h"
#import "NSDateFormatter+SharedFormatter.h"
#import "AppDelegate.h"
#import "AlertViewManager.h"
#import "Utils.h"
#import "HUCachedImageLoader.h"

@interface LocationViewController () {

    MKMapView   *_mapView;
    MKAnnotationView *_locationAnnotationView;
    MapViewBubbleAnnotation *_bubbleAnnotation;
}

//@property (nonatomic, strong) UILabel *lblLatitude;
//@property (nonatomic, strong) UILabel *lblLongitude;
//@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic) BOOL isBubbleDisplayed;

@end

@implementation LocationViewController
@synthesize locationManager;


#pragma mark - Initialization

- (id)initWithMessage:(ModelMessage *)message
{
    self = [super init];
    if (self) {
        
//        self.title = @"Location Detail";
        _message = message;
        self.shouldSearchForLocation=NO;
        

        //[self buildComments];
    }
    return self;
}



-(id)initWithTargetUser:(ModelUser*)targetUser targetGroup:(ModelGroup*)targetGroup targetMode:(int)targetMode
//- (id)initWithMessage:(ModelMessage *)message andTargetMode:(int) targetMode
{
    self = [super init];
    if (self) {
//        self.title = @"Location";
        self.targetMode=targetMode;
        self.targetUser=targetUser;
        self.targetGroup=targetGroup;
        //self.sendersLocation=[[CLLocation alloc] init];
        self.sendersLocation=nil;
        self.shouldSearchForLocation=YES;

    }
    return self;
}

#pragma mark - Override

- (NSString *) title {
    if (_shouldSearchForLocation){
        return NSLocalizedString(@"Location-Title-Search",nil); 
    }else {
        return NSLocalizedString(@"Location-Title-Show",nil);        
    }
    //return NSLocalizedString((_shouldSearchForLocation ? @"Location-Title-" : @"Location-Title"), @"");
}

#pragma mark - View Lifecycle
-(UIView*)getUserHeader{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,65)];
    header.backgroundColor = [UIColor colorWithWhite:0 alpha:0.69];
    NSString *usersNameString=nil;
    ModelUser *user = [[[UserManager defaultManager] getLoginedUser] copy];
    if (self.shouldSearchForLocation){
        usersNameString = [[NSString stringWithFormat:NSLocalizedString(@"LocationTitle",nil),user.name] uppercaseString];
    }else{
        user._id = _message.from_user_id;
        usersNameString = [[NSString stringWithFormat:NSLocalizedString(@"LocationTitle",nil),_message.from_user_name] uppercaseString];
    }
    
    UILabel *usersNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65,46,260,20)];
    usersNameLabel.backgroundColor = [UIColor clearColor];
    usersNameLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    usersNameLabel.textColor = [UIColor whiteColor];
    usersNameLabel.text=usersNameString;

    __block UIImageView *usersAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 52, 52)];
	usersAvatarImageView.image = [UIImage imageWithBundleImage:@"user_stub"];
    
    [HUCachedImageLoader thumbnailFromUserId:user._id completionHandler:^(UIImage *image) {
        if(image)
            usersAvatarImageView.image = image;
    }];
    
    
    [header addSubview:usersAvatarImageView];
    [header addSubview:usersNameLabel];
    
    return header;
}

- (void) loadView {

    [super loadView];
    
    [self addBackButton];
    
        
    _mapView = [self mapView];
    _mapView.delegate=self;
    _mapView.mapType=MKMapTypeStandard;
    [self.view addSubview:_mapView];
    
    
    if (self.shouldSearchForLocation){
        [self getLocation];
    }
    else{
        [self showLocation];
    }
}

-(void)viewWillDissappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - Button Selectors

- (void) onShare {
    [self shareLocationBtnPressed];
}

#pragma mark - Location Services

-(void)getLocation {
    [self.view addSubview:[self getUserHeader]];
    
    self.navigationItem.rightBarButtonItems = [self shareButtonItemsWithSelector:@selector(onShare)];
    
	// Do any additional setup after loading the view.
    [self startStandardUpdates];
    
}

-(void)showLocation{
    [self.view addSubview:[self getUserHeader]];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_message.latitude longitude:_message.longitude];
    
    //Position map
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    MKCoordinateSpan mapSpan= MKCoordinateSpanMake(0.005,0.005);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(mapCenter, mapSpan);
    
    _mapView.region=mapRegion;
    
    
    // Set some coordinates for our position (Buckingham Palace!)
	CLLocationCoordinate2D location2D;
	location2D.latitude = _message.latitude;
	location2D.longitude = _message.longitude;
    
	// Add the annotation to our map view
	MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@",_message.from_user_name]
                                                                       subtitle:[NSString stringWithFormat:@"Last seen %@",[self formatTime]]
                                                                  andCoordinate:location2D];
    
   /* MapViewBubbleAnnotation *newBubble = [[MapViewBubbleAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@",_message.from_user_name]
                                                                       subtitle:[NSString stringWithFormat:@"Last seen %@",[self formatTime]]
                                                                  andCoordinate:location2D];
    */
    //_bubbleAnnotation=newBubble;
	//[_mapView addAnnotation:newAnnotation];
    //[_mapView addAnnotations:[NSArray arrayWithObjects:newBubble, newAnnotation,nil]];
    [_mapView addAnnotation: newAnnotation];

    
}


-(void)shareLocationBtnPressed {
    
    if (self.sendersLocation) {
    
        [self sendLocatioMessage];

    }else {//senders location == nil
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StrManager _:@"No position yet"]
                                                        message:[StrManager _:@"Wait a few minutes until we pinpoint your location."]
                                                       delegate:nil
                                              cancelButtonTitle:[StrManager _:@"OK"]
                                              otherButtonTitles:nil];
        [alert show];
    }

    
}

#pragma mark - Data Handling

- (void) sendLocatioMessage {

	[[AlertViewManager defaultManager] showWaiting:NSLocalizedString(@"Sending", nil)
										   message:nil];
	
    [[DatabaseManager defaultManager] sendLocationMessageOfType:self.targetMode
                                                         toUser:self.targetUser
                                                        toGroup:self.targetGroup
                                                           from:[[UserManager defaultManager] getLoginedUser]
                                                   withLocation:self.sendersLocation
                                                        success:^(BOOL isSuccess,NSString *errStr){
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
																[[AlertViewManager defaultManager] dismiss];
                                                                if(isSuccess == YES){
                                                                    
                                                                    [CSToast showToast:[StrManager _:NSLocalizedString(@"Location sent", nil)] withDuration:3.0];
                                                                    
                                                                    //[self reload];
                                                                    
                                                                    //_tvMessageInput.text = @"";
                                                                    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
                                                                }else {
                                                                    
                                                                    [CSToast showToast:errStr withDuration:3.0];
                                                                    
                                                                }
                                                                
                                                            });
                                                            
                                                            
                                                        } error:^(NSString *errStr){
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [[AlertViewManager defaultManager] dismiss];
                                                            });
                                                            
                                                            
                                                            
                                                            
                                                        }];
}




-(NSString*)formatTime{
    NSTimeInterval _interval=_message.created;
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:_interval];
    return [Utils formatDate:messageDate];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    //_lblLatitude.text=@"Nista";
    //_lblLongitude.text=@"Nista";
    
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
     self.rightButtonItem.enabled =YES;
     //[_lblLatitude setText:[NSString stringWithFormat:@"Latitude %.2f", newLocation.coordinate.latitude]];
     //[_lblLongitude setText:[NSString stringWithFormat:@"Longitude %.2f", newLocation.coordinate.longitude]];
    self.sendersLocation=newLocation;

    //Position map
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    MKCoordinateSpan mapSpan= MKCoordinateSpanMake(0.005,0.005);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(mapCenter, mapSpan);
    
    _mapView.region=mapRegion;
    [_mapView setShowsUserLocation:YES];
   
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
}


#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *parkingAnnotationIdentifier=@"ParkingAnnotationIdentifier";
    
    if([annotation isKindOfClass:[MapViewAnnotation class]]){
        //Try to get an unused annotation, similar to uitableviewcells
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:parkingAnnotationIdentifier];
        //If one isn't available, create a new one
        if(!annotationView){
            annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:parkingAnnotationIdentifier];
            annotationView.draggable=NO;
            annotationView.image=[UIImage imageNamed:@"location_pin.png"];
        }

        annotationView.canShowCallout = NO;
        _locationAnnotationView = annotationView;
        return annotationView;
    }else if( [annotation isKindOfClass:[MapViewBubbleAnnotation class]]){
        //Try to get an unused annotation, similar to uitableviewcells
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:@"BubbleAnnotationIdentifier"];
        //If one isn't available, create a new one
        if(!annotationView){
            //annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BubbleAnnotationIdentifier"];
            annotationView=[[HUMapBubbleView alloc] initWithAnnotation:annotation reuseIdentifier:@"BubbleAnnotationIdentifier"];
            
        }
        
        annotationView.canShowCallout = NO;

        
        return annotationView;
    }
    return nil;
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view  {

    //hide
   //[mapView bringSubviewToFront: _locationAnnotationView];
    if ([view.annotation isKindOfClass:[MapViewAnnotation class]]) {

        [_mapView removeAnnotation:_bubbleAnnotation];
        _bubbleAnnotation = nil;
    }
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    //show
    //[mapView bringSubviewToFront: _locationAnnotationView];
    if ([view.annotation isKindOfClass:[MapViewAnnotation class]] && !_bubbleAnnotation) {
        //[mapView bringSubviewToFront:view];

        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:_message.latitude longitude:_message.longitude];
        
        //Position map
        CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        //MKCoordinateSpan mapSpan= MKCoordinateSpanMake(0.005,0.005);
       // MKCoordinateRegion mapRegion = MKCoordinateRegionMake(mapCenter, mapSpan);
        //MKCoordinateRegion mapRegion = MKCoordinateRegionMake(mapCenter, _mapView.);
        
        //_mapView.region=mapRegion;
        //[_mapView setRegion:mapRegion animated:YES];
        [_mapView setCenterCoordinate:mapCenter animated:YES];
        
        // Set some coordinates for our position (Buckingham Palace!)

        
        CLLocationCoordinate2D location2D;
        location2D.latitude = _message.latitude;
        location2D.longitude = _message.longitude;
        
        MapViewBubbleAnnotation *newBubble = [[MapViewBubbleAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@",_message.from_user_name]
                                                                                   subtitle:[NSString stringWithFormat:@"Last seen %@",[self formatTime]]
                                                                              andCoordinate:location2D];
        
        HUMapBubbleView *annotationView = (HUMapBubbleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"BubbleAnnotationIdentifier"];
        //If one isn't available, create a new one
        if(!annotationView){
            
            annotationView=[[HUMapBubbleView alloc] initWithAnnotation:newBubble reuseIdentifier:@"BubbleAnnotationIdentifier"];
        }
        
        annotationView.canShowCallout = NO;
        _bubbleAnnotation  = newBubble;
        
        [_mapView addAnnotation:newBubble];
                
        //self.isBubbleDisplayed = YES;
        view.userInteractionEnabled = NO;
    }
}


@end