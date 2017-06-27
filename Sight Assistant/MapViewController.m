//
//  MapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 15/02/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "MapViewController.h"

NSInteger const radius = 10000;

@interface MapViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocation *userPosition;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) double regionCenterLat;
@property (nonatomic) double regionCenterLon;
@property (nonatomic, strong) User *user;
@property (nonatomic) BOOL addPins;
@property (nonatomic) BOOL helped;
@property (nonatomic, strong) Position *pos2;

@property (weak, nonatomic) IBOutlet UISegmentedControl *rateSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *jobDoneButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;

@end

@implementation MapViewController

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate=self;
    self.regionCenterLat = 0.0;
    self.regionCenterLon = 0.0;
    self.acceptButton.hidden = self.showAllBlindUsers;
    self.declineButton.hidden = self.showAllBlindUsers;
    
    self.pos2 = [[Position alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    if (self.showAllBlindUsers) {
        [self initView];
        [self addAllPins];
    } else {
        self.userPosition = [[CLLocation alloc]initWithLatitude:[self.position.lat doubleValue] longitude:[self.position.lon doubleValue]];
        [self centerMapOnLocation:self.userPosition withName:self.position.user];
    }
    
    FIRDatabaseReference *positionsRef = [[FIRDatabase database] referenceWithPath:@"positions"];
    [[positionsRef child:self.position.user] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot.key isEqualToString:@"isHelped"]) {
            self.pos2.helped = [snapshot.value boolValue];
        } else if ([snapshot.key isEqualToString:@"helpedBy"]) {
            self.pos2.helpedBy = snapshot.value;
        } else if ([snapshot.key isEqualToString:@"rated"]) {
            self.pos2.rated = [snapshot.value boolValue];
        } else if ([snapshot.key isEqualToString:@"rating"]) {
            self.pos2.rating = [snapshot.value doubleValue];
        }
    }];
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO];
    
    if (self.addPins) {
        self.addPins = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (Position *pos in [Position sharedInstance].positions) {
        if ([pos.user isEqualToString:self.position.user]) {
            Position *auxPos = [[Position alloc] init];
            auxPos = pos;
            [[Position sharedInstance].positions removeObject:pos];
            auxPos.helpedBy = self.pos2.helpedBy;
            auxPos.helped = self.pos2.helped;
            auxPos.rating = self.pos2.rating;
            auxPos.rated = self.pos2.rated;
            [[Position sharedInstance].positions addObject:auxPos];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper methods

- (void)centerMapOnLocation:(CLLocation *)location withName:(NSString *)userName {
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    
    placemark.coordinate = location.coordinate;
    placemark.title = userName;
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:placemark];
    [self.mapView selectAnnotation:placemark animated:YES];
}

-(void)initView {
    for (Position *pos in self.positions) {
        self.regionCenterLat = self.regionCenterLat + [pos.lat doubleValue];
        self.regionCenterLon = self.regionCenterLon + [pos.lon doubleValue];
    }
    
    CLLocation *centerCoord = [[CLLocation alloc] initWithLatitude:self.regionCenterLat/self.positions.count longitude:self.regionCenterLon/self.positions.count];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoord.coordinate, radius, radius);
    
    [self.mapView setRegion:region animated:NO];
}

-(void)addAllPins {
    self.addPins = YES;
    
    for (Position *position in self.positions) {
        MKPointAnnotation *mapPin = [[MKPointAnnotation alloc] init];
        
        double latitude = [position.lat doubleValue];
        double longitude = [position.lon doubleValue];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        mapPin.title = position.user;
        mapPin.subtitle = [NSString stringWithFormat:@"%@", @(position.helped)];
        mapPin.coordinate = coordinate;
        
        [self.mapView addAnnotation:mapPin];
    }
}

#pragma mark - User interaction methods

- (IBAction)acceptPressed:(id)sender {
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"positions"] child:self.position.user];
    NSDictionary *post = @{@"helpedBy": [User sharedInstance].currentUserName, @"isHelped": @(YES)};
    
    [newref updateChildValues:post];
    
    self.acceptButton.enabled = NO;
    
    // TODO: remove this on real device
    // Position hardcoded to see that the route is created correctly
    MKPointAnnotation *plmrk2 = [[MKPointAnnotation alloc] init];
    plmrk2.coordinate = CLLocationCoordinate2DMake(46.735000, 23.518300);
    plmrk2.title = @"Me";
    [self.mapView addAnnotation:plmrk2];
    [self.mapView selectAnnotation:plmrk2 animated:YES];
    
    // Create 2 placemarks, one for the blind user and one for helper
    MKPlacemark *p1 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.position.lat doubleValue], [self.position.lon doubleValue]) addressDictionary:nil];
    //[p1 setCoordinate:CLLocationCoordinate2DMake([self.position.lat doubleValue], [self.position.lon doubleValue])];
                       //initWithCoordinate:CLLocationCoordinate2DMake([self.position.lat doubleValue], [self.position.lon doubleValue])];
    MKPlacemark *p2 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude) addressDictionary:nil];
    
    // Create 2 mapitems from that 2 placemarks
    MKMapItem *mi1 = [[MKMapItem alloc] initWithPlacemark:p1];
    MKMapItem *mi2 = [[MKMapItem alloc] initWithPlacemark:p2];
    
    // Create directionRequest to set the destination and the source
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    directionRequest.source = mi2;
    directionRequest.destination = mi1;
    directionRequest.transportType = MKDirectionsTransportTypeAny;
    directionRequest.requestsAlternateRoutes = YES;
    
    // Get directions for the route and put it on the mapview
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        MKRoute *route = response.routes[0];
        if (route) {
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        }
    }];
}

- (IBAction)declinePressed:(id)sender {
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"positions"] child:self.position.user];
    NSDictionary *post = @{@"isHelped": @(NO)};
    
    [newref updateChildValues:post];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)jobDonePressed:(id)sender {
    [UIView transitionWithView:self.ratingView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.ratingView.hidden = NO;
                        self.alphaView.hidden = NO;
                    }
                    completion:NULL];
    
}

- (IBAction)sendRatingPressed:(id)sender {
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"positions"] child:self.position.user];
    NSDictionary *post = @{@"rating": @(self.rateSegmentedControl.selectedSegmentIndex + 1), @"rated": @(YES)};
    
    FIRDatabaseReference *newref2 = [[[FIRDatabase database] referenceWithPath:@"users"] child:self.position.user];
    NSDictionary *post2 = @{@"rating": @((self.rateSegmentedControl.selectedSegmentIndex + 1 + [User sharedInstance].currentUserRate) / 2)};
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:@"Please wait and please do not close the app!\n\n\n"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(130.5, 95.5);
    spinner.color = [UIColor blackColor];
    [spinner startAnimating];
    [alert.view addSubview:spinner];
    
    [newref updateChildValues:post withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        [newref2 updateChildValues:post2 withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            [self presentViewController:alert animated:YES completion:nil];
            [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [alert dismissViewControllerAnimated:YES completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }];
    }];
}

#pragma mark - Location Manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = [locations lastObject];
    MKPointAnnotation *plmrk = [[MKPointAnnotation alloc] init];
    
    plmrk.coordinate = self.currentLocation.coordinate;
    plmrk.title = @"Me";
    
    [self.mapView addAnnotation:plmrk];
    [self.mapView selectAnnotation:plmrk animated:YES];
}

#pragma mark - MapKit delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];

    if (self.addPins) {
        if ([((MKPointAnnotation *)annotation).subtitle isEqualToString:@"0"]) {
            pin.pinTintColor = [UIColor redColor];
            return pin;
        } else if ([((MKPointAnnotation *)annotation).subtitle isEqualToString:@"1"]) {
            pin.pinTintColor = [UIColor greenColor];
            return pin;
        }
    }
    
    if ([((MKPointAnnotation *)annotation).title isEqualToString:self.position.user]) {
        if (!self.position.helped) {
            pin.pinTintColor = [UIColor redColor];
            return pin;
        } else if (self.position.helped) {
            pin.pinTintColor = [UIColor greenColor];
            return pin;
        }
    }
    
    if ([((MKPointAnnotation *)annotation).title isEqualToString:@"Me"]) {
        pin.pinTintColor = [UIColor blueColor];
        return pin;
    }
    
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polyLineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polyLineView.strokeColor = [UIColor redColor];
    polyLineView.lineWidth = 4.0;
    
    return polyLineView;
}

@end
