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
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSDictionary *users;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Read from database
    self.ref = [[FIRDatabase database] reference];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.users = snapshot.value[@"users"];
    }];
    
    // Write in database
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"users"] child:@"user2"];
    NSDictionary *post = @{@"name": @"raalu", @"pass": @"lolo"};
    [newref setValue:post];
}

- (IBAction)login:(id)sender {
    for (NSString *user in self.users.allKeys) {
        NSDictionary *userDict = [self.users objectForKey:user];
        if ([self.username.text isEqualToString:[userDict objectForKey:@"name"]] && [self.pass.text isEqualToString:[userDict objectForKey:@"pass"]]) {
            self.label.text = @"All good";
            return;
        } else {
            self.label.text = @"Nope";
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
