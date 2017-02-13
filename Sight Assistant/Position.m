//
//  Position.m
//  Sight Assistant
//
//  Created by Rares Soponar on 13/02/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "Position.h"

@implementation Position

+ (instancetype)sharedInstance
{
    static Position *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Position alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.user = [[NSString alloc] init];
        self.lat = [[NSString alloc] init];
        self.lon = [[NSString alloc] init];
    }
    return self;
}

- (instancetype)initWithUser:(NSString *)user latitude:(NSString *)lat andLongitude:(NSString *)lon {
    self = [super init];
    if (self) {
        self.user = user;
        self.lat = lat;
        self.lon = lon;
    }
    return self;
}

@end
