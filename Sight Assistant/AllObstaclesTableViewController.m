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

@end

@implementation AllObstaclesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == SmallObstacle || ((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == ShortObstacle) {
        self.smallObstacle = [[CLLocation alloc] initWithLatitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.latitude longitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.longitude];
        [self performSegueWithIdentifier:@"seeOneObstacle" sender:self];
    } else if (((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == BigObstacle || ((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).size == LongObstacle) {
        self.startOfObstacle = [[CLLocation alloc] initWithLatitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.latitude longitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).start.coordinate.longitude];
        self.endOfObstacle = [[CLLocation alloc] initWithLatitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).end.coordinate.latitude longitude:((Obstacle *)[Obstacle sharedInstance].allObstacles[indexPath.row]).end.coordinate.longitude];
        [self performSegueWithIdentifier:@"seeOneObstacle" sender:self];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SeeObstacleMapViewController *destinationVC = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"seeAllObst"]) {
        destinationVC.showAllObstacles = YES;
        destinationVC.obstacles = [Obstacle sharedInstance].allObstacles;
    } else if ([segue.identifier isEqualToString:@"seeOneObstacle"]) {
        if (self.smallObstacle) {
            destinationVC.smallObstacle = self.smallObstacle;
        } else if (self.startOfObstacle && self.endOfObstacle) {
            destinationVC.startOfObstacle = self.startOfObstacle;
            destinationVC.endOfObstacle = self.endOfObstacle;
        }
    }
}

@end
