//
//  Route.h
//  Sight Assistant
//
//  Created by Rares Soponar on 08/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (nonatomic, strong) NSMutableArray *routes;

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *destinationName;
@property (nonatomic, strong) NSString *user;

- (instancetype)initWithDestination:(NSString *)destinastionName latitude:(NSString *)latitude longitude:(NSString *)longitude forUser:(NSString *)user;
+ (instancetype)sharedInstance;

@end
