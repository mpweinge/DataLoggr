//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"

@protocol DLLocationTrackerDelegate

@required
-(void) DidGetLocation:(CLLocationCoordinate2D) location;
@end

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (nonatomic, readwrite) id <DLLocationTrackerDelegate> delegate;

@property (strong,nonatomic) NSString * accountStatus;
@property (strong,nonatomic) NSString * authKey;
@property (strong,nonatomic) NSString * device;
@property (strong,nonatomic) NSString * name;
@property (strong,nonatomic) NSString * profilePicURL;
@property (strong,nonatomic) NSNumber * userid;

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;


@end
