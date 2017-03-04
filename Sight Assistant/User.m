//
//  User.m
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "User.h"

@implementation User

+ (instancetype)sharedInstance
{
    static User *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[User alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.userName = [[NSString alloc] init];
        self.password = [[NSString alloc] init];
        self.currentUserName = [[NSString alloc] init];
        self.blind = NO;
        self.helped = NO;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name withUserName:(NSString *)userName withPass:(NSString *)password isBlind:(BOOL)blind isHelped:(BOOL)isHelped {
    self = [super init];
    if (self) {
        self.name = name;
        self.userName = userName;
        self.password = password;
        self.blind = blind;
        self.helped = isHelped;
    }
    return self;
}

@end
