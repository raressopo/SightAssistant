//
//  SeeAllBlindsTableViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 13/02/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "SeeAllBlindsTableViewController.h"
#import "MapViewController.h"

@interface SeeAllBlindsTableViewController ()

@property (nonatomic) NSInteger currentRowSelected;

@end

@implementation SeeAllBlindsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentRowSelected = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Position sharedInstance].positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pos" forIndexPath:indexPath];
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    
    for (Position *pos in [Position sharedInstance].positions) {
        [namesArray addObject:pos.user];
    }
    cell.textLabel.text = namesArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentRowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"mapViewSegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapViewSegue"]) {
        //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        MapViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.position = [Position sharedInstance].positions[self.currentRowSelected];
    } else if ([segue.identifier isEqualToString:@"showAllBlindUsers"]) {
        MapViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.showAllBlindUsers = YES;
        destinationVC.positions = [Position sharedInstance].positions;
    }
}


@end
