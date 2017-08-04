//
//  APIClient.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/6/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "AFHTTPSessionManager.h"

// Base
static NSString * const APIBaseUrlString = @"https://abundance.altruus.com/api/v1/";
//static NSString * const APIBaseUrlString = @"http://45.55.229.174/api/v1/";

// Endpoints
static NSString * const APICurrentUserString = @"consumer/current";
static NSString * const APIFeedbackString = @"consumer/feedbacks/scan";
static NSString * const APIRegisterString = @"consumer/register";
static NSString * const APIUserGiftsString = @"consumer/gifts";
static NSString * const APIProvidersString = @"consumer/providers";
static NSString * const APIErrorsString = @"consumer/errors";
static NSString * const APIRedemptionString = @"consumer/redemptions";

// Friends
static NSString * const APICreateFriendsString = @"consumer/friendships";
static NSString * const APIFriendsString = @"consumer/friends";
static NSString * const APIFollowersString = @"consumer/followers";

// Gift Button
static NSString * const APIMerchantGiftScanString = @"consumer/promotions/scan";
static NSString * const APIMerchantGiftShareString = @"consumer/promotions/share";

// Redeem Button
static NSString * const APIRedeemScanString = @"consumer/gifts/scan";
static NSString * const APIRedeemConfirmString = @"consumer/gifts/redeem";

static NSString * const APISocialShareString = @"consumer/socials/share";

@interface APIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)startMonitoringConnection;

- (void)stopMonitoringConnection;

- (void)startNetworkActivity;

- (void)stopNetworkActivity;

@end
