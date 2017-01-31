//
//  AppDelegate.h
//  Sight Assistant
//
//  Created by Rares Soponar on 22/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "User.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

