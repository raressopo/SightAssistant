//
//  User.h
//  Sight Assistant
//
//  Created by Rares Soponar on 31/01/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL blind;
@property (nonatomic, assign) NSUInteger rating;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSString *currentUserName;
@property (nonatomic, assign) NSUInteger currentUserRate;
@property (nonatomic, strong) NSString *currentUserType;

- (instancetype)initWithName:(NSString *)name withUserName:(NSString *)userName withPass:(NSString *)password isBlind:(BOOL)blind withRating:(NSUInteger)rating;
+ (instancetype)sharedInstance;

@end
