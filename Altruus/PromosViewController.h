//
//  PromosViewController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/15/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

typedef NS_ENUM(NSInteger, PromosScreen)
{
    PromosScreenGifts,
    PromosScreenRedeem,
    PromosScreenLast,
    PromosScreenAll
};

@interface PromosViewController : UIViewController
@property (strong,nonatomic) User *localUser;
@property (assign,nonatomic) PromosScreen screenType;
@property (strong,nonatomic) NSString *qr_string;
@end
