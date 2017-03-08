//
//  Route.m
//  Sight Assistant
//
//  Created by Rares Soponar on 08/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "Route.h"

@implementation Route

+ (instancetype)sharedInstance
{
    static Route *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Route alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.destinationName = @"";
        self.lat = @"";
        self.lon = @"";
        self.user = @"";
    }
    
    return self;
}

- (instancetype)initWithDestination:(NSString *)destinastionName latitude:(NSString *)latitude longitude:(NSString *)longitude forUser:(NSString *)user {
    self = [super init];
    if (self) {
        self.destinationName = destinastionName;
        self.lat = latitude;
        self.lon = longitude;
        self.user = user;
    }
    
    return self;
}

@end
