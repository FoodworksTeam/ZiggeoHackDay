//
//  TrailCell.h
//  ZiggeoHackDay
//
//  Created by Michael Dee on 5/9/15.
//  Copyright (c) 2015 Michael Dee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface TrailCell : UITableViewCell

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) UILabel *titleLabel;


- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated;

@end
