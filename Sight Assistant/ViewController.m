//
//  ViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 22/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *pass;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSDictionary *usersFromDB;
@property (nonatomic, strong) NSDictionary *positionFromDB;

@property (nonatomic) BOOL observeSingleEvent;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.users = [[NSMutableArray alloc] init];
    self.ref = [[FIRDatabase database] reference];
    
    // Get all the users from DB
    [User sharedInstance].users = [[NSMutableArray alloc] init];
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.usersFromDB = snapshot.value[@"users"];
        
        for (NSString *userFromDB in self.usersFromDB.allKeys) {
            NSDictionary *user = [self.usersFromDB objectForKey:userFromDB];
            User *userFromDict = [[User alloc] initWithName:userFromDB withUserName:[user objectForKey:@"name"] withPass:[user objectForKey:@"pass"] isBlind:[[user objectForKey:@"blind"] boolValue] isHelped:[[user objectForKey:@"isHelped"] boolValue]];
            
            [[User sharedInstance].users addObject:userFromDict];
        }
    }];
}

#pragma mark - Button actions

- (IBAction)login:(id)sender {
    for (User *user in [User sharedInstance].users) {
        if ([self.username.text isEqualToString:user.userName] && [self.pass.text isEqualToString:user.password] && user.blind) {
            [User sharedInstance].currentUserName = user.name;
            [self performSegueWithIdentifier:@"blind" sender:sender];
            return;
        } else if ([self.username.text isEqualToString:user.userName] && [self.pass.text isEqualToString:user.password] && !user.blind) {
            [User sharedInstance].currentUserName = user.name;
            [self performSegueWithIdentifier:@"helper" sender:sender];
            return;
        }
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
