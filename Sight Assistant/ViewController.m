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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Read from database
    self.users = [[NSMutableArray alloc] init];
    self.ref = [[FIRDatabase database] reference];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.usersFromDB = snapshot.value[@"users"];
        for (NSString *userr in self.usersFromDB.allKeys) {
            NSDictionary *user = [self.usersFromDB objectForKey:userr];
            User *userFromDict = [[User alloc] initWithName:userr withUserName:[user objectForKey:@"name"] withPass:[user objectForKey:@"pass"] isBlind:[[user objectForKey:@"blind"] boolValue]];
            [self.users addObject:userFromDict];
        }
    }];
    
    [Position sharedInstance].positions = [[NSMutableArray alloc] init];
    self.ref = [[FIRDatabase database] reference];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.positionFromDB = snapshot.value[@"positions"];
        for (NSString *pos in self.positionFromDB.allKeys) {
            NSDictionary *position = [self.positionFromDB objectForKey:pos];
            Position *posFromDB = [[Position alloc] initWithUser:pos latitude:[position objectForKey:@"latitude"] andLongitude:[position objectForKey:@"longitude"]];
            [[Position sharedInstance].positions addObject:posFromDB];
        }
    }];
}

- (IBAction)login:(id)sender {
    for (User *user in self.users) {
        if ([self.username.text isEqualToString:user.userName] && [self.pass.text isEqualToString:user.password] && user.blind) {
            [User sharedInstance].currentUserName = user.name;
            [self performSegueWithIdentifier:@"blind" sender:sender];
            return;
        } else if ([self.username.text isEqualToString:user.userName] && [self.pass.text isEqualToString:user.password] && !user.blind) {
            [User sharedInstance].currentUserName = user.name;
            [self performSegueWithIdentifier:@"helper" sender:sender];
            return;
        }
//        else {
//            [self wrongUsernameOrPass];
//        }
    }
}

//- (void)wrongUsernameOrPass {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Username/Password Incorrect!"
//                                                                   message:@"Please check if your username or password is enetered corectly."
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//    }];
//    [alert addAction:okAction];
//    [self presentViewController:alert animated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
