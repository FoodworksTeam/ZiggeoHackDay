//
//  CrumbViewController.m
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import "CrumbViewController.h"
//#import "CrumbCell.h"
#import <Parse/Parse.h>

@interface CrumbViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *crumbArray;


@end

@implementation CrumbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    _tableView.backgroundColor = [UIColor whiteColor];
//    [_tableView registerClass:[CrumbCell class] forCellReuseIdentifier:@"crumbcell"];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIRefreshControl *firstRefresh = [[UIRefreshControl alloc] init];
    [firstRefresh addTarget:self action:@selector(queryForObjects:) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:firstRefresh atIndex:0];
    [self.view addSubview:_tableView];
}

#pragma mark - Table view data source
//Use this to catch the initial call.  Make sure we have loaded first.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _crumbArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *activity = _crumbArray[indexPath.row];
    PFObject *item = activity[@"item"];
    PFUser *doer = activity[@"doer"];
    
//    ActivityCell *cell = (ActivityCell *)[tableView dequeueReusableCellWithIdentifier:@"activitycell"];
//    if (cell == nil) {
//        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"activitycell"];
//    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //What should the cell height be?
    return 50;
}


@end
