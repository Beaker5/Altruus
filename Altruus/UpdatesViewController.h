//
//  UpdatesViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/2/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UpdateType)
{
    UpdateTypeFriends = 1,
    UpdateTypeYou,
    UpdateTypeCompany
};

typedef NS_ENUM(NSInteger, ScreenType)
{
    ScreenTypeUpdates = 1,
    ScreenTypeGiftsSent,
    ScreenTypeGiftsReceived,
};

@interface UpdatesViewController : UIViewController

@property (assign) BOOL showBackButton;
@property (assign) ScreenType screenType;


@end
