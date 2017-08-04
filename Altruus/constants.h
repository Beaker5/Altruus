//
//  constants.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/1/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#ifndef Altruus_constants_h
#define Altruus_constants_h


#endif

//global imports
#import "UIColor+HexValue.h"
#import "UIColor+ALTRUUSAdditions.h"
#import "UIFont+ALTRUUSAdditions.h"


// useful stuff
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define IS_IOS8 ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]?YES:NO)

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif


static NSInteger *const kUSVersion = 0;

// Support v2
static NSString *const kAltruusSupportEmail = @"altruus@altruus.com";
static NSString *const kAltruusAppID = @"id1020419872";

// Local user stored in defaults
static NSString *const kAltruusLocalUser = @"localuser";
static NSString *const kAltruusLocalUserAuthKey = @"localauthkey";

//The Altruus logo
static NSString *const kAltruusDisplayLogo = @"Logo1";
static NSString *const kAltruusBannerLogo = @"Logo2";

//Icons
static NSString *const kIconFacebook = @"FB-Icon";
static NSString *const kIconTwitter = @"TW-Icon";
static NSString *const kIconInstagram = @"IG-Icon";

static NSString *const kIconHomeGifts = @"Tab-gift";

// Invite Text
static NSString *const kBranchFirstLogin = @"kBranchFirstLogin";
static NSString *const kBranchInviteUser = @"kBranchInviteUser";
static NSString *const kAltruusInviteLink = @"http://altruus.com/mobile";
static NSString *const kAltruusInviteText = @"I just sent you a gift! Download Altruus from the following link to redeem";

//Images
static NSString *const kAltruusFBIconUserProfile = @"FB-userPhoto";
static NSString *const kAltruusAddFriendButton = @"addFriendButton";
static NSString *const kAltruusSentGiftPicture = @"Sent-gift";
static NSString *const kAltruusRedeemGiftPicture = @"Redeem-gift";


//Profile Pic Border and Path for local file
static NSString *const kAltruusProfile = @"Profile-Border";
static NSString *const kAltruusProfilePicPath = @"profilePicPathd";
static NSString *const kAltruusProfilePicFile = @"profilePic.png";

//Global Colors
static NSString *const kColorYellow = @"#f5ac1d";
static NSString *const kColorGreen = @"#4e8c8c";
static NSString *const kColorBlue = @"#0a2340";
static NSString *const kColorBlack = @"#34495e";

// StoryBoards
static NSString *const kStoryboardLogin = @"login";
static NSString *const kStoryboardBaseProfile = @"baseProfile";
static NSString *const kStoryboardProfile = @"profile";
static NSString *const kStoryboardSignup = @"signup";
static NSString *const kStoryboardMenu = @"menu";
static NSString *const kStoryboardQRScreen = @"qrscreen";
static NSString *const kStoryboardFeedbackScreen = @"feedback";
static NSString *const kStoryboardPromoteScreen = @"promote";
static NSString *const kStoryboardRedeemScreen = @"redeem";
static NSString *const kStoryboardPromosScreen = @"promos";
static NSString *const kStoryboardTermsScreen = @"terms";
static NSString *const kStoryboardFriendsScreen = @"friends";
static NSString *const kStoryboardMapScreen = @"map";
static NSString *const kStoryboardBaseMapScreen = @"mapRoot";

// StoryBoards v2
static NSString *const kV2StoryboardLogin = @"login-v2";
static NSString *const kV2StoryboardMyProfile = @"myProfile";
static NSString *const kV2StoryboardFriendProfile = @"friendProfile";
static NSString *const kV2StoryboardFriendsList = @"friendsList";
static NSString *const kV2StoryboardGiftInfo = @"giftInfo";
static NSString *const kV2StoryboardUpdates = @"updates";
static NSString *const kV2StoryboardGiftsHome = @"giftsHome";
static NSString *const kV2StoryboardRedeem = @"redeemGift";
static NSString *const kV2StoryboardOrganizationProfile = @"organizationProfile";
static NSString *const kV2StoryboardAbout = @"about";
static NSString *const kV2StoryboardIntroConroller = @"introController";

//Global Font
static NSString *const kAltruusFont = @"Futura-CondensedMedium";
static NSString *const kAltruusFontBold = @"Futura-CondensedExtraBold";

// Add Futura Bold

static NSString *const kUserLoggedIn = @"logged";
static NSString *const kUserIsFacebook = @"isFB";
static NSString *const kUserFirstLogin = @"firstLogin";
static NSString *const kUserModelBlob = @"userblob";


// Notifications
static NSString *kRecievedRemoteNotification = @"kRecievedRemoteNotification";
static NSString *kToggleFacebookNotification = @"ToggleFacebookNotification";
static NSString *kToggleTwitterNotification = @"ToggleTwitterNotification";
static NSString *kFeedbackDisplayNotification = @"FeedbackDisplayNotification";
static NSString *kStoreQRCodeNotification = @"kStoreQRCodeNotification";
static NSString *kPurgeQRCodeNotification = @"kPurgeQRCodeNotification";
static NSString *kInviteFriendNotification = @"kInviteFriendNotification";
static NSString *kUserIDSetNotification = @"kUserIDSetNotification";

// Notifications v2
static NSString *kV2NotificationRedeemDone = @"kV2NotificationRedeemDone";
static NSString *kV2NotificationIntroScreenDone = @"kV2NotificationIntroScreenDone";
static NSString *kV2UserLoggedOut = @"kV2UserLoggedOut";

// Logged in v2
static NSString *const kv2LocalUserLoggedIn = @"loggedIn";

// Colors v2
static NSString *const kv2ColorFacebookBlue = @"3B5998";
