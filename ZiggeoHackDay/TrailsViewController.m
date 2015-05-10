//
//  TrailsViewController.m
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import "TrailsViewController.h"
#import <Parse/Parse.h>
#import "TrailCell.h"
#import "OneTrailViewController.h"


@interface TrailsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *trailsArray;
@property (strong, nonatomic) NSMutableDictionary *crumbsArrays;



@end

@implementation TrailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:239/255.0 blue:237/255.0 alpha:1.0];

    _crumbsArrays = [[NSMutableDictionary alloc] init];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView registerClass:[TrailCell class] forCellReuseIdentifier:@"trailcell"];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIRefreshControl *firstRefresh = [[UIRefreshControl alloc] init];
    [firstRefresh addTarget:self action:@selector(getTrails:) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:firstRefresh atIndex:0];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 49, 0)];
    [self.view addSubview:_tableView];
    
    
    [self getTrails:nil];

}

- (void)getTrails:(UIRefreshControl *)sender
{

    PFQuery *trailsQuery = [PFQuery queryWithClassName:@"Trail"];
    [trailsQuery orderByAscending:@"CreatedAt"];
    
    [trailsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            
            if(sender)
            {
                [sender endRefreshing];
            }
            _trailsArray = objects;
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
    return _trailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TrailCell *cell = (TrailCell *)[tableView dequeueReusableCellWithIdentifier:@"trailcell"];
    if (cell == nil) {
        cell = [[TrailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"trailcell"];
    }
    
    PFObject *trail = _trailsArray[indexPath.row];
    //We need to get the trails now.
    
    PFRelation *crumbs = [trail relationForKey:@"crumbs"];
    
    [crumbs.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects) {
            
            [_crumbsArrays setObject:objects forKey:indexPath];
            
            //We want to know which crumb he is at for this one.
            PFObject *crumb = objects[0];
            
            PFGeoPoint *geopoint = crumb[@"location"];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geopoint.latitude longitude:geopoint.longitude];
            
            cell.titleLabel.text = trail[@"title"];
            
            //Dont have it named here.
            [cell.mapView addAnnotation:location];
            [cell.mapView setCenterCoordinate:location.coordinate];
            [cell zoomMapViewToFitAnnotations:cell.mapView animated:NO];
        }
    }];
    
    //do it here.
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Present the other one.

    OneTrailViewController *vc = [[OneTrailViewController alloc] init];
    vc.trail = _trailsArray[indexPath.row];
    vc.crumbsArray = _crumbsArrays[indexPath];
    [self presentViewController:vc animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //What should the cell height be?
    return 150;
}


@end
