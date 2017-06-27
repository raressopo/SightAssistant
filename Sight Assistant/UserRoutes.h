//
//  UserRoutes.h
//  Sight Assistant
//
//  Created by Rares Soponar on 12/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

@interface UserRoutes : NSObject

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSMutableArray *allRoutes;

@property (nonatomic, strong) NSMutableArray *routesOfAllUsers;

+ (instancetype)sharedInstance;

@end
