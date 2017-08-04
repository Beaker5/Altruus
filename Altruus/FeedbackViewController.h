//
//  FeedbackViewController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/20/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

typedef NS_ENUM(NSInteger, FeedbackScreen)
{
    FeedbackScreenFacebookAndTwitter,
    FeedbackScreenFeedback
};

typedef NS_ENUM(NSInteger, GiftResult)
{
    GiftResultGift,
    GiftResultGiftAndRedeem
};

@interface FeedbackViewController : UIViewController

@property (strong, nonatomic) NSString *qrString;
@property (strong,nonatomic) User *localUser;
@property (strong, nonatomic) NSString *merchant_name;
@property (assign) FeedbackScreen screenType;
@property (assign) GiftResult result;

@property (strong, nonatomic) NSNumber *redeemID;
@end
