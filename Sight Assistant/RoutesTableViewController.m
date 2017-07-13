//
//  RoutesTableViewController.m
//  Sight Assistant
//
//  Created by Rares Soponar on 08/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "RoutesTableViewController.h"
#import "UserRoutes.h"
#import "User.h"
#import "RouteMapViewController.h"

@interface RoutesTableViewController ()

@property (nonatomic, strong) NSMutableArray *userRoutes;
@property (nonatomic) NSInteger currentRowSelected;
@property (weak, nonatomic) IBOutlet UIButton *sendVocalCommandsButton;
@property (weak, nonatomic) IBOutlet UIView *viewUnderButton;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@end

@implementation RoutesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc]init];

    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ro_RO"]];
    // Set speech recognizer delegate
    speechRecognizer.delegate = self;
    
    self.currentRowSelected = 0;
    self.userRoutes = [[NSMutableArray alloc] init];
    
    for (UserRoutes *user in [UserRoutes sharedInstance].routesOfAllUsers) {
        if ([user.user isEqualToString:[User sharedInstance].currentUserName]) {
            self.userRoutes = user.allRoutes;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"blindMode"]) {
        self.sendVocalCommandsButton.hidden = YES;
        self.viewUnderButton.hidden = YES;
    } else {
        self.sendVocalCommandsButton.hidden = NO;
        self.viewUnderButton.hidden = NO;
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
    [self textToSpeech:@"Selectați ruta"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self textToSpeech:@"Rută selectată cu succes"];
    sleep(2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)sendVocalCommand:(id)sender {
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
    recogReq.shouldReportPartialResults = NO;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recogReq resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the mic after pressing the button should be being logged
            // in the console.
            for (Route *route in self.userRoutes){
                if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:route.destinationName]) {
                    NSInteger a = [self.userRoutes indexOfObject:route];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:a inSection:0];
                    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    self.currentRowSelected = indexPath.row;
                    [self performSegueWithIdentifier:@"route" sender:self];
                } else if ([[result.bestTranscription.formattedString lowercaseString] isEqualToString:@"înapoi"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }  else {
                    [self textToSpeech:@"Comandă necunoscută"];
                }
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
        self.sendVocalCommandsButton.enabled = YES;
    } else {
        self.sendVocalCommandsButton.enabled = NO;
    }
}

- (void)textToSpeech:(NSString *)text {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"ro_RO"];
    utterance.voice = language;
    [utterance setRate:0.5];
    [self.synthesizer speakUtterance:utterance];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userRoutes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"route" forIndexPath:indexPath];
    
    cell.textLabel.text = ((Route *)self.userRoutes[indexPath.row]).destinationName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentRowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"route" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"route"]) {
        RouteMapViewController *destinationVC = segue.destinationViewController;
        destinationVC.currentRowSelected = self.currentRowSelected + 1;
    }
}

@end
