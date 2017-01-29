//
//  SignUpViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 29/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *selectUserTypeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)userType:(id)sender {
    if (self.selectUserTypeSwitch.on) {
        self.userTypeLabel.text = @"Helper";
    } else {
        self.userTypeLabel.text = @"Helped";
    }
    [self.userTypeLabel sizeToFit];
}

- (IBAction)signUp:(id)sender {
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"users"] child:self.nameField.text];
    NSDictionary *post = @{@"name": self.usernameField.text, @"pass": self.passwordField.text, @"blind": @([self switchResult])};
    [newref setValue:post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)switchResult {
    if (self.selectUserTypeSwitch.on) {
        return NO;
    } else {
        return YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
