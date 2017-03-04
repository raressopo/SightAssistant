//
//  Position.h
//  Sight Assistant
//
//  Created by Rares Soponar on 13/02/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic) BOOL helped;

@property (nonatomic, strong) NSMutableArray *positions;

- (instancetype)initWithUser:(NSString *)user latitude:(NSString *)lat andLongitude:(NSString *)lon helped:(BOOL)helped;
+ (instancetype)sharedInstance;

@end
