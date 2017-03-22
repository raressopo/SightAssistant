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
@property (weak, nonatomic) IBOutlet UIPickerView *sizeOrTypePicker;
@property (nonatomic, assign) BOOL sizeWasPresserd;
@property (nonatomic, assign) BOOL typeWasPresserd;
@property (nonatomic, strong) NSArray *obstacleType;
@property (nonatomic, strong) NSArray *obstacleSize;
@property (weak, nonatomic) IBOutlet UITextField *longCoordField;
@property (weak, nonatomic) IBOutlet UITextField *latCoordField;
@property (weak, nonatomic) IBOutlet UIButton *getLocationButton;
@property (weak, nonatomic) IBOutlet UITextField *startLatitudeField;
@property (weak, nonatomic) IBOutlet UITextField *startLongitudeField;
@property (weak, nonatomic) IBOutlet UIButton *getStartLocation;
@property (weak, nonatomic) IBOutlet UITextField *endLatitudeField;
@property (weak, nonatomic) IBOutlet UITextField *endLongitudeField;
@property (weak, nonatomic) IBOutlet UIButton *getEndLocation;
@property (nonatomic, assign) BOOL isBigOrLongObstacle;

@end

@implementation CreateObstacleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isBigOrLongObstacle = NO;
     self.obstacleType = @[@"crowded sidewalk", @"heavy to pass", @"easy to pass"];
     self.obstacleSize = @[@"big", @"long", @"small", @"short"];
    
    self.sizeWasPresserd = NO;
    self.typeWasPresserd = NO;
    
    self.sizeOrTypePicker.hidden = YES;
    
    if (!self.isBigOrLongObstacle) {
        self.startLatitudeField.hidden = YES;
        self.startLongitudeField.hidden = YES;
        self.getStartLocation.hidden = YES;
        self.endLatitudeField.hidden = YES;
        self.endLongitudeField.hidden = YES;
        self.getEndLocation.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectObstacleType:(id)sender {
    self.typeWasPresserd = YES;
    self.sizeOrTypePicker.hidden = NO;
    self.sizeOrTypePicker.delegate = self;
    self.sizeOrTypePicker.dataSource = self;
}

- (IBAction)selectObstaceSize:(id)sender {
    self.view.alpha = 0.5;
    self.sizeWasPresserd = YES;
    self.sizeOrTypePicker.hidden = NO;
    self.sizeOrTypePicker.delegate = self;
    self.sizeOrTypePicker.dataSource = self;
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.sizeWasPresserd) {
        return self.obstacleSize.count;
    } else if (self.typeWasPresserd) {
        return self.obstacleType.count;
    }
    
    return 1;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.sizeWasPresserd) {
        return self.obstacleSize[row];
    } else if (self.typeWasPresserd) {
        return self.obstacleType[row];
    }
    
    return self.obstacleType[0];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if (self.sizeWasPresserd) {
        self.sizeWasPresserd = NO;
        self.obstacleSizeField.text = self.obstacleSize[row];
        self.sizeOrTypePicker.hidden = YES;
        
        if ([self.obstacleSize[row] isEqualToString:@"big"] || [self.obstacleSize[row] isEqualToString:@"long"]) {
            self.startLatitudeField.hidden = NO;
            self.startLongitudeField.hidden = NO;
            self.getStartLocation.hidden = NO;
            self.endLatitudeField.hidden = NO;
            self.endLongitudeField.hidden = NO;
            self.getEndLocation.hidden = NO;
            
            self.latCoordField.hidden = YES;
            self.longCoordField.hidden = YES;
            self.getLocationButton.hidden = YES;
            
            self.isBigOrLongObstacle = YES;
        } else {
            self.startLatitudeField.hidden = YES;
            self.startLongitudeField.hidden = YES;
            self.getStartLocation.hidden = YES;
            self.endLatitudeField.hidden = YES;
            self.endLongitudeField.hidden = YES;
            self.getEndLocation.hidden = YES;
            
            self.latCoordField.hidden = NO;
            self.longCoordField.hidden = NO;
            self.getLocationButton.hidden = NO;
            
            self.isBigOrLongObstacle = NO;
        }
        
        self.sizeOrTypePicker.delegate = nil;
        self.sizeOrTypePicker.dataSource = nil;
    } else if (self.typeWasPresserd) {
        self.typeWasPresserd = NO;
        self.obstacleTypeField.text = self.obstacleType[row];
        self.sizeOrTypePicker.hidden = YES;
        
        self.sizeOrTypePicker.delegate = nil;
        self.sizeOrTypePicker.dataSource = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
