//
//  GetDestMapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 15/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "GetDestMapViewController.h"

@interface GetDestMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation GetDestMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.mapView];
    CLLocationCoordinate2D selectedLocation = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:selectedLocation.latitude longitude:selectedLocation.longitude];
    [[self delegate] setCreatedLocationWIthLatitude:loc];
    
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    
    placemark.coordinate = loc.coordinate;
    
    [self.mapView addAnnotation:placemark];
    [self.mapView selectAnnotation:placemark animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
