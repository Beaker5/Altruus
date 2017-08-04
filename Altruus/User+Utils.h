//
//  User+Utils.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/5/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "User.h"

typedef NS_ENUM(NSInteger, APIRequestStatus)
{
    APIRequestStatusSuccess,
    APIRequestStatusFail
};

typedef NS_ENUM(NSInteger, APIProvider)
{
    APIProviderFacebook,
    APIProviderTwitter,
    APIProvideriOS
};

typedef NS_ENUM(NSInteger, FriendScreen)
{
    FriendScreenFriends,
    FriendScreenFollowers
};

typedef void (^FeedbackBlock) (APIRequestStatus status,NSString *merchant_name);
typedef void (^LoginBlock) (APIRequestStatus status,NSString *userToken,NSDictionary *userData);
typedef void (^PromoBlock) (APIRequestStatus status,id promoData);
typedef void (^PromoListBlock) (APIRequestStatus status,NSArray *gifts);
typedef void (^MerchantPromoBlock) (APIRequestStatus status,NSArray *gifts,NSString *merchant, NSNumber *friendsCount);
typedef void (^NoDataBlock) (BOOL success);
typedef void (^NoDataBlock2) (APIRequestStatus success);
typedef void (^ProviderBlock) (BOOL success);
typedef void (^FriendsBlock) (BOOL success, NSArray *friends);
typedef void (^ProvidersSocialBlock) (BOOL fbLinked, BOOL twLinked, NSString *fbToken,NSString *twToken);

@interface User (Utils)


- (NSString *)localUsername;
- (NSURL *)imageUrl;


+ (User *)createLocalUserInContext:(NSManagedObjectContext *)context;
+ (User *)getLocalUserInContext:(NSManagedObjectContext *)context;



+(User*)getLocalUserSesion:(NSManagedObjectContext*)context;
+(NSInteger)esPrimerLogueo:(NSManagedObjectContext*)context;
+(void)eliminaUsuario:(NSManagedObjectContext*)context;

// Requests

/** 
 
 Handles User Signup flow
 */
+ (void)registerWithParams:(NSDictionary *)params
                  block:(LoginBlock)block;


+ (void)getUserInfoWithBlock:(PromoBlock)block;

+ (void)submitFeedbackWithParams:(NSDictionary *)params
                           block:(FeedbackBlock)block;

+ (void)fetchUsersGiftsWithBlock:(PromoListBlock)block;




+ (void)fetchMerchantGiftsWithParams:(NSDictionary *)params
                             block:(MerchantPromoBlock)block;

+ (void)shareMerchantGiftsWithParams:(NSDictionary *)params
                               block:(PromoBlock)block;

+ (void)fetchMerchantRedeemsWithParams:(NSDictionary *)params
                               block:(MerchantPromoBlock)block;


+ (void)redeemMerchantRedeemsWithParams:(NSDictionary *)params
                                 block:(PromoBlock)block;

+ (void)fetchAllRedeemsWithBlock:(PromoListBlock)block;

+ (void)shareGiftWithParams:(NSDictionary *)params
                              block:(NoDataBlock)block;

+ (void)linkProvider:(APIProvider)provider
          withParams:(NSDictionary *)params
               block:(ProviderBlock)block;


+ (void)deleteProvider:(APIProvider)provider
                 block:(NoDataBlock)block;

+ (void)getProvidersWithBlock:(ProvidersSocialBlock)block;

+ (void)fetchFriendsOrFollowersOnScreen:(FriendScreen)screen
                              withBlock:(FriendsBlock)block;

+ (void)createFriendshipWithParams:(NSDictionary *)params
                             block:(NoDataBlock)block;

+ (void)socialShareWithParams:(NSDictionary *)params
                                  block:(NoDataBlock2)block;

// This is just a diagnostic tool for the developer to view errors;
+ (void)sendErrorToServerWithParams:(NSDictionary *)params;

@end
