//
//  AllObstaclesTableViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 19/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "AllObstaclesTableViewController.h"
#import "Obstacle.h"
#import "SeeObstacleMapViewController.h"

@interface AllObstaclesTableViewController ()

@property (nonatomic, strong) CLLocation *startOfObstacle;
@property (nonatomic, strong) CLLocation *endOfObstacle;
@property (nonatomic, strong) CLLocation *smallObstacle;

@property (nonatomic, strong) Obstacle *obstacle;

@end

@implementation AllObstaclesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Obstacle sharedInstance].allObstacles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"obstacleCell" forIndexPath:indexPath];
    
    cell.textLabel.text = ((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.obstacle = [Obstacle sharedInstance].allObstacles[indexPath.row];
    if (((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == SmallObstacle || ((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == ShortObstacle) {
        self.smallObstacle = [[CLLocation alloc] initWithLatitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.latitude longitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.longitude];
    } else if (((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == BigObstacle || ((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == LongObstacle) {
        self.startOfObstacle = [[CLLocation alloc] initWithLatitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.latitude longitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.longitude];
        self.endOfObstacle = [[CLLocation alloc] initWithLatitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).end.coordinate.latitude longitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).end.coordinate.longitude];
    }
    
    [self performSegueWithIdentifier:@"seeOneObstacle" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SeeObstacleMapViewController *destinationVC = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"seeAllObst"]) {
        destinationVC.showAllObstacles = YES;
        destinationVC.obstacles = [Obstacle sharedInstance].allObstacles;
    } else if ([segue.identifier isEqualToString:@"seeOneObstacle"]) {
        destinationVC.obstacle = self.obstacle;
        if (self.smallObstacle) {
            destinationVC.smallObstacle = self.smallObstacle;
        } else if (self.startOfObstacle && self.endOfObstacle) {
            destinationVC.startOfObstacle = self.startOfObstacle;
            destinationVC.endOfObstacle = self.endOfObstacle;
        }
    }
}

@end
