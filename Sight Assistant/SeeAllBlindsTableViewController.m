//
//  SeeAllBlindsTableViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 13/02/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "SeeAllBlindsTableViewController.h"
#import "MapViewController.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface SeeAllBlindsTableViewController ()

@property (nonatomic) NSInteger positionInArray;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) FIRDatabaseReference *ref;

@end

@implementation SeeAllBlindsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [[NSMutableArray alloc] init];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.positionInArray = 0;
    
    self.ref = [[FIRDatabase database] referenceWithPath:@"positions"];
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    NSInteger k = 0;
    for (Position *pos in [Position sharedInstance].positions) {
        if (!pos.rated) {
            k = k + 1;
        }
    }
    return k;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pos" forIndexPath:indexPath];
    
    for (Position *pos in [Position sharedInstance].positions) {
        if (!pos.rated) {
            [self.array addObject:pos];
        }
    }
    Position *auxPos = ((Position *)self.array[indexPath.row]);
    cell.textLabel.text = auxPos.user;
    
    if (auxPos.helped && ![auxPos.helpedBy isEqualToString:[User sharedInstance].currentUserName]) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.positionInArray = indexPath.row;
    [self performSegueWithIdentifier:@"mapViewSegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapViewSegue"]) {
        //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        MapViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.position = self.array[self.positionInArray];
    } else if ([segue.identifier isEqualToString:@"showAllBlindUsers"]) {
        MapViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.showAllBlindUsers = YES;
        destinationVC.positions = [Position sharedInstance].positions;
    }
}


@end
