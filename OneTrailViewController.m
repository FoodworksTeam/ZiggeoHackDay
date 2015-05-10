//
//  OneTrailViewController.m
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import "OneTrailViewController.h"
#import "CrumbCell.h"
#import "UIImageView+WebCache.h"
#import "VideoPlayer.h"


@interface OneTrailViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITableView *tableView;


@property (strong, nonatomic)  UILabel *titleLabel;

@end

@implementation OneTrailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:239/255.0 blue:237/255.0 alpha:1.0];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 25, 30, 30)];
    [closeButton setTitle:@"X" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    closeButton.titleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:closeButton];
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2, 50, 200, 50)];
    _titleLabel.font = [UIFont systemFontOfSize:24];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.layer.cornerRadius = 6.0;
    [self.view addSubview:_titleLabel];

    if([_trail objectForKey:@"title"] != nil)
    {
        _titleLabel.text = _trail[@"title"];
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
    
    
}


- (void)getCrumbs:(UIRefreshControl *)sender
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *crumbsRelation = [_trail relationForKey:@"crumbs"];
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

    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.05, .05));
    [cell.mapView setRegion:region animated:NO];
    [cell.mapView setCenterCoordinate:location.coordinate];
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
    
    //Put a video view on the screen.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //What should the cell height be?
    return 150;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
