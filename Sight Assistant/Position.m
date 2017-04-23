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
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.user = [[NSString alloc] init];
        self.lat = [[NSString alloc] init];
        self.lon = [[NSString alloc] init];
        self.helpedBy = [[NSString alloc] init];
        self.rating = 0;
        self.rated = NO;
        self.helped = NO;
    }
    return self;
}

- (instancetype)initWithUser:(NSString *)user latitude:(NSString *)lat andLongitude:(NSString *)lon helped:(BOOL)helped {
    self = [super init];
    if (self) {
        self.user = user;
        self.lat = lat;
        self.lon = lon;
        self.helped = helped;
    }
    return self;
}

@end
