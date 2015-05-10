//
//  OneTrailViewController.h
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface OneTrailViewController : UIViewController

@property (nonatomic, strong) PFObject *trail;
@property (nonatomic, strong) NSArray *crumbsArray;



@end
