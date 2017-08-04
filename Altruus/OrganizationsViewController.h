//
//  OrganizationsViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/11/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friends.h"

typedef NS_ENUM(NSInteger, OrganizationType){
    OrganizationTypeBusiness = 1,
    OrganizationTypeCharity
};

@interface OrganizationsViewController : UIViewController

@property (assign) OrganizationType organizationType;
@property (assign, nonatomic) Friends *friend;
@property (assign, nonatomic) BOOL vieneDeAmigos;

@end

