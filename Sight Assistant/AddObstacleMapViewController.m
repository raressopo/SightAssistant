//
//  AddObstacleMapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 19/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "AddObstacleMapViewController.h"

@interface AddObstacleMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AddObstacleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showObstacleWithCoord:self.obstacle orStartCoord:self.startOfObstacle andEndCord:self.endOfObstacle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.isSmallObstacle = NO;
    self.isStartOfTheObstacle = NO;
    self.isEndOfTheObstacle = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isSmallObstacle || self.isStartOfTheObstacle || self.isEndOfTheObstacle) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        CGPoint point = [[touches anyObject] locationInView:self.mapView];
        CLLocationCoordinate2D selectedLocation = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:selectedLocation.latitude longitude:selectedLocation.longitude];
        
        if (self.isSmallObstacle) {
            [[self delegate] setCreatedLocationWIthLatitude:loc withType:@"small"];
        } else if (self.isStartOfTheObstacle) {
            [[self delegate] setCreatedLocationWIthLatitude:loc withType:@"start"];
        } else if (self.isEndOfTheObstacle) {
            [[self delegate] setCreatedLocationWIthLatitude:loc withType:@"end"];
        }
        
        MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
        
        placemark.coordinate = loc.coordinate;
        
        [self.mapView addAnnotation:placemark];
        [self.mapView selectAnnotation:placemark animated:YES];
    }
}

- (void)showObstacleWithCoord:(CLLocation *)obstLocation orStartCoord:(CLLocation *)startObstLocation andEndCord:(CLLocation *)endObstLocation {
    if (obstLocation) {
        MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(obstLocation.coordinate, 1000, 1000);
        
        placemark.coordinate = obstLocation.coordinate;
        
        [self.mapView setRegion:region];
        [self.mapView addAnnotation:placemark];
        [self.mapView selectAnnotation:placemark animated:YES];
    } else if (startObstLocation && endObstLocation) {
        MKPointAnnotation *startMapPin = [[MKPointAnnotation alloc] init];
        MKPointAnnotation *endMapPin = [[MKPointAnnotation alloc] init];
        
        double startLatitude = startObstLocation.coordinate.latitude;
        double startLongitude =startObstLocation.coordinate.longitude;
        
        double endLatitude = endObstLocation.coordinate.latitude;
        double endLongitude = endObstLocation.coordinate.longitude;
        
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(startLatitude, startLongitude);
        CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake(endLatitude, endLongitude);
        
        startMapPin.coordinate = startCoordinate;
        endMapPin.coordinate = endCoordinate;
        
        [self.mapView addAnnotation:startMapPin];
        [self.mapView addAnnotation:endMapPin];
        
        // Create 2 placemarks, one for the blind user and one for helper
        MKPlacemark *p1 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(startLatitude, startLongitude) addressDictionary:nil];
        MKPlacemark *p2 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(endLatitude, endLongitude) addressDictionary:nil];
        
        // Create 2 mapitems from that 2 placemarks
        MKMapItem *mi1 = [[MKMapItem alloc] initWithPlacemark:p1];
        MKMapItem *mi2 = [[MKMapItem alloc] initWithPlacemark:p2];
        
        // Create directionRequest to set the destination and the source
        MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
        
        directionRequest.source = mi2;
        directionRequest.destination = mi1;
        directionRequest.transportType = MKDirectionsTransportTypeWalking;
        directionRequest.requestsAlternateRoutes = YES;
        
        // Get directions for the route and put it on the mapview
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
            MKRoute *route = response.routes[0];
            
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        }];

    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polyLineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    
    polyLineView.strokeColor = [UIColor blueColor];
    polyLineView.lineWidth = 4.0;
    
    return polyLineView;
}

@end
