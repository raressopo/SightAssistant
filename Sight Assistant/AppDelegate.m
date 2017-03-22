//
//  AppDelegate.m
//  Sight Assistant
//
//  Created by Rares Soponar on 22/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "AppDelegate.h"
#import "Position.h"
#import "Route.h"
#import "UserRoutes.h"
#import "Obstacle.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Something went wrong: %@", error);
        }
    }];
    
    // Get all the positions that need help from DB
    [Position sharedInstance].positions = [[NSMutableArray alloc] init];
    FIRDatabaseReference *positionsRef = [[FIRDatabase database] referenceWithPath:@"positions"];
    [positionsRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        Position *position = [[Position alloc] init];
        position.user = snapshot.key;
        position.lat = snapshot.value[@"latitude"];
        position.lon = snapshot.value[@"longitude"];
        position.helped = [snapshot.value[@"isHelped"] boolValue];
        
        [[Position sharedInstance].positions addObject:position];
    }];
    
    // Get all the routes from DB
    [UserRoutes sharedInstance].routesOfAllUsers = [[NSMutableArray alloc] init];
    FIRDatabaseReference *routesRef = [[FIRDatabase database] referenceWithPath:@"routes"];
    [routesRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *routes = snapshot.value;
        UserRoutes *userRoutes = [[UserRoutes alloc] init];
        userRoutes.user = snapshot.key;
        for (NSString *routeKey in routes.allKeys) {
            Route *route = [[Route alloc] init];
            route.destinationName = routeKey;
            NSDictionary *location = [routes objectForKey:routeKey];
            route.lat = [location objectForKey:@"latitude"];
            route.lon = [location objectForKey:@"longitude"];
            [userRoutes.allRoutes addObject:route];
        }
        [[UserRoutes sharedInstance].routesOfAllUsers addObject:userRoutes];
    }];
    
    // Get all the obstacles from DB
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    
    [Obstacle sharedInstance].allObstacles = [[NSMutableArray alloc] init];
    FIRDatabaseReference *obstaclesRef = [[FIRDatabase database] referenceWithPath:@"obstacles"];
    [obstaclesRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *obstacleDict = snapshot.value;
        Obstacle *obstacle = [[Obstacle alloc] init];
        obstacle.name = snapshot.key;
        obstacle.date = [dateFormatter dateFromString:[obstacleDict objectForKey:@"date"]];
        obstacle.shortDescription = [obstacleDict objectForKey:@"description"];
        [obstacle setStartLatitude:[[obstacleDict objectForKey:@"start"] objectForKey:@"lat"] andLongitude:[[obstacleDict objectForKey:@"start"] objectForKey:@"lon"]];
        [obstacle setEndLatitude:[[obstacleDict objectForKey:@"end"] objectForKey:@"lat"] andLongitude:[[obstacleDict objectForKey:@"end"] objectForKey:@"lon"]];
        
        if ([[obstacleDict objectForKey:@"size"] isEqualToString:@"big"]) {
            obstacle.size = BigObstacle;
        } else if ([[obstacleDict objectForKey:@"size"] isEqualToString:@"long"]) {
            obstacle.size = LongObstacle;
        } else if ([[obstacleDict objectForKey:@"size"] isEqualToString:@"small"]) {
            obstacle.size = SmallObstacle;
        } else if ([[obstacleDict objectForKey:@"size"] isEqualToString:@"short"]) {
            obstacle.size = ShortObstacle;
        }
        
        if ([[obstacleDict objectForKey:@"type"] isEqualToString:@"crowded sidewalk"]) {
            obstacle.type = CrowdedSidewalk;
        } else if ([[obstacleDict objectForKey:@"type"] isEqualToString:@"heavy to pass"]) {
            obstacle.type = HeavyToPass;
        } else if ([[obstacleDict objectForKey:@"type"] isEqualToString:@"easy to pass"]) {
            obstacle.type = EasyToPass;
        }
        [[Obstacle sharedInstance].allObstacles addObject:obstacle];
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Sight_Assistant"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
