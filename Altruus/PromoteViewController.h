//
//  PromoteViewController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/21/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@interface PromoteViewController : UIViewController

@property (strong, nonatomic) NSString *qrString;
@property (strong,nonatomic) User *localUser;


// values for redeem screen. TODO need to change this to pass giftObject
@property (strong, nonatomic) NSString *giftName;
@property (strong, nonatomic) NSNumber *giftID;
@property (strong, nonatomic) NSString *giftDescription;
@property (strong, nonatomic) NSString *giftMerchantName;
@property (strong, nonatomic) NSString *giftSender;
@end
