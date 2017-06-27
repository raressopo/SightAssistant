//
//  RouteMapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 16/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "RouteMapViewController.h"
#import "Obstacle.h"

@interface RouteMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *routeDestination;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation RouteMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate=self;
    
    self.currentLocation = [[CLLocation alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
    
    self.routeDestination = [[CLLocation alloc] initWithLatitude:[self.route.lat doubleValue] longitude:[self.route.lon doubleValue]];
    [self centerMapOnLocation:self.routeDestination];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centerMapOnLocation:(CLLocation *)location {
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000 * 2.0, 1000 * 2.0);
    
    placemark.coordinate = location.coordinate;
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:placemark];
    [self.mapView selectAnnotation:placemark animated:YES];
    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:47.197573 longitude:23.047726];
    MKPointAnnotation *plmrk = [[MKPointAnnotation alloc] init];
    
    plmrk.coordinate = self.currentLocation.coordinate;
    
    [self.mapView addAnnotation:plmrk];
    [self.mapView selectAnnotation:plmrk animated:YES];
    
    MKPlacemark *p1 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.routeDestination.coordinate.latitude, self.routeDestination.coordinate.longitude) addressDictionary:nil];
    MKPlacemark *p2 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude) addressDictionary:nil];
    
    // Create 2 mapitems from that 2 placemarks
    MKMapItem *mi1 = [[MKMapItem alloc] initWithPlacemark:p1];
    MKMapItem *mi2 = [[MKMapItem alloc] initWithPlacemark:p2];
    
    // Create directionRequest to set the destination and the source
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    directionRequest.source = mi1;
    directionRequest.destination = mi2;
    directionRequest.transportType = MKDirectionsTransportTypeAny;
    directionRequest.requestsAlternateRoutes = YES;
    
    // Get directions for the route and put it on the mapview
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        MKRoute *route = response.routes[0];
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        NSUInteger pointCount = route.polyline.pointCount;
        
        //allocate a C array to hold this many points/coordinates...
        CLLocationCoordinate2D *routeCoordinates
        = malloc(pointCount * sizeof(CLLocationCoordinate2D));
        
        //get the coordinates (all of them)...
        [route.polyline getCoordinates:routeCoordinates
                                 range:NSMakeRange(0, pointCount)];
        
        //this part just shows how to use the results...
        NSLog(@"route pointCount = %lu", (unsigned long)pointCount);
        for (int c=0; c < pointCount; c++)
        {
            NSLog(@"routeCoordinates[%d] = %.10f, %.10f",
                  c, routeCoordinates[c].latitude, routeCoordinates[c].longitude);
            for (Obstacle *obstacle in [Obstacle sharedInstance].allObstacles) {
                if (obstacle.size == LongObstacle || obstacle.size == BigObstacle) {
                    
                }
                double latDif = fabs(routeCoordinates[c].latitude - obstacle.start.coordinate.latitude);
                double lonDif = fabs(routeCoordinates[c].longitude - obstacle.start.coordinate.longitude);
                
                NSLog(@"%.10f, %.10f", latDif, lonDif);
            }
        }
        
        //free the memory used by the C array when done with it...
        free(routeCoordinates);
    }];
}

#pragma mark - Location Manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = [locations lastObject];
    MKPointAnnotation *plmrk = [[MKPointAnnotation alloc] init];
    
    plmrk.coordinate = self.currentLocation.coordinate;
    
    [self.mapView addAnnotation:plmrk];
    [self.mapView selectAnnotation:plmrk animated:YES];
    
    MKPlacemark *p1 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.routeDestination.coordinate.latitude, self.routeDestination.coordinate.longitude) addressDictionary:nil];
    MKPlacemark *p2 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude) addressDictionary:nil];
    
    // Create 2 mapitems from that 2 placemarks
    MKMapItem *mi1 = [[MKMapItem alloc] initWithPlacemark:p1];
    MKMapItem *mi2 = [[MKMapItem alloc] initWithPlacemark:p2];
    
    // Create directionRequest to set the destination and the source
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    directionRequest.source = mi1;
    directionRequest.destination = mi2;
    directionRequest.transportType = MKDirectionsTransportTypeWalking;
    directionRequest.requestsAlternateRoutes = NO;
    
    // Get directions for the route and put it on the mapview
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        MKRoute *route = response.routes[0];
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        NSUInteger pointCount = route.polyline.pointCount;
        
        //allocate a C array to hold this many points/coordinates...
        CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
        
        //get the coordinates (all of them)...
        [route.polyline getCoordinates:routeCoordinates
                                 range:NSMakeRange(0, pointCount)];
        
        //this part just shows how to use the results...
        NSLog(@"route pointCount = %lu", (unsigned long)pointCount);
        for (int c=0; c < pointCount; c++) {
            NSLog(@"routeCoordinates[%d] = %.10f, %.10f", c, routeCoordinates[c].latitude, routeCoordinates[c].longitude);
            for (Obstacle *obstacle in [Obstacle sharedInstance].allObstacles) {
                if (obstacle.size == LongObstacle || obstacle.size == BigObstacle) {
                    
                }
                NSUInteger latDif = routeCoordinates[c].latitude - obstacle.start.coordinate.latitude;
                NSUInteger lonDif = routeCoordinates[c].longitude - obstacle.start.coordinate.longitude;
                
                NSLog(@"%lu, %lu", (unsigned long)latDif, (unsigned long)lonDif);
            }
        }
        
        //free the memory used by the C array when done with it...
        free(routeCoordinates);
    }];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polyLineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polyLineView.strokeColor = [UIColor redColor];
    polyLineView.lineWidth = 4.0;
    
    return polyLineView;
}

@end
