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
@property (weak, nonatomic) IBOutlet UILabel *vocalCommandLabel;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic,strong) UILongPressGestureRecognizer *changeUIModePress;

@property (nonatomic) BOOL viewWillAppearCheck;

@end

@implementation BlindSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ro_RO"]];
    // Set speech recognizer delegate
    speechRecognizer.delegate = self;
    
    // Request the authorization to make sure the user is asked for permission so you can
    // get an authorized response, also remember to change the .plist file, check the repo's
    // readme file or this projects info.plist
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"Authorized");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"Denied");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"Not Determined");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"Restricted");
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
    
    self.changeUIModePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.changeUIModePress.minimumPressDuration = 3.0f;
    self.changeUIModePress.allowableMovement = 100.0f;
    
    [self.view addGestureRecognizer:self.changeUIModePress];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewWillAppearCheck = YES;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"blindMode"]) {
        self.sendVocalCommandButton.hidden = YES;
    } else {
        self.sendVocalCommandButton.hidden = NO;
    }
    
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionTask cancel];
        [recognitionRequest endAudio];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper methods

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if ([sender isEqual:self.changeUIModePress]) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            self.sendVocalCommandButton.hidden = !self.sendVocalCommandButton.hidden;
            [[NSUserDefaults standardUserDefaults] setBool:!self.sendVocalCommandButton.hidden forKey:@"blindMode"];
        }
    }
}

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
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
    } else {
        [self startListening];
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

- (void)startListening {
    
    // Initialize the AVAudioEngine
    audioEngine = [[AVAudioEngine alloc] init];
    
    // Make sure there's not a recognition task already running
    if (recognitionTask) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    // Starts an AVAudio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = audioEngine.inputNode;
    SFSpeechAudioBufferRecognitionRequest *recogReq = recognitionRequest;
    recogReq.shouldReportPartialResults = YES;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recogReq resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the mic after pressing the button should be being logged
            // in the console.
            if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"drum"] || [[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"traseu"]) {
                [self performSegueWithIdentifier:@"routes" sender:self];
            } else if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"creează"]) {
                [self performSegueWithIdentifier:@"createRoute" sender:self];
            } else if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"ajutor"]) {
                [self getLocation:nil];
            }
            isFinal = result.isFinal;
        }
        if (error || isFinal) {
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            recogReq.shouldReportPartialResults = NO;
            recognitionRequest = nil;
            recognitionTask = nil;
        }
    }];
    
    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    // Starts the audio engine, i.e. it starts listening.
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening");
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"Availability:%d",available);
}

@end
