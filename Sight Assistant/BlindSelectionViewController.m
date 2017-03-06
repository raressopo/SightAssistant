//
//  BlindSelectionViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "BlindSelectionViewController.h"
#import "User.h"

@interface BlindSelectionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *lat;
@property (weak, nonatomic) IBOutlet UITextField *longit;

@property (nonatomic) BOOL viewWillAppearCheck;

@end

@implementation BlindSelectionViewController {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewWillAppearCheck = NO;
    FIRDatabaseReference *isHelpedRef = [[[[FIRDatabase database] referenceWithPath:@"positions"] child:[User sharedInstance].currentUserName] child:@"isHelped"];
    [isHelpedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (self.viewWillAppearCheck) {
            if ([snapshot.value isEqual:@(YES)]) {
                [self helperAcceptNotification];
            } else {
                [self helperDeclineNotification];
            }
        }
    }];
    
    locationManager = [[CLLocationManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewWillAppearCheck = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper methods

- (void)helperDeclineNotification {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Help declined";
    // TODO: Add the reason of the user that declined to offer help
    content.body = @"The user that accepted to offer help declined it for unknown reason";
    content.sound = [UNNotificationSound defaultSound];
    
    //UNNotificationAction *snoozeAction = [UNNotificationAction actionWithIdentifier:@"Snooze"
    //                                                                          title:@"Snooze" options:UNNotificationActionOptionNone];
    //UNNotificationAction *deleteAction = [UNNotificationAction actionWithIdentifier:@"Delete"
    //                                                                          title:@"Delete" options:UNNotificationActionOptionDestructive];
    //
    //UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"UYLReminderCategory"
    //                                                                          actions:@[snoozeAction,deleteAction] intentIdentifiers:@[]
    //                                                                          options:UNNotificationCategoryOptionNone];
    //NSSet *categories = [NSSet setWithObject:category];
    //content.categoryIdentifier = @"UYLReminderCategory";
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                    repeats:NO];
    
    NSString *identifier = @"UYLLocalNotification";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:trigger];
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    // [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}

- (void)helperAcceptNotification {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Help accepted";
    // TODO: Add the name of the user that offered help
    content.body = @"User accepted to offer help";
    content.sound = [UNNotificationSound defaultSound];
    
    //UNNotificationAction *snoozeAction = [UNNotificationAction actionWithIdentifier:@"Snooze"
    //                                                                          title:@"Snooze" options:UNNotificationActionOptionNone];
    //UNNotificationAction *deleteAction = [UNNotificationAction actionWithIdentifier:@"Delete"
    //                                                                          title:@"Delete" options:UNNotificationActionOptionDestructive];
    //
    //UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"UYLReminderCategory"
    //                                                                          actions:@[snoozeAction,deleteAction] intentIdentifiers:@[]
    //                                                                          options:UNNotificationCategoryOptionNone];
    //NSSet *categories = [NSSet setWithObject:category];
    //content.categoryIdentifier = @"UYLReminderCategory";
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                    repeats:NO];
    
    NSString *identifier = @"UYLLocalNotification";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:trigger];
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    // [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}


#pragma mark - User Interaction methods

- (IBAction)getLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    self.lat.text = [NSString stringWithFormat:@"%.8f", locationManager.location.coordinate.latitude];
    self.longit.text = [NSString stringWithFormat:@"%.8f", locationManager.location.coordinate.longitude];
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"positions"] child:[User sharedInstance].currentUserName];
    NSDictionary *post = @{@"latitude": self.lat.text, @"longitude": self.longit.text, @"isHelped": @(NO)};
    [newref setValue:post];

}

- (IBAction)signOut:(id)sender {
    [User sharedInstance].currentUserName = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - User Notifications Delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
}

@end
