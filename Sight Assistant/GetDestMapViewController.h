//
//  GetDestMapViewController.h
//  Sight Assistant
//
//  Created by Rares Soponar on 15/03/2017.
//  Copyright © 2017 Rares Soponar. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <Speech/Speech.h>

@protocol CreateRouteDelegate <NSObject>

- (void)setCreatedLocationWIthLatitude:(CLLocation *)location;

@end

@interface GetDestMapViewController : ViewController <SFSpeechRecognizerDelegate> {
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
}

@property (nonatomic, strong) id<CreateRouteDelegate> delegate;

@end
