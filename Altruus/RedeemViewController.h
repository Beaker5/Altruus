//
//  RedeemViewController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/23/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

typedef NS_ENUM(NSInteger, CouponScreen)
{
    CouponScreenGift,
    CouponScreenRedeem
};

@interface RedeemViewController : UIViewController

@property (strong,nonatomic) User *localUser;
@property (strong, nonatomic) NSString *qrString;
@property (strong, nonatomic) NSString *merchant_name;
@property (strong,nonatomic) NSString *shareText;
@property (strong, nonatomic) NSNumber *redeemID;
@property (strong,nonatomic) NSString *confirmation_number;
@property (assign,nonatomic) CouponScreen screenType;
@end
