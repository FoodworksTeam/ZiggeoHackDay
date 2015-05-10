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

@property (nonatomic, strong) VideoRecorder *recorderview;

@property (nonatomic, strong) EAGLContext* context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Make an popover view.  That goes once they hit start?
    
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [_recorderview.session endRtmpSession];
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    _recorderview = [[VideoRecorder alloc] initWithFrame:self.view.frame];
    _recorderview.delegate = self;
    [self.view addSubview:_recorderview];
    
    
    [super viewWillAppear:animated];
    
}


# pragma MARK  VideoRecorderDelegate
- (void) onUploadCompleteWithVideoToken:(NSString*)vt andImage:(UIImage*)img
{
    // Show refresh control and disable stuff.
    if(vt) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        PFObject *video = [PFObject objectWithClassName:@"Video"];
        [video setObject:vt forKey:@"ZVideoToken"];
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:appDelegate.currentLocation];
        if(geoPoint) {
            [video setObject:geoPoint forKey:@"location"];
        }
        
        
        [video saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded) {
                //Lets save it to the trail.
                
                PFObject *trail = [[PFUser currentUser] objectForKey:@"trail"];
                
                if(!trail)
                {
                    //Firs time.
                    PFObject *trail = [PFObject objectWithClassName:@"Trail"];
                    [trail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [[PFUser currentUser] setObject:trail forKey:@"trail"];
                        [[PFUser currentUser] saveInBackground];
                        
                        PFRelation *crumbs = [trail relationForKey:@"crumbs"];
                        
                        [crumbs addObject:video];
                        [trail saveInBackground];
                        
                    }];
                }
                
                
                
                PFRelation *crumbs = [trail relationForKey:@"crumbs"];
                
                
                [crumbs addObject:video];
                
                
                [trail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    
                    
                    
                }];
                
            }
        }];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory warning on View controller.");
}

@end
