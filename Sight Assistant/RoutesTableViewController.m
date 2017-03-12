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

@interface RoutesTableViewController ()

@property (nonatomic, strong) NSMutableArray *userRoutes;

@end

@implementation RoutesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

@end
