//
//  MapViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 15/02/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import "Position.h"
#import <MapKit/MapKit.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface MapViewController : ViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic, strong) Position *position;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, assign) BOOL showAllBlindUsers;

@end
