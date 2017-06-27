//
//  CreateRouteViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 12/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "GetDestMapViewController.h"

@interface CreateRouteViewController : ViewController <CreateRouteDelegate>

@property (nonatomic, strong) CLLocation *location;

@end
