//
//  RouteMapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 16/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "RouteMapViewController.h"
#import "Obstacle.h"
#import "UserRoutes.h"
#import "User.h"

@interface RouteMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *routeDestination;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *sendVocalCommands;
@property (nonatomic,strong) UILongPressGestureRecognizer *changeUIModePress;
@property (nonatomic, strong) NSArray *userRoutes;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation RouteMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UserRoutes *user in [UserRoutes sharedInstance].routesOfAllUsers) {
        if ([user.user isEqualToString:[User sharedInstance].currentUserName]) {
            self.userRoutes = user.allRoutes;
        }
    }
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ro_RO"]];
    // Set speech recognizer delegate
    speechRecognizer.delegate = self;
    
    self.mapView.delegate=self;
    
    self.currentLocation = [[CLLocation alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
    
    self.route = self.userRoutes[self.currentRowSelected];
    self.routeDestination = [[CLLocation alloc] initWithLatitude:[self.route.lat doubleValue] longitude:[self.route.lon doubleValue]];
    [self centerMapOnLocation:self.routeDestination];
    
    self.changeUIModePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.changeUIModePress.minimumPressDuration = 3.0f;
    self.changeUIModePress.allowableMovement = 100.0f;
    
    [self.view addGestureRecognizer:self.changeUIModePress];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.synthesizer continueSpeaking];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"blindMode"]) {
        self.sendVocalCommands.hidden = YES;
    } else {
        self.sendVocalCommands.hidden = NO;
    }
    
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionTask cancel];
        [recognitionRequest endAudio];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self textToSpeech:@"Hartă deschisă cu succes"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if ([sender isEqual:self.changeUIModePress]) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            self.sendVocalCommands.hidden = !self.sendVocalCommands.hidden;
            [[NSUserDefaults standardUserDefaults] setBool:!self.sendVocalCommands.hidden forKey:@"blindMode"];
        }
    }
}

- (void)centerMapOnLocation:(CLLocation *)location {
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000 * 2.0, 1000 * 2.0);
    
    placemark.coordinate = location.coordinate;
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:placemark];
    [self.mapView selectAnnotation:placemark animated:YES];
}

#pragma mark - Location Manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = [locations lastObject];
    MKPointAnnotation *plmrk = [[MKPointAnnotation alloc] init];
    
    plmrk.coordinate = self.currentLocation.coordinate;
    
    [self.mapView addAnnotation:plmrk];
    [self.mapView selectAnnotation:plmrk animated:YES];
    
    MKPlacemark *p1 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.routeDestination.coordinate.latitude, self.routeDestination.coordinate.longitude) addressDictionary:nil];
    MKPlacemark *p2 = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude) addressDictionary:nil];
    
    // Create 2 mapitems from that 2 placemarks
    MKMapItem *mi1 = [[MKMapItem alloc] initWithPlacemark:p1];
    MKMapItem *mi2 = [[MKMapItem alloc] initWithPlacemark:p2];
    
    // Create directionRequest to set the destination and the source
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    directionRequest.source = mi2;
    directionRequest.destination = mi1;
    directionRequest.transportType = MKDirectionsTransportTypeWalking;
    directionRequest.requestsAlternateRoutes = YES;
    
    // Get directions for the route and put it on the mapview
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error){
        MKRoute *route = response.routes[0];
        if (route) {
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
            [self textToSpeech:[NSString stringWithFormat:@"În %.0f de metrii %@", route.steps[0].distance, route.steps[0].instructions]];

//            NSUInteger pointCount = route.polyline.pointCount;
//            
//            //allocate a C array to hold this many points/coordinates...
//            CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
//            
//            //get the coordinates (all of them)...
//            [route.polyline getCoordinates:routeCoordinates
//                                     range:NSMakeRange(0, pointCount)];
//            
//            //this part just shows how to use the results...
//            NSLog(@"route pointCount = %lu", (unsigned long)pointCount);
//            for (int c=0; c < pointCount; c++) {
//                NSLog(@"routeCoordinates[%d] = %.10f, %.10f", c, routeCoordinates[c].latitude, routeCoordinates[c].longitude);
//                for (Obstacle *obstacle in [Obstacle sharedInstance].allObstacles) {
//                    if (obstacle.size == LongObstacle || obstacle.size == BigObstacle) {
//                        
//                    }
//                    NSUInteger latDif = routeCoordinates[c].latitude - obstacle.start.coordinate.latitude;
//                    NSUInteger lonDif = routeCoordinates[c].longitude - obstacle.start.coordinate.longitude;
//                    
//                    NSLog(@"%lu, %lu", (unsigned long)latDif, (unsigned long)lonDif);
//                }
//            }
//            
//            //free the memory used by the C array when done with it...
//            free(routeCoordinates);
        }
    }];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polyLineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polyLineView.strokeColor = [UIColor redColor];
    polyLineView.lineWidth = 4.0;
    
    return polyLineView;
}
- (IBAction)sendCommands:(id)sender {
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
    } else {
        [self startListening];
        [self textToSpeech:@"Butonul a fost apăsat"];
    }
}

- (void)startListening {
    
    // Initialize the AVAudioEngine
    audioEngine = [[AVAudioEngine alloc] init];
    
    // Make sure there's not a recognition task already running
    if (recognitionTask) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    // Starts an AVAudio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = audioEngine.inputNode;
    SFSpeechAudioBufferRecognitionRequest *recogReq = recognitionRequest;
    recogReq.shouldReportPartialResults = YES;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recogReq resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the mic after pressing the button should be being logged
            // in the console.
            if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"înapoi"]) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self textToSpeech:@"Comandă necunoscută"];
            }
            
            isFinal = result.isFinal;
        }
        if (error || isFinal) {
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            recogReq.shouldReportPartialResults = NO;
            recognitionRequest = nil;
            recognitionTask = nil;
        }
    }];
    
    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    // Starts the audio engine, i.e. it starts listening.
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening");
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    if (available) {
        self.sendVocalCommands.enabled = YES;
    } else {
        self.sendVocalCommands.enabled = NO;
    }
}

- (void)textToSpeech:(NSString *)text {
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"ro_RO"];
    utterance.voice = language;
    [utterance setRate:0.45];
    [self.synthesizer speakUtterance:utterance];
}

@end
