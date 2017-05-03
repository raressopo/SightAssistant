//
//  HelperSelectionViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "HelperSelectionViewController.h"

@interface HelperSelectionViewController ()

@property (nonatomic) BOOL firstVCAppear;

@end

@implementation HelperSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstVCAppear = NO;
    FIRDatabaseReference *isHelpedRef = [[FIRDatabase database] referenceWithPath:@"positions"];
    [isHelpedRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (self.firstVCAppear && [[User sharedInstance].currentUserType isEqualToString:@"helper"]) {
            [self notifyForHelpingUser:snapshot.key];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.firstVCAppear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button actions

- (IBAction)signOut:(id)sender {
    [User sharedInstance].currentUserName = @"";
    [User sharedInstance].currentUserRate = 0;
    [User sharedInstance].currentUserType = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Local notifications

- (void)notifyForHelpingUser:(NSString *)user {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [NSString stringWithFormat:@"%@ needs help", user];
    // TODO: Add the reason of the user that declined to offer help
    content.body = [NSString stringWithFormat:@"Please accept or decline to offer help to: %@", user];
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

#pragma mark - User Notifications Delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
}

@end
