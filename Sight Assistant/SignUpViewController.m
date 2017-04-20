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
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectUserTypeSegment;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)signUp:(id)sender {
    if (!(self.usernameField.text.length > 0) || !(self.passwordField.text.length > 0) || !(self.nameField.text.length > 0) || !(self.confirmPasswordField.text.length > 0)) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Signup Failed"
                                                                       message:@"Please check that all the fields are completed!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if ([self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"users"] child:self.nameField.text];
        NSDictionary *post = @{@"name": self.usernameField.text, @"pass": self.passwordField.text, @"blind": @(self.selectUserTypeSegment.selectedSegmentIndex == 0 ? NO : YES)};
        
        [newref setValue:post];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"Please check if the password you entered in the ''Password'' field is the same with the one from ''Confirm password''"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
