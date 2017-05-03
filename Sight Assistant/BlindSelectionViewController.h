//
//  BlindSelectionViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import <UserNotifications/UserNotifications.h>
#import <Speech/Speech.h>

@interface BlindSelectionViewController : ViewController <CLLocationManagerDelegate, UNUserNotificationCenterDelegate, SFSpeechRecognizerDelegate>

@end
