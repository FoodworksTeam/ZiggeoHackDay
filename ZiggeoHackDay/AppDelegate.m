//
//  AppDelegate.m
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ZiggeoiOsSDK.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Parse stuff.
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"fzku4MyoccA8jrlvb4EPn1qKydERyK09YJDAxEaN"
                  clientKey:@"LJqAG1BduE2uk718LkFzzqRyRv2w79LUUQDdWkYp"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    //Ziggeo
    [ZiggeoiOsSDK init:@"4b961928db1601a8da70022930a055b2"];
    
    [self createLocationManager];
    
    return YES;
}

-(void)createLocationManager
{
    _locManager = [[CLLocationManager alloc] init];
    _locManager.delegate = self;
    _locManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _locManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [_locManager requestWhenInUseAuthorization];
    
    _currentLocation = [_locManager location];
    [_locManager startUpdatingLocation];
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [_locManager stopUpdatingLocation];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

#pragma mark locationManager delegate methods


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Location update");
    CLLocation *newLocation = [locations lastObject];
    _currentLocation = newLocation;
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [_locManager startUpdatingLocation];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
