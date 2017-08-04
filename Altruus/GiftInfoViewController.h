//
//  GiftInfoViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/6/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "Friends.h"

typedef NS_ENUM(NSInteger, GiftingAction){
    GiftingActionRedeem = 1,
    GiftingActionSendGift,
    GiftingActionSendGiftToOneUser
};

@interface GiftInfoViewController : UIViewController

@property (strong, nonatomic) User *localUser;
@property (nonatomic, strong) NSDictionary *gift;
@property (assign) GiftingAction giftingAction;
@property (nonatomic, strong) NSString *categoryString;
@property (nonatomic, strong) NSString *userReceivingGift;
@property (nonatomic, strong) NSString *userIDReceivingGift;
@property (strong,nonatomic) Friends *friend;
@property (assign, nonatomic) BOOL vieneDeAmigos;


@end
