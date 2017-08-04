//
//  MapViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/15/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak,nonatomic) IBOutlet MKMapView *map;
@property (assign,nonatomic)CLLocationCoordinate2D coordinates;
@property (strong,nonatomic) NSString *merchantName;
@property (strong,nonatomic) NSString *merchantAddress;
@end
