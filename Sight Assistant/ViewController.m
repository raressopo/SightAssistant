//
//  ViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 22/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) FIRDatabaseReference *ref;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ref = [[FIRDatabase database] referenceWithPath:@"users"];
    [[_ref child:@"user1"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        NSLog(@"%@",snapshot.value[@"pass"]);
        
        // ...
    }];
    
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"users"] child:@"user2"];
    NSDictionary *post = @{@"name": @"raalu"};
    [newref setValue:post];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
