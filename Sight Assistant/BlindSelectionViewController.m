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
@property (weak, nonatomic) IBOutlet UIButton *sendVocalCommandButton;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;

@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

@property (nonatomic) BOOL viewWillAppearCheck;

@end

@implementation BlindSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.speechRecognizer = [[SFSpeechRecognizer alloc] init];
    
    self.speechRecognizer.delegate = self;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                self.sendVocalCommandButton.enabled = YES;
                break;
            
            case SFSpeechRecognizerAuthorizationStatusDenied:
                self.sendVocalCommandButton.enabled = NO;
                break;
                
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                self.sendVocalCommandButton.enabled = NO;
                break;
                
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                self.sendVocalCommandButton.enabled = NO;
                break;
                
            default:
                break;
        }
    }];

    self.currentLocation = [[CLLocation alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
    
    self.viewWillAppearCheck = NO;
    FIRDatabaseReference *isHelpedRef = [[[FIRDatabase database] referenceWithPath:@"positions"] child:[User sharedInstance].currentUserName];
    [isHelpedRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (self.viewWillAppearCheck && [snapshot.key isEqualToString:@"isHelped"] && [[User sharedInstance].currentUserType isEqualToString:@"blind"]) {
            if ([snapshot.value isEqual:@(YES)]) {
                [self helperAcceptNotification];
            } else {
                [self helperDeclineNotification];
            }
        }
    }];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!error) {
                                  NSLog(@"request authorization succeeded!");
                              }
                          }];
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
    self.lat.text = [NSString stringWithFormat:@"%.8f", self.currentLocation.coordinate.latitude];
    self.longit.text = [NSString stringWithFormat:@"%.8f", self.currentLocation.coordinate.longitude];
    FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"positions"] child:[User sharedInstance].currentUserName];
    NSDictionary *post = @{@"latitude": self.lat.text, @"longitude": self.longit.text, @"helpedBy": @"nobody", @"rated": @(NO), @"isHelped": @(NO), @"rating": @(0)};
    [newref setValue:post];

}

- (IBAction)signOut:(id)sender {
    [User sharedInstance].currentUserName = @"";
    [User sharedInstance].currentUserRate = 0;
    [User sharedInstance].currentUserType = @"";
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendVocalCommand:(id)sender {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.sendVocalCommandButton.enabled = NO;
        [self.sendVocalCommandButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    } else {
        [self startRecording];
        [self.sendVocalCommandButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    }
}

#pragma mark - MapKit Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = [locations lastObject];
    NSLog(@"---> Location: %@", self.currentLocation);
}

#pragma mark - User Notifications Delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
}

- (void)startRecording {
    if (self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    recognitionRequest.shouldReportPartialResults = YES;
    
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __block BOOL isFinal = NO;
        
        if (result) {
            // TODO: Aici trebuie interpretat rezultatul
            NSLog(@"%@", result.bestTranscription.formattedString);
            isFinal = result.isFinal;
        }
        
        if (error || isFinal) {
            [self.audioEngine stop];
            [self.audioEngine.inputNode removeTapOnBus:0];
            
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            
            self.sendVocalCommandButton.enabled = YES;
        }
        
        AVAudioFormat *recordingFormat = [self.audioEngine.inputNode outputFormatForBus:0];
        
        [self.audioEngine.inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            [self.recognitionRequest appendAudioPCMBuffer:buffer];
        }];
        
        [self.audioEngine prepare];
        [self.audioEngine startAndReturnError:nil];
    }];
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    if (available) {
        self.sendVocalCommandButton.enabled = YES;
    } else {
        self.sendVocalCommandButton.enabled = NO;
    }
}

@end
