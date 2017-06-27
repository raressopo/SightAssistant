//
//  RoutesTableViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 08/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "RoutesTableViewController.h"
#import "UserRoutes.h"
#import "User.h"
#import "RouteMapViewController.h"

@interface RoutesTableViewController ()

@property (nonatomic, strong) NSMutableArray *userRoutes;
@property (nonatomic) NSInteger currentRowSelected;

@end

@implementation RoutesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentRowSelected = 0;
    self.userRoutes = [[NSMutableArray alloc] init];
    
    for (UserRoutes *user in [UserRoutes sharedInstance].routesOfAllUsers) {
        if ([user.user isEqualToString:[User sharedInstance].currentUserName]) {
            self.userRoutes = user.allRoutes;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userRoutes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"route" forIndexPath:indexPath];
    
    cell.textLabel.text = ((Route *)self.userRoutes[indexPath.row]).destinationName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentRowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"route" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"route"]) {
        RouteMapViewController *destinationVC = segue.destinationViewController;
        destinationVC.route = self.userRoutes[self.currentRowSelected];
    }
}

@end
