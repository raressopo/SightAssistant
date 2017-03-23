//
//  AddObstacleMapViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 19/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@protocol CreateObstacleDelegate <NSObject>

- (void)setCreatedLocationWIthLatitude:(CLLocation *)location withType:(NSString *)type;

@end

@interface AddObstacleMapViewController : ViewController

@property (nonatomic, assign) BOOL isSmallObstacle;
@property (nonatomic, assign) BOOL isStartOfTheObstacle;
@property (nonatomic, assign) BOOL isEndOfTheObstacle;

@property (nonatomic, strong) id<CreateObstacleDelegate> delegate;

@end
