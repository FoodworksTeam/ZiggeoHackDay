//
//  CrumbCell.h
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface CrumbCell : UITableViewCell

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *videoImageView;


- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated;



@end
