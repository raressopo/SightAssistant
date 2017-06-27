//
//  Obstacle.m
//  Sight Assistant
//
//  Created by Rares Soponar on 19/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle

+ (instancetype)sharedInstance
{
    static Obstacle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Obstacle alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.shortDescription = [[NSString alloc] init];
        self.date = [[NSDate alloc] init];
        self.start = [[CLLocation alloc] init];
        self.end = [[CLLocation alloc] init];
        self.size = SmallObstacle;
        self.type = EasyToPass;
    }
    
    return self;
}

- (void)setStartLatitude:(NSString *)latitude andLongitude:(NSString *)longitude {
    self.start = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
}

- (void)setEndLatitude:(NSString *)latitude andLongitude:(NSString *)longitude {
    self.end = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
}

@end
