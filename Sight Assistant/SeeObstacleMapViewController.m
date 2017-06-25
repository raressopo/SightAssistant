//
//  SeeObstacleMapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 19/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "SeeObstacleMapViewController.h"
#import "CreateObstacleViewController.h"

@interface SeeObstacleMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) double regionCenterLat;
@property (nonatomic) double regionCenterLon;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation SeeObstacleMapViewController

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.menuButton.enabled = !self.showAllObstacles;
    
    if (self.showAllObstacles) {
        [self initView];
        [self addAllPins];
    } else {
        [self showObstacleWithCoord:self.smallObstacle orStartCoord:self.startOfObstacle andEndCord:self.endOfObstacle];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        directionRequest.requestsAlternateRoutes = NO;
        
        // Get directions for the route and put it on the mapview
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
            MKRoute *route = response.routes[0];
            
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        }];
        
    }
}


-(void)initView {
    for (Obstacle *obst in self.obstacles) {
        self.regionCenterLat = self.regionCenterLat + obst.start.coordinate.latitude + obst.end.coordinate.latitude;
        self.regionCenterLon = self.regionCenterLon + obst.start.coordinate.longitude + obst.end.coordinate.longitude;
    }
    
    CLLocation *centerCoord = [[CLLocation alloc] initWithLatitude:self.regionCenterLat/(self.obstacles.count * 2) longitude:self.regionCenterLon/(self.obstacles.count * 2)];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoord.coordinate, 100000, 100000);
    
    [self.mapView setRegion:region animated:NO];
}

-(void)addAllPins {
    for (Obstacle *obst in self.obstacles) {
        MKPointAnnotation *startMapPin = [[MKPointAnnotation alloc] init];
        MKPointAnnotation *endMapPin = [[MKPointAnnotation alloc] init];
        
        double startLatitude = obst.start.coordinate.latitude;
        double startLongitude = obst.start.coordinate.longitude;
        
        double endLatitude = obst.end.coordinate.latitude;
        double endLongitude = obst.end.coordinate.longitude;
        
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
        directionRequest.requestsAlternateRoutes = NO;
        
        // Get directions for the route and put it on the mapview
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
            MKRoute *route = response.routes[0];
            
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        }];
    }
}

- (IBAction)menuPressed:(id)sender {
    [UIView transitionWithView:self.menuView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.menuView.hidden = !self.menuView.hidden;
                    }
                    completion:NULL];
}

- (IBAction)editObstaclePressed:(id)sender {
}

- (IBAction)removeObstaclePressed:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"WARNING!"
                                                                   message:@"Are you sure do you want to remove the obstacle?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"obstacles"] child:self.obstacle.name];
        [[Obstacle sharedInstance].allObstacles removeObject:self.obstacle];
        [newref removeValue];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editObstacle"]) {
        CreateObstacleViewController *destVC = segue.destinationViewController;
        destVC.editableObstacle = self.obstacle;
        destVC.isEditObstacle = YES;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polyLineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    
    polyLineView.strokeColor = [UIColor blueColor];
    polyLineView.lineWidth = 4.0;
    
    return polyLineView;
}

@end
