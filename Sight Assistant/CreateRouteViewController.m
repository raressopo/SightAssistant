//
//  CreateRouteViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 12/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "CreateRouteViewController.h"

@interface CreateRouteViewController ()

@property (weak, nonatomic) IBOutlet UITextField *routeName;
@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;
@property (weak, nonatomic) IBOutlet UITextField *street;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (weak, nonatomic) IBOutlet UIButton *sendVocalCommandButton;
@property (nonatomic,strong) UILongPressGestureRecognizer *changeUIModePress;

@end

@implementation CreateRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];

    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ro_RO"]];
    // Set speech recognizer delegate
    speechRecognizer.delegate = self;
    
    self.location = [[CLLocation alloc] init];
    
    self.changeUIModePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.changeUIModePress.minimumPressDuration = 3.0f;
    self.changeUIModePress.allowableMovement = 100.0f;
    
    [self.view addGestureRecognizer:self.changeUIModePress];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.location) {
        self.latitude.text = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    }
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.synthesizer continueSpeaking];
    [self textToSpeech:@"Introduceți datele"];
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

- (IBAction)createPressed:(id)sender {
    FIRDatabaseReference *newref = [[[[FIRDatabase database] referenceWithPath:@"routes"] child:[User sharedInstance].currentUserName] child:self.routeName.text];
    if (self.latitude.text.length > 0 && self.latitude.text && self.longitude.text.length > 0 && self.longitude.text && [self.latitude.text doubleValue] > 0 && [self.longitude.text doubleValue] > 0) {
        NSDictionary *post = @{@"latitude": self.latitude.text, @"longitude": self.longitude.text};
        
        [newref setValue:post];
    } else if (self.street.text.length > 0 && self.street.text && self.number.text.length > 0 && self.number.text && self.city.text.length > 0 && self.city.text) {
        MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
        [searchRequest setNaturalLanguageQuery:[NSString stringWithFormat:@"%@ %@ %@", self.street.text, self.number.text, self.city.text]];
        
        // Create the local search to perform the search
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            if (!error) {
                NSDictionary *post = @{@"latitude": [NSString stringWithFormat:@"%.6f", response.mapItems[0].placemark.coordinate.latitude], @"longitude": [NSString stringWithFormat:@"%.6f", response.mapItems[0].placemark.coordinate.longitude]};
                
                [newref setValue:post];
            } else {
                NSLog(@"Search Request Error: %@", [error localizedDescription]);
            }
        }];
    }
    
    [self textToSpeech:@"Adresă adăugată în baza de date"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendCommand:(id)sender {
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
    } else {
        [self startListening];
        [self textToSpeech:@"Butonul a fost apăsat"];
    }
}

- (void)setCreatedLocationWIthLatitude:(CLLocation *)location {
    self.location = location;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createRoute"]) {
        GetDestMapViewController *controller = segue.destinationViewController;
        controller.delegate = self;
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
    recognitionRequest.shouldReportPartialResults = NO;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the mic after pressing the button should be being logged
            // in the console.
            NSLog(@"%@", [result.transcriptions lastObject]);
            if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"înapoi"]) {
                [self.navigationController popViewControllerAnimated:YES];
            } else if ([[result.bestTranscription.formattedString lowercaseString] containsString:@"strada"] || [[result.bestTranscription.formattedString lowercaseString] containsString:@"bulevardul"]) {
                self.street.text = result.bestTranscription.formattedString;
                [self textToSpeech:@"Stradă introdusă cu succes"];
            } else if ([[result.bestTranscription.formattedString lowercaseString] containsString:@"numărul"]) {
                NSArray *words = [result.bestTranscription.formattedString componentsSeparatedByString:@" "];
                self.number.text = [words lastObject];
                [self textToSpeech:@"Număr introdus cu succes"];
            } else if ([[result.bestTranscription.formattedString lowercaseString] containsString:@"orașul"]) {
                NSString *oras = [[result.bestTranscription.formattedString lowercaseString] stringByReplacingOccurrencesOfString:@"orașul" withString:@""];
                self.city.text = oras;
                [self textToSpeech:@"Oraș introdus cu succes"];
            } else if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"latitudine"]) {
                [self textToSpeech:@"Latitudine introdusă cu succes"];
            } else if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"longitudine"]) {
                [self textToSpeech:@"Longitudine introdusă cu succes"];
            } else if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"creează"]) {
                [self createPressed:nil];
                [self textToSpeech:@"Destinație adăugată cu succes"];
            } else if ([[result.bestTranscription.formattedString lowercaseString] containsString:@"nume"]) {
                NSString *nume = [[result.bestTranscription.formattedString lowercaseString] stringByReplacingOccurrencesOfString:@"nume" withString:@""];
                self.routeName.text = nume;
                [self textToSpeech:@"Numele destinației introdus cu succes"];
            } else {
                [self textToSpeech:@"Comandă necunoscută"];
            }
            
            isFinal = result.isFinal;
        }
        
        if (error || isFinal) {
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            recognitionRequest.shouldReportPartialResults = NO;
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
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    if (available) {
        self.sendVocalCommandButton.enabled = YES;
    } else {
        self.sendVocalCommandButton.enabled = NO;
    }
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult {
    NSLog(@"%@", recognitionResult.bestTranscription.formattedString);
}

- (void)textToSpeech:(NSString *)text {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"ro_RO"];
    utterance.voice = language;
    [utterance setRate:0.5];
    [self.synthesizer speakUtterance:utterance];
}




@end
