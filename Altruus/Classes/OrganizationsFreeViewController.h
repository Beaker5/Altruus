//
//  OrganizationsFreeViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 07/11/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friends.h"

typedef NS_ENUM(NSInteger, OrganizationType){
    OrganizationTypeBusiness = 1,
    OrganizationTypeCharity
};

@interface OrganizationsFreeViewController : UIViewController

@property (assign) OrganizationType organizationType;
@property (assign, nonatomic) Friends *friend;
@property (assign, nonatomic) BOOL vieneDeAmigos;

@end
