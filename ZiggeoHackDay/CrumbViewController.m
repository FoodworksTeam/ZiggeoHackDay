//
//  CrumbViewController.m
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import "CrumbViewController.h"
#import "CrumbCell.h"
#import <Parse/Parse.h>
#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "VideoPlayer.h"


@interface CrumbViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *crumbsArray;

@property (strong, nonatomic)  UILabel *addLabel;
@property (strong, nonatomic)  UITextField *titleTextField;


@end

@implementation CrumbViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:239/255.0 blue:237/255.0 alpha:1.0];

    
    _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2, 50, 200, 50)];
    _titleTextField.borderStyle = UITextBorderStyleNone;
    _titleTextField.font = [UIFont systemFontOfSize:24];
    _titleTextField.placeholder = @"Name Your Trail";
    _titleTextField.textAlignment = NSTextAlignmentCenter;
    _titleTextField.backgroundColor = [UIColor whiteColor];
    _titleTextField.delegate = self;
    _titleTextField.layer.cornerRadius = 6.0;
    [self.view addSubview:_titleTextField];
    PFObject *trail = [[PFUser currentUser] objectForKey:@"trail"];
    [trail fetchIfNeeded];
    if(trail)
    {
        if([trail objectForKey:@"title"] != nil)
        {
            _titleTextField.text = trail[@"title"];
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height- 150)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView registerClass:[CrumbCell class] forCellReuseIdentifier:@"crumbcell"];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addcell"];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIRefreshControl *firstRefresh = [[UIRefreshControl alloc] init];
    [firstRefresh addTarget:self action:@selector(getCrumbs:) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:firstRefresh atIndex:0];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 49, 0)];
    [self.view addSubview:_tableView];
    
    
    [self getCrumbs:nil];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.text)
    {
        PFObject *trail = [[PFUser currentUser] objectForKey:@"trail"];
        [trail setObject:textField.text forKey:@"title"];
        [trail saveInBackground];
    }
}

- (void)getCrumbs:(UIRefreshControl *)sender
{
    PFUser *currentUser = [PFUser currentUser];
    PFObject *trail = [currentUser objectForKey:@"trail"];
    PFRelation *crumbsRelation = [trail relationForKey:@"crumbs"];
    PFQuery *crumbsQuery = crumbsRelation.query;
    
    
    
    [crumbsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        if(!error) {
            
            if(sender)
            {
                [sender endRefreshing];
            }
            _crumbsArray = objects;
            [_tableView reloadData];
        }
    }];
    
    
}

#pragma mark - Table view data source
//Use this to catch the initial call.  Make sure we have loaded first.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _crumbsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    PFObject *crumb = _crumbsArray[indexPath.row];
    PFGeoPoint *geopoint = crumb[@"location"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geopoint.latitude longitude:geopoint.longitude];
    
    
    CrumbCell *cell = (CrumbCell *)[tableView dequeueReusableCellWithIdentifier:@"crumbcell"];
    if (cell == nil) {
        cell = [[CrumbCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"crumbcell"];
    }
    
    //Dont have it named here.
    NSString *urlString = [NSString stringWithFormat:@"http://embed.ziggeo.com/v1/applications/%@/videos/%@/image", @"4b961928db1601a8da70022930a055b2", crumb[@"ZVideoToken"]];
    [cell.videoImageView sd_setImageWithURL:[NSURL URLWithString:urlString]];

    [cell.mapView addAnnotation:location];
    [cell.mapView setCenterCoordinate:location.coordinate];

    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.05, .05));
    [cell.mapView setRegion:region animated:NO];
    
//    [cell zoomMapViewToFitAnnotations:cell.mapView animated:NO];

    //do it here.
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    VideoPlayer *player = [[VideoPlayer alloc] initWithFrame:self.view.frame];
    [player setVideoToken:_crumbsArray[indexPath.row][@"ZVideoToken"]];
    player.vc = self;
    [self.view addSubview:player];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //What should the cell height be?
    return 150;
}


@end
