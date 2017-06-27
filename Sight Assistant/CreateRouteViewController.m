//
//  CreateRouteViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 12/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "CreateRouteViewController.h"

@interface CreateRouteViewController ()

@property (weak, nonatomic) IBOutlet UITextField *routeName;
@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;

@end

@implementation CreateRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.location = [[CLLocation alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.location) {
        self.latitude.text = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createPressed:(id)sender {
    FIRDatabaseReference *newref = [[[[FIRDatabase database] referenceWithPath:@"routes"] child:[User sharedInstance].currentUserName] child:self.routeName.text];
    NSDictionary *post = @{@"latitude": self.latitude.text, @"longitude": self.longitude.text};
    
    [newref setValue:post];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCreatedLocationWIthLatitude:(CLLocation *)location {
    self.location = location;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createRoute"]) {
        GetDestMapViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

@end
