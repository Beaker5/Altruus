//
//  RedeemGiftViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/6/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RedeemScreenType)
{
    RedeemScreenTypeRedeemGift = 1,
    RedeemScreenTypeSentGift,
};

@interface RedeemGiftViewController : UIViewController

@property (strong,nonatomic) NSString *confirmationNumber;
@property (assign) RedeemScreenType screenType;


@end
