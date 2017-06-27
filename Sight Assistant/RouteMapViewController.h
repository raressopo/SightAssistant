//
//  RouteMapViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 16/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Route.h"

@interface RouteMapViewController : ViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) Route *route;

@end
