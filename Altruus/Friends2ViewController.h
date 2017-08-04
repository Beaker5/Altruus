//
//  Friends2ViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "GiftInfoViewController.h"

typedef NS_ENUM(NSInteger, FriendListType)
{
    FriendListTypeChooseFriend = 1,
    FriendListTypeViewFriends
};

typedef NS_ENUM(NSInteger, ContactListType) {
    ContactListTelephone = 0,
    ContactListAltruus
};

@interface Friends2ViewController : UIViewController


@property (assign) FriendListType friendListType;
@property (assign) BOOL showBackButton;
@property (assign) BOOL comingFromNavPush;

@property (assign) BOOL estaFacebook;

@property (nonatomic, strong) NSString *categoryString;
@property (assign) NSDictionary *gift;
@property (assign) User *localUser;

@property (assign) GiftingAction giftingAction;


@end
