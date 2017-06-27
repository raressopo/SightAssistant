//
//  GetDestMapViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 15/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "GetDestMapViewController.h"

@interface GetDestMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *sendVocalCommandButton;
@property (nonatomic,strong) UILongPressGestureRecognizer *changeUIModePress;

@end

@implementation GetDestMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ro_RO"]];
    // Set speech recognizer delegate
    speechRecognizer.delegate = self;
    
    self.changeUIModePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.changeUIModePress.minimumPressDuration = 3.0f;
    self.changeUIModePress.allowableMovement = 100.0f;
    
    [self.view addGestureRecognizer:self.changeUIModePress];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"blindMode"]) {
        self.sendVocalCommandButton.hidden = YES;
    } else {
        self.sendVocalCommandButton.hidden = NO;
    }
    
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionTask cancel];
        [recognitionRequest endAudio];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if ([sender isEqual:self.changeUIModePress]) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            self.sendVocalCommandButton.hidden = !self.sendVocalCommandButton.hidden;
            [[NSUserDefaults standardUserDefaults] setBool:!self.sendVocalCommandButton.hidden forKey:@"blindMode"];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.mapView];
    CLLocationCoordinate2D selectedLocation = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:selectedLocation.latitude longitude:selectedLocation.longitude];
    [[self delegate] setCreatedLocationWIthLatitude:loc];
    
    MKPointAnnotation *placemark = [[MKPointAnnotation alloc] init];
    
    placemark.coordinate = loc.coordinate;
    
    [self.mapView addAnnotation:placemark];
    [self.mapView selectAnnotation:placemark animated:YES];
}

- (IBAction)sendCommand:(id)sender {
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
    } else {
        [self startListening];
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
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
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
    NSLog(@"Availability:%d",available);
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
