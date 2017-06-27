//
//  Obstacle.h
//  Sight Assistant
//
//  Created by Rares Soponar on 19/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, ObstacleType) {
    CrowdedSidewalk,
    HeavyToPass,
    EasyToPass
};

typedef NS_ENUM(NSUInteger, ObstacleSize) {
    BigObstacle,
    SmallObstacle,
    LongObstacle,
    ShortObstacle
};

@interface Obstacle : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) ObstacleType type;
@property (nonatomic, assign) ObstacleSize size;
@property (nonatomic, strong) CLLocation *start;
@property (nonatomic, strong) CLLocation *end;

@property (nonatomic, strong) NSMutableArray *allObstacles;

+ (instancetype)sharedInstance;
- (void)setStartLatitude:(NSString *)latitude andLongitude:(NSString *)longitude;
- (void)setEndLatitude:(NSString *)latitude andLongitude:(NSString *)longitude;


@end
