//
//  MapViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/15/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "MapViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"

@interface MapViewController ()<MKMapViewDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.map.showsUserLocation = YES;
    
    [self setup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = {self.coordinates,span};
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.coordinates;
    annotation.title = self.merchantName;
    [self.map addAnnotation:annotation];
    self.map.centerCoordinate = self.coordinates;
    self.map.region = region;
    
    self.titleLabel.text = self.merchantAddress;
    self.titleLabel.textColor = [UIColor colorWithHexString:kColorBlue];
    self.titleLabel.font = [UIFont fontWithName:kAltruusFont size:20];
    
    self.navigationItem.title = self.merchantName;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
