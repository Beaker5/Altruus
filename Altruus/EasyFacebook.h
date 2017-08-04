#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>



@protocol EasyFacebookDelegate;

static NSString *EasyFacebookLoggedInNotification = @"EasyFacebookLoggedInNotification";
static NSString *EasyFacebookUserInfoFetchedNotification = @"EasyFacebookUserInfoFetchedNotification";
static NSString *EasyFacebookLoggedOutNotification = @"EasyFacebookLoggedOutNotification";
static NSString *EasyFacebookUserCancelledLoginNotification = @"EasyFacebookUserCancelledLoginNotification";
static NSString *EasyFacebookPublishPermissionGrantedNotification = @"EasyFacebookPublishPermissionGrantedNotification";
static NSString *EasyFacebookPublishPermissionDeclinedNotification = @"EasyFacebookPublishPermissionDeclinedNotification";
static NSString *EasyFacebookStoryPublishedNotification = @"EasyFacebookStoryPublishedNotification";

@interface EasyFacebook : NSObject

    + (EasyFacebook *)sharedEasyFacebookClient;
    @property (nonatomic, weak) id<EasyFacebookDelegate>delegate;

    //Required Read Permissions.
    @property (strong) NSArray *readPermissions;

    /*
    Quick Check is only 99% accurate. It checks the permissions granted to the access token.
    These could have changed since the access token was issued. They could also be changed
    by the user on the FB website external to the app.
    */
    - (BOOL)isPublishPermissionsAvailableQuickCheck; //Quicker (and usually good enough)

    - (void)requestPublishPermissions:(void(^)(BOOL granted, NSError *error))responseHandler;

    //Actions

    /*
    If you want to publish an entry into users timeline (i.e. sharing).
    See:
    https://developers.facebook.com/docs/ios/share#link
    https://developers.facebook.com/docs/reference/ios/current/class/FBLinkShareParams
     
    Example:
    
    NSDictionary *params = @{@"link" : @"the url we want to share.",
        @"name" : @"a title.",
        @"caption" : @"a subtitle.",
        @"picture" : @"the url of a thumbnail to associate with the post.",
        @"description" : @"a snippet of text describing the content of the link.",
        @"message" : @"main message appears above everything else"
    };
     
    */

    //- (void)shareWithDescription:(NSString *)params completion:(void(^)(BOOL success, NSError *error))completion;

    //Diagnostics
    @property BOOL preventAppShutDown;

    //Log in/out

    - (void)logIn; //For loggin on
    - (void)logOut; //For logging out
    - (BOOL)isLoggedIn; //For checking logged on status

    //Handle State Changes
    - (void)loginStateChangeWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error;


    //Add to AppDelegate

    + (BOOL)application:(UIApplication *) application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
    + (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;


    //User's Basic Details
    - (void)fetchUserInformation;
    @property NSString *UserEmail;
    @property NSString *UserFirstName;
    @property NSString *UserGender;
    @property NSString *UserObjectID;
    @property NSString *UserLastName;
    @property NSString *UserLink;
    @property NSString *UserLocale;
    @property NSString *UserName;
    @property NSString *UserTimeZone;
    @property NSString *UserVerified;
@end



@protocol EasyFacebookDelegate <NSObject>
@optional
    - (void)showLoadingScreen:(id)sender;
    - (void)hideLoadingScreen:(id)sender;
@end
