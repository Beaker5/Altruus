//
//  QRScreenViewController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/19/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "ProfileController.h"

typedef NS_ENUM(NSInteger, QRScreenType)
{
    QRScreenTypeGift,
    QRScreenTypeRedeem
};

@interface QRScreenViewController : UIViewController

@property (assign,nonatomic)QRScreenType screenType;
@property (strong,nonatomic) User *localUser;
@property (strong,nonatomic) NSString *qrString;

@end
