//
//  ViewController.m
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import "ViewController.h"
#import "Videoplayer.h"
#import "VideoRecorder.h"
#import "AppDelegate.h"



@interface ViewController () <VideoRecorderDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    VideoRecorder *recorderview = [[VideoRecorder alloc] initWithFrame:self.view.frame];
    recorderview.delegate = self;
    [self.view addSubview:recorderview];
    
    
}


# pragma MARK  VideoRecorderDelegate
- (void) onUploadCompleteWithVideoToken:(NSString*)vt andImage:(UIImage*)img
{
    // Show refresh control and disable stuff.
    
    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    PFObject *video = [PFObject objectWithClassName:@"Video"];
    [video setObject:vt forKey:@"ZVideoToken"];

    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:appDelegate.currentLocation];
    if(geoPoint) {
        [video setObject:geoPoint forKey:@"location"];
    }
    
    [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error) {
            //Lets save it to the trail.
            PFRelation *crumbs = [_trail relationForKey:@"crumbs"];
            
            
        }
    }];
    
//    NSLog(@"UploadCompleteWithVideoToken");
//    NSLog(vt);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory warning on View controller.");
}

@end
