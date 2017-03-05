//
//  BlindSelectionViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "BlindSelectionViewController.h"
#import "User.h"

@interface BlindSelectionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *lat;
@property (weak, nonatomic) IBOutlet UITextField *longit;

@end

@implementation BlindSelectionViewController {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)getLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    self.lat.text = [NSString stringWithFormat:@"%.8f", locationManager.location.coordinate.latitude];
    self.longit.text = [NSString stringWithFormat:@"%.8f", locationManager.location.coordinate.longitude];
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"positions"] child:[User sharedInstance].currentUserName];
    NSDictionary *post = @{@"latitude": self.lat.text, @"longitude": self.longit.text, @"isHelped": @(NO)};
    [newref setValue:post];

}

- (IBAction)signOut:(id)sender {
    [User sharedInstance].currentUserName = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
