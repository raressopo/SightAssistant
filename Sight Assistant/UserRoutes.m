//
//  UserRoutes.m
//  Sight Assistant
//
//  Created by Rares Soponar on 12/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "UserRoutes.h"

@implementation UserRoutes

- (instancetype)init {
    self = [super init];
    if (self){
        self.allRoutes = [[NSMutableArray alloc] init];
        self.user = @"";
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static UserRoutes *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserRoutes alloc] init];
    });
    return sharedInstance;
}

@end
