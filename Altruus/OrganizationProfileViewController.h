//
//  OrganizationProfileViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/7/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friends.h"

@interface OrganizationProfileViewController : UIViewController

@property (strong,nonatomic) NSString *organizationName;
@property (nonatomic, strong) NSDictionary *organization;

@property (assign, nonatomic) Friends *friend;
@property (assign, nonatomic) BOOL vieneDeAmigos;

@end
