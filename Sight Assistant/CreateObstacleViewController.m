//
//  CreateObstacleViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 22/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "CreateObstacleViewController.h"

@interface CreateObstacleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *obstacleNameField;
@property (weak, nonatomic) IBOutlet UITextField *obstacleShortDescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *obstacleTypeField;
@property (weak, nonatomic) IBOutlet UITextField *obstacleSizeField;

// Small/Short Obstacle UI elements
@property (weak, nonatomic) IBOutlet UITextField *longCoordField;
@property (weak, nonatomic) IBOutlet UITextField *latCoordField;
@property (weak, nonatomic) IBOutlet UIButton *getLocationButton;

// Big/Long Obstacle UI elements - START COORD
@property (weak, nonatomic) IBOutlet UITextField *startLatitudeField;
@property (weak, nonatomic) IBOutlet UITextField *startLongitudeField;
@property (weak, nonatomic) IBOutlet UIButton *getStartLocation;

// Big/Long Obstacle UI elements - END COORD
@property (weak, nonatomic) IBOutlet UITextField *endLatitudeField;
@property (weak, nonatomic) IBOutlet UITextField *endLongitudeField;
@property (weak, nonatomic) IBOutlet UIButton *getEndLocation;

// PickerView properties UI + Logic
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *sizeOrTypePicker;
@property (nonatomic, strong) NSArray *obstacleType;
@property (nonatomic, strong) NSArray *obstacleSize;

@property (nonatomic, assign) BOOL sizeWasPressed;
@property (nonatomic, assign) BOOL typeWasPressed;

@property (nonatomic, assign) BOOL isBigOrLongObstacle;
@property (nonatomic, assign) BOOL isSmallObstacle;
@property (nonatomic, assign) BOOL isStartOfTheObstacle;
@property (nonatomic, assign) BOOL isEndOfTheObstacle;

@property (nonatomic, strong) CLLocation *smallObstacle;
@property (nonatomic, strong) CLLocation *startOfTheObstacle;
@property (nonatomic, strong) CLLocation *endOfTheObstacle;
@property (weak, nonatomic) IBOutlet UIButton *addObstBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateObstBtn;

@end

@implementation CreateObstacleViewController


# pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isBigOrLongObstacle = NO;
     self.obstacleType = @[@"crowded sidewalk", @"heavy to pass", @"easy to pass"];
     self.obstacleSize = @[@"big", @"long", @"small", @"short"];
    
    self.sizeWasPressed = NO;
    self.typeWasPressed = NO;
    
    self.pickerView.hidden = YES;
    
    self.addObstBtn.hidden = self.isEditObstacle;
    self.updateObstBtn.hidden = !self.isEditObstacle;
    self.obstacleNameField.enabled = !self.isEditObstacle;
    
    if (self.isEditObstacle) {
        self.obstacleNameField.text = self.editableObstacle.name;
        self.obstacleShortDescriptionField.text = self.editableObstacle.shortDescription;
        if (self.editableObstacle.size == ShortObstacle) {
            self.obstacleSizeField.text = @"short";
            self.longCoordField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.longitude];
            self.latCoordField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.latitude];
        } else if (self.editableObstacle.size == SmallObstacle) {
            self.obstacleSizeField.text = @"small";
            self.longCoordField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.longitude];
            self.latCoordField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.latitude];
        } else if (self.editableObstacle.size == BigObstacle) {
            self.obstacleSizeField.text = @"big";
            self.startLongitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.longitude];
            self.startLatitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.latitude];
            self.endLongitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.end.coordinate.longitude];
            self.endLatitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.end.coordinate.latitude];
        }  else if (self.editableObstacle.size == LongObstacle) {
            self.obstacleSizeField.text = @"long";
            self.startLongitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.longitude];
            self.startLatitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.start.coordinate.latitude];
            self.endLongitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.end.coordinate.longitude];
            self.endLatitudeField.text = [NSString stringWithFormat:@"%f", self.editableObstacle.end.coordinate.latitude];
        }
        if (self.editableObstacle.type == CrowdedSidewalk) {
            self.obstacleTypeField.text = @"crowded sidewalk";
        } else if (self.editableObstacle.type == HeavyToPass) {
            self.obstacleTypeField.text = @"heavy to pass";
        } else if (self.editableObstacle.type == EasyToPass) {
            self.obstacleTypeField.text = @"easy to pass";
        }
    }
    
    if (!self.isBigOrLongObstacle) {
        [self hideStartEndCoordFields:YES];
    }
    
    if (self.editableObstacle.size == ShortObstacle || self.editableObstacle.size == SmallObstacle) {
        [self hideStartEndCoordFields:YES];
    } else if (self.editableObstacle.size == BigObstacle || self.editableObstacle.size == LongObstacle) {
        [self hideStartEndCoordFields:NO];
        self.longCoordField.hidden = YES;
        self.latCoordField.hidden = YES;
        self.getLocationButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isSmallObstacle) {
        self.latCoordField.text = [NSString stringWithFormat:@"%.10f", self.smallObstacle.coordinate.latitude];
        self.longCoordField.text = [NSString stringWithFormat:@"%.10f", self.smallObstacle.coordinate.longitude];
    } else if (self.isStartOfTheObstacle) {
        self.startLatitudeField.text = [NSString stringWithFormat:@"%.10f", self.startOfTheObstacle.coordinate.latitude];
        self.startLongitudeField.text = [NSString stringWithFormat:@"%.10f", self.startOfTheObstacle.coordinate.longitude];
    } else if (self.isEndOfTheObstacle) {
        self.endLatitudeField.text = [NSString stringWithFormat:@"%.10f", self.endOfTheObstacle.coordinate.latitude];
        self.endLongitudeField.text = [NSString stringWithFormat:@"%.10f", self.endOfTheObstacle.coordinate.longitude];
    }
    
    self.isSmallObstacle = NO;
    self.isStartOfTheObstacle = NO;
    self.isEndOfTheObstacle = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma mark - UI actions

- (IBAction)selectObstacleType:(id)sender {
    self.typeWasPressed = YES;
    self.pickerView.hidden = NO;
    self.sizeOrTypePicker.delegate = self;
    self.sizeOrTypePicker.dataSource = self;
}

- (IBAction)selectObstaceSize:(id)sender {
//    self.view.alpha = 0.5;
    self.sizeWasPressed = YES;
    self.pickerView.hidden = NO;
    self.sizeOrTypePicker.delegate = self;
    self.sizeOrTypePicker.dataSource = self;
}

- (IBAction)addObstacle:(id)sender {
    if ([self checkIfAllFieldsArePopulated]) {
        FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"obstacles"] child:self.obstacleNameField.text];
        NSDictionary *post = @{@"name": self.obstacleNameField.text,
                               @"description": self.obstacleShortDescriptionField.text,
                               @"type": self.obstacleTypeField.text,
                               @"size": self.obstacleSizeField.text,
                               @"date": [NSString stringWithFormat:@"%@", [NSDate date]],
                               @"start": @{@"lat": (self.startOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.startLatitudeField.text : self.latCoordField.text,
                                           @"lon": (self.startOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.startLongitudeField.text : self.longCoordField.text},
                               @"end": @{@"lat": (self.endOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.endLatitudeField.text : self.latCoordField.text,
                                         @"lon": (self.endOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.endLongitudeField.text : self.longCoordField.text}};
        
        [newref setValue:post];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Incomplete information"
                                                                       message:@"Please don't let blank fields without information!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
- (IBAction)updateBtnPressed:(id)sender {
    if ([self checkIfAllFieldsArePopulated]) {
        FIRDatabaseReference *newref = [[[FIRDatabase database] referenceWithPath:@"obstacles"] child:self.obstacleNameField.text];
        NSDictionary *post = @{@"name": self.obstacleNameField.text,
                               @"description": self.obstacleShortDescriptionField.text,
                               @"type": self.obstacleTypeField.text,
                               @"size": self.obstacleSizeField.text,
                               @"start": @{@"lat": (self.startOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.startLatitudeField.text : self.latCoordField.text,
                                           @"lon": (self.startOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.startLongitudeField.text : self.longCoordField.text},
                               @"end": @{@"lat": (self.endOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.endLatitudeField.text : self.latCoordField.text,
                                         @"lon": (self.endOfTheObstacle || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) ? self.endLongitudeField.text : self.longCoordField.text},
                               @"updatedAt": [NSString stringWithFormat:@"%@", [NSDate date]]};
        
        [newref updateChildValues:post];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - PickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.sizeWasPressed) {
        return self.obstacleSize.count;
    } else if (self.typeWasPressed) {
        return self.obstacleType.count;
    }
    
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.sizeWasPressed) {
        return self.obstacleSize[row];
    } else if (self.typeWasPressed) {
        return self.obstacleType[row];
    }
    
    return self.obstacleType[0];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.sizeWasPressed) {
        self.smallObstacle = nil;
        self.startOfTheObstacle = nil;
        self.endOfTheObstacle = nil;
        
        self.sizeWasPressed = NO;
        self.obstacleSizeField.text = self.obstacleSize[row];
        self.pickerView.hidden = YES;
        
        if ([self.obstacleSize[row] isEqualToString:@"big"] || [self.obstacleSize[row] isEqualToString:@"long"]) {
            [self hideCoordFields:NO];
        } else {
            [self hideCoordFields:YES];
        }
        
        self.sizeOrTypePicker.delegate = nil;
        self.sizeOrTypePicker.dataSource = nil;
    } else if (self.typeWasPressed) {
        self.typeWasPressed = NO;
        self.obstacleTypeField.text = self.obstacleType[row];
        self.pickerView.hidden = YES;
        
        self.sizeOrTypePicker.delegate = nil;
        self.sizeOrTypePicker.dataSource = nil;
    }
}

#pragma mark - Helper methods

- (void)hideStartEndCoordFields:(BOOL)hidden {
    self.startLatitudeField.hidden = hidden;
    self.startLongitudeField.hidden = hidden;
    self.getStartLocation.hidden = hidden;
    
    self.endLatitudeField.hidden = hidden;
    self.endLongitudeField.hidden = hidden;
    self.getEndLocation.hidden = hidden;
}

- (void)hideCoordFields:(BOOL)hidden {
    [self hideStartEndCoordFields:hidden];
    
    self.latCoordField.hidden = !hidden;
    self.longCoordField.hidden = !hidden;
    self.getLocationButton.hidden = !hidden;
    
    self.isBigOrLongObstacle = !hidden;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AddObstacleMapViewController *controller = segue.destinationViewController;
    controller.delegate = self;
    
    if ([segue.identifier isEqualToString:@"smallObst"]) {
        controller.isSmallObstacle = YES;
        self.isSmallObstacle = YES;
    } else if ([segue.identifier isEqualToString:@"startObst"]) {
        controller.isStartOfTheObstacle = YES;
        self.isStartOfTheObstacle = YES;
    } else if ([segue.identifier isEqualToString:@"endObst"]) {
        controller.isEndOfTheObstacle = YES;
        self.isEndOfTheObstacle = YES;
    } else if ([segue.identifier isEqualToString:@"showObst"]) {
        if ([self checkIfAllFieldsArePopulated]) {
            if (self.smallObstacle || self.editableObstacle.size == SmallObstacle || self.editableObstacle.size == ShortObstacle) {
                controller.obstacle = self.smallObstacle ? self.smallObstacle : self.editableObstacle.start;
            } else if ((self.startOfTheObstacle && self.endOfTheObstacle) || self.editableObstacle.size == LongObstacle || self.editableObstacle.size == BigObstacle) {
                controller.startOfObstacle = self.startOfTheObstacle ? self.startOfTheObstacle : self.editableObstacle.start;
                controller.endOfObstacle = self.endOfTheObstacle ? self.endOfTheObstacle : self.editableObstacle.end;
            }
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Uncomplete information"
                                                                           message:@"Please don't let blank fields without information!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)setCreatedLocationWIthLatitude:(CLLocation *)location withType:(NSString *)type {
    if ([type isEqualToString:@"small"]) {
        self.smallObstacle = location;
    } else if ([type isEqualToString:@"start"]) {
        self.startOfTheObstacle = location;
    } else if ([type isEqualToString:@"end"]) {
        self.endOfTheObstacle = location;
    }
}

- (BOOL)checkIfAllFieldsArePopulated {
    if (!self.getLocationButton.hidden) {
        return self.obstacleNameField.text.length && self.obstacleShortDescriptionField.text.length && self.obstacleTypeField.text.length && self.obstacleSizeField.text.length && self.latCoordField.text.length && self.longCoordField.text.length;
    } else {
        return self.obstacleNameField.text && self.obstacleShortDescriptionField.text && self.obstacleTypeField.text && self.obstacleSizeField.text && self.startLatitudeField.text &&self.startLongitudeField.text && self.endLatitudeField.text && self.endLongitudeField.text;
    }
    
    return NO;
}

@end
