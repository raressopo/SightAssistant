//
//  CreateObstacleViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 22/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import "AddObstacleMapViewController.h"
#import "Obstacle.h"
#import <FirebaseDatabase/FirebaseDatabase.h>

@interface CreateObstacleViewController : ViewController <UIPickerViewDelegate, UIPickerViewDataSource, CreateObstacleDelegate>

@property (nonatomic, strong) Obstacle *editableObstacle;
@property (nonatomic, assign) BOOL isEditObstacle;

@end
