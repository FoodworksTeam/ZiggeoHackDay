//
//  VideoRecorder.m
//  ZiggeoiOsSDK
//
//  Created by Gianluca di Maggio on 29/09/14.
//  Copyright (c) 2014 Ziggeo. All rights reserved.
//

#import "VideoRecorder.h"
#import "ZiggeoiOsSDK.h"
#import "VCSimpleSession.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoRecorder () <VCSessionDelegate>
    @property (nonatomic, assign) int recordingDuration;
@end

@implementation VideoRecorder {
    
    BOOL isInitialStream;
    BOOL canRotate;
    BOOL hasUploadEnded;
    BOOL setup;
    BOOL videoRecorded;
    UIButton *_buttonFlash;
    UIButton *_buttonStart;
    UIButton *_buttonCamera;
    UIView *_loadingView;
    UILabel *_loadingLabel;
    UIActivityIndicatorView *_loadingIndicator;

}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Init session with given framerate and dimensions, using size of screen
        CGSize screeSize = [[UIScreen mainScreen] bounds].size;
        _session = [[VCSimpleSession alloc] initWithVideoSize:CGSizeMake(screeSize.width, screeSize.height) frameRate:30 bitrate:1000000];
        
        // Add the video recorder to the view layout
        [self addSubview: _session.previewView];
        _session.previewView.frame = [self frame];
        
        // Set delegate
        _session.delegate = self;

        // Initialize Views
//        _buttonFlash = [[UIButton alloc] initWithFrame:CGRectMake([self frame].size.width - 96, [self frame].size.height - 96 - 49, 96, 96)];
//        [_buttonFlash setImage:[UIImage imageNamed:@"ic_flash_on_holo_light.png"] forState:UIControlStateNormal];
//        [_buttonFlash addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_buttonFlash];
        _buttonStart = [[UIButton alloc] initWithFrame:CGRectMake(([self frame].size.width - 96) / 2, [self frame].size.height - 96 - 49, 96, 96)];
        [_buttonStart setImage:[UIImage imageNamed:@"record-unpressed"] forState:UIControlStateNormal];
        [_buttonStart addTarget:self action:@selector(toggleStream) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_buttonStart];
        _buttonCamera = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 56, 56)];
        [_buttonCamera setImage:[UIImage imageNamed:@"ios7-camera-outline"] forState:UIControlStateNormal];
        [_buttonCamera addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_buttonCamera];
        
        // Initialize some variables
        isInitialStream = TRUE;
        canRotate = TRUE;
        videoRecorded = FALSE;
        hasUploadEnded = FALSE;
        
        // check if flashlight is available
         [_buttonFlash setEnabled:NO];
         Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
         if (captureDeviceClass != nil) {
             AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
             if ([device hasTorch] && [device hasFlash])
                    [_buttonFlash setEnabled:YES];
         }
        
        [self setUpLoadingView];
    }
    return self;
}


- (void)setUpLoadingView
{
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, self.frame.size.width - 40, 200)];
    _loadingView.backgroundColor = [UIColor blackColor];
    _loadingView.alpha = .7;
    _loadingView.layer.cornerRadius = 10.0;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.frame = CGRectMake(0, 20, _loadingView.frame.size.width, 60);
    [_loadingView addSubview:_loadingIndicator];
    
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, _loadingView.frame.size.width - 20, 40)];
    _loadingLabel.font = [UIFont boldSystemFontOfSize:22];
    _loadingLabel.textColor = [UIColor whiteColor];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.numberOfLines = 0;
    _loadingLabel.text = @"Preparing to Record...";
    [_loadingView addSubview:_loadingLabel];
}


- (void)toggleFlash {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if (device.torchActive) {
        [device setTorchMode:AVCaptureTorchModeOn];
        [device setFlashMode:AVCaptureFlashModeOn];
        [_buttonFlash setImage:[UIImage imageNamed:@"ic_flash_off_holo_light.png"] forState:UIControlStateNormal];
    } else {
        [device setTorchMode:AVCaptureTorchModeOff];
        [device setFlashMode:AVCaptureFlashModeOff];
        [_buttonFlash setImage:[UIImage imageNamed:@"ic_flash_on_holo_light.png"] forState:UIControlStateNormal];
    }
    [device unlockForConfiguration];
    
}


- (void)switchCamera {
    _session.cameraState = _session.cameraState == VCCameraStateBack ? VCCameraStateFront : VCCameraStateBack;
}

- (void) setEnableUI:(BOOL)enable {
    
}


- (void) connectionStatusChanged:(VCSessionState) state {
    switch(state) {
            
        case VCSessionStateError:
        case VCSessionStateStarting:
        case VCSessionStateNone:
        case VCSessionStatePreviewStarted:
            break;
            
            // Once session has started, start countdown timer
        case VCSessionStateStarted:
            NSLog(@"VCSessionStream Started");
            // Stream started.
            [self updateViewForStart];
            
            if (_recordingDuration)
                [self performSelector:@selector(stopStream) withObject:nil afterDelay:_recordingDuration];
            break;
            
            // Connection has ended
        case VCSessionStateEnded:
            NSLog(@"VCSessionStream Ended");

            // Session could be completed either before or after the user
            // has already selected the preview frame. In the former case,
            // the player has been already setup the video player in
            // the onItemClick method, hence nothing more need to be done
            // here. In the latter case, a spinner has been shown instead,
            // that we need to stop here and then display the player
            [self updateViewForStopped];
            hasUploadEnded = TRUE;
            [self resetStream];
            if (self.delegate)
                [self.delegate onUploadCompleteWithVideoToken:VIDEO_TOKEN andImage:nil];
            break;
            
        default: break;
    }
}

- (void)updateViewForStart
{
    [_loadingView removeFromSuperview];
    [_buttonStart setImage:[UIImage imageNamed:@"record-pressed"] forState:UIControlStateNormal];
}

- (void)updateViewForStopped
{
    [_loadingView removeFromSuperview];
    [_buttonStart setImage:[UIImage imageNamed:@"record-unpressed"] forState:UIControlStateNormal];
}


- (void)toggleStream {
    //
    //    [self getPreviewFrame:nil];
    //    [self performSegueWithIdentifier:@"previewSegue" sender:self];
    //    return;
    
    // Get configuration
    
    switch(_session.rtmpSessionState) {
        case VCSessionStatePreviewStarted:
            [self addLoadingView];
            [self retrieveTokens];
            canRotate = FALSE;
            break;
        case VCSessionStateEnded:
            [self addLoadingView];
            isInitialStream = YES;
            [self retrieveTokens];
            canRotate = FALSE;
            break;
        default:
            [self stopStream]; break;
    }
}

- (void)addLoadingView
{
    [_loadingIndicator startAnimating];
    [self addSubview:_loadingView];
}

- (void) retrieveTokens {
    
    // If this is the first stream, then create a new video via a POST request
    if (isInitialStream) {
        
        // Initialize a url request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ZiggeoiOsSDK postNewVideoPath]];
        [request setHTTPMethod:@"POST"];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        // Perform an async post request, and define what to do with the data received
        [NSURLConnection
         sendAsynchronousRequest:request
         queue:queue
         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
             
             // Request executed correctly, parse Video token and Stream token
             if (error == nil && data.length > 0) {
                 // Parse JSON
                 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                 VIDEO_TOKEN = [[dict objectForKey:@"video"] objectForKey:@"token"];
                 STREAM_TOKEN = [[dict objectForKey:@"stream"] objectForKey:@"token"];
                 NSLog(@"ST:%@, VT:%@", VIDEO_TOKEN, STREAM_TOKEN);
                 [self startStream];
             }
             
         }
         ];
        
        isInitialStream = FALSE;
    }
    
    //If not initial stream, then create a new one using same video token
    else {
        // Get the url
        // Initialize a url request
        NSURLRequest *request = [NSURLRequest requestWithURL:[ZiggeoiOsSDK postNewStreamPath:VIDEO_TOKEN]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        // Perform an async post request, and define what to do with the data received
        [NSURLConnection
         sendAsynchronousRequest:request
         queue:queue
         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
             
             // Request executed correctly, parse Video token and Stream token
             if (error == nil && data.length > 0) {
                 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                 STREAM_TOKEN = [[dict objectForKey:@"stream"] objectForKey:@"token"];
                 [self startStream];
             }
         }
         ];
    }
    
}

- (void) startStream {
    
    // Get the server parameters
    [_session startRtmpSessionWithURL:[ZiggeoiOsSDK recordWowzaServer] andStreamKey:[ZiggeoiOsSDK recordWowzaPath:VIDEO_TOKEN stream:STREAM_TOKEN]];
    
    
}

- (void)stopStream {
    
    NSLog(@"Stopping stream");
    
    
    
    // Stops the stream and disconnects from the RTSP server
    [_session endRtmpSession];

    // TODO?
    /*
    Config *conf = [Config sharedManager];
    if (conf.debug) {
        NSString *tempUrl = [conf getRecordingURLWithAppName:@"ziggeo" andStreamName:@"test_video.mp4"];
        [self getRequest:[NSString stringWithFormat:@"%@&action=stopRecording", tempUrl]];
    }
     */
    
    videoRecorded = true;
    

}

- (void) resetStream {
    
    // Reset variables
    canRotate = TRUE;
    hasUploadEnded = FALSE;
    videoRecorded = TRUE;

    // Start recording the stream with HTTP post request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[ZiggeoiOsSDK postVideoPath:VIDEO_TOKEN stream:STREAM_TOKEN]];
    [request setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){}];
    

}



/********* Rotation Method **********/

//- (BOOL) shouldAutorotate {
//    NSLog(@"Can rotate:%d", canRotate);
//    return canRotate;
//}

/********** Some getters/setters *************/

- (BOOL) hasUploadEnded { return hasUploadEnded; }

@end
