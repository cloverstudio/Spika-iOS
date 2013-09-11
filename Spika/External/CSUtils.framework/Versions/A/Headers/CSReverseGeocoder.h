//
//  CSReverseGeocoder.h
//  CSReverseGeocoder
//
//  Created by Luka Fajl on 4.5.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class CSReverseGeocoder;

typedef void (^ReverseGeocoderBlock)(CSReverseGeocoder *geocoder, MKPlacemark *placemark, NSError *error);

typedef NS_ENUM (NSInteger, CSReverseGeocoderPlacemarkValue) {

    CSReverseGeocoderPlacemarkValueCity = 0,        // eg. City of Zagreb
    CSReverseGeocoderPlacemarkValueCountry,         // eg. Croatia
    CSReverseGeocoderPlacemarkValueISOCountryCode,  // The value is an ISO country code, eg. HR
    CSReverseGeocoderPlacemarkValueAddress,         // Formatted string that contains the full address. The string is likely to contain line endings.
    CSReverseGeocoderPlacemarkValueName,            // eg. Apple Inc. If there is no Name, will return Street
    CSReverseGeocoderPlacemarkValueState,           // eg. New York. If there is no state will return City
    CSReverseGeocoderPlacemarkValueStreet,          // eg. 1 Infinite Loop
    CSReverseGeocoderPlacemarkValueSubLocality,     // neighborhood, common name, eg. Mission District, or Gornji Grad - Medveščak
    CSReverseGeocoderPlacemarkValueThoroughfare,    // street address, eg. 1 Infinite Loop
    CSReverseGeocoderPlacemarkValuePostalCode       // ZIP code, eg. 10000
};

@protocol CSReverseGeocoderDelegate <NSObject> 
@required
-(void) geocoder:(CSReverseGeocoder*)geocoder
didFindPlacemark:(MKPlacemark*)placemark;

-(void) geocoder:(CSReverseGeocoder*)geocoder
didFailWithError:(NSError*)error;

@end

@class CSMapLocation;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0

NS_CLASS_AVAILABLE_IOS(4_0)
@interface CSReverseGeocoder : NSObject <MKReverseGeocoderDelegate>

#else

NS_CLASS_AVAILABLE_IOS(4_0)
@interface CSReverseGeocoder : NSObject

#endif


@property (nonatomic, assign) id<CSReverseGeocoderDelegate> delegate; // Delegate that can be called when geocoding is finished.
@property (nonatomic, readwrite) NSInteger tag; // Tag property for identifying geocoders.

#pragma mark - Geocode Actions
/**
 Geocode given location. Common method when using delegates.
 
 @param location A location that needs to be geocoded.
 */
- (void) geocodeLocation:(CLLocation *)location;

/**
 Geocode given location. Common method when using blocks.
 
 @param location A location that needs to be geocoded.
 @param callbackBlock A block object to be called when reverse geocoder finishes with geocoding location. This block has no return value and takes three arguments: the geocoder object that made geocoding, a placemark object that contains data for given location, the error that occured during the geocoding.
 */
- (void) geocodeLocation:(CLLocation *)location
       withCallbackBlock:(ReverseGeocoderBlock)callbackBlock;

#pragma mark - Placemark Values

/**
 Query placemark for human readable result.
 
 @param value A reverse geocoder value is a query.
 @param placemark A placemark that needs to be queried.
 */
- (NSString *) valueType:(CSReverseGeocoderPlacemarkValue)value
            forPlacemark:(MKPlacemark *)placemark;

@end
