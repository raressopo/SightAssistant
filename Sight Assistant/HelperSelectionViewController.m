//
//  HelperSelectionViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "HelperSelectionViewController.h"

@interface HelperSelectionViewController ()

@end

@implementation HelperSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button actions

- (IBAction)signOut:(id)sender {
    [User sharedInstance].currentUserName = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
