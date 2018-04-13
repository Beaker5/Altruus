//
//  AppDelegate.m
//  Altruus
//
//  Created by CJ Ogbuehi on 3/30/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "EasyFacebook.h"
#import "constants.h"
#import "User+Utils.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <JDStatusBarNotification.h>
#import <Tweaks/FBTweakShakeWindow.h>
#import <Branch.h>
#import <IQKeyboardManager.h>
#import <OneSignal/OneSignal.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Stripe/Stripe.h>
#import "Servicios.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const kLocalUserCreated = @"createdLocalUser";

@interface AppDelegate ()

@property (assign) BOOL appInForeground;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    */
    // Global appearance
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor altruus_darkSkyBlueColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor altruus_darkSkyBlueColor]}];
    
    //the color for the text for unselected tabs
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor altruus_bluegreyColor]} forState:UIControlStateNormal];
    
    [Stripe setDefaultPublishableKey:@"pk_live_6wEPvr7EvsQLKFuOWwPjRTr8"]; //Producción
    //[Stripe setDefaultPublishableKey:@"pk_test_mbNdkqdHkyz6d5CB9SZYlaUQ"]; //Prueba


   //[OneSignal setLogLevel:ONE_S_LL_VERBOSE visualLevel:ONE_S_LL_WARN]; //comentè
    
    id notificationRecievedBlock = ^(OSNotification *notification) {
        //NSLog(@"Received Notification - %@", notification.payload.notificationID);
    };
    
    
    id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
        /*
        OSNotificationPayload* payload = result.notification.payload;
        
        NSString* messageTitle = @"OneSignal Example";
        NSString* fullMessage = [payload.body copy];
        
        if (payload.additionalData) {
            
            if (payload.title)
                messageTitle = payload.title;
            
            if (result.action.actionID)
                fullMessage = [fullMessage stringByAppendingString:[NSString stringWithFormat:@"\nPressed ButtonId:%@", result.action.actionID]];
        }
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:messageTitle
                                                            message:fullMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
         */
    };
    
    id oneSignalSetting = @{kOSSettingsKeyInFocusDisplayOption : @(OSNotificationDisplayTypeNotification), kOSSettingsKeyAutoPrompt : @YES};
    
    
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:@"f9631098-4028-4c90-9902-da39815db34f"
          handleNotificationReceived:notificationRecievedBlock
            handleNotificationAction:notificationOpenedBlock
                            settings:oneSignalSetting];
    
    [OneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        if (pushToken)
            //_pushId = pushToken;
            _pushId = userId;
        NSLog(@"**************************************************************************");
        NSLog(@"pushID Delegate: %@, UserID: %@", _pushId, userId);
    }];
    if (_pushId == NULL || _pushId == nil || !_pushId || _pushId == (id)[NSNull null] || [_pushId isEqualToString:@"(null)"]) {
        _pushId = @"f9631098-4028-4c90-9902-da39815db34f";
    }
    
    //_pushId = @"f9631098-4028-4c90-9902-da39815db34f";
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    //self.accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        //dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            //self.accessGranted = granted;
            //dispatch_semaphore_signal(semaphore);
        });
        //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //        dispatch_release(semaphore);
    }
    
   /*
    // Right slide out menu setup
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"gifts"
                                                             bundle: nil];
    UIViewController *menu = [mainStoryboard instantiateViewControllerWithIdentifier:@"menu2"];
    if (menu){
        //SlideNavigationContorllerAnimatorSlideAndFade *slideAnimation = [[SlideNavigationContorllerAnimatorSlideAndFade alloc] initWithMaximumFadeAlpha:.8 fadeColor:[UIColor altruus_skyBlueColor] andSlideMovement:100];
        
        //SlideNavigationContorllerAnimatorScaleAndFade *scaleAnimation = [[SlideNavigationContorllerAnimatorScaleAndFade alloc] initWithMaximumFadeAlpha:.8 fadeColor:[UIColor colorWithHexString:kColorYellow] andMinimumScale:1];
        
        //[SlideNavigationController sharedInstance].menuRevealAnimator = slideAnimation;
        [SlideNavigationController sharedInstance].leftMenu = menu;
    }
    */
    
    
    // Keyboard manager - for UITextfields
    [IQKeyboardManager sharedManager].enable = YES;
    
    // Notifications
    //if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) { //COMENTÉ 100517
        // use registerUserNotificationSettings
        
        //[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]]; //COMENTÉ 100517
        
        //[application registerForRemoteNotifications];//COMENTÉ 100517
        
    //} else {//COMENTÉ 100517
        // use registerForRemoteNotificationTypes:
        
        //[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];//COMENTÉ 100517
    //} //COMENTÉ 100517
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]){
        self.appInForeground = YES;
    }
    
    //Facebook stuff
    //[EasyFacebook application:application didFinishLaunchingWithOptions:launchOptions]; //Comenté 170717
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [[Branch getInstance] setDebug]; // for debug and development only
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            //NSLog(@"params: %@", params.description);
            NSString *userID = params[@"userID"];
            if (userID){
                [self createFriendshipWithUserID:userID];
            }
            
        }
    }];

    
    /* //comente
    // Fabric
    [Fabric with:@[[Crashlytics class]]];
    
    // Branch.io stuff
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            //NSLog(@"params: %@", params.description);
            NSString *userID = params[@"userID"];
            if (userID){
                [self createFriendshipWithUserID:userID];
            }
            
        }
    }];
    */
    
    
     //COMENTE 170517
    @try {
        // Create initial user
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults boolForKey:kLocalUserCreated]){
            // First time in app
            [User createLocalUserInContext:self.managedObjectContext];
            [defaults setBool:YES forKey:kLocalUserCreated];
            NSLog(@"Se creó usuario inicial");
        }
    } @catch (NSException *exception) {
        NSLog(@"Error al crear usuario inicial: %@", exception.reason);
    } @finally {
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // pass the url to the handle deep link call
    [[Branch getInstance] handleDeepLink:url];
    
    //BOOL wasHandled1 = [EasyFacebook application:application openURL:url sourceApplication:sourceApplication annotation:annotation]; //Comenté 170717
    
    //return wasHandled1; //Comenté 170717
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    return handledByBranch;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // handler for Push Notifications
    [[Branch getInstance] handlePushNotification:userInfo];
}

// Push Notification code
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    NSDictionary *params = @{@"uid":@"mobile",
                             @"token":token,
                             @"name":@"mobile_device_token"};
    
    [User linkProvider:APIProvideriOS
            withParams:params block:^(BOOL success) {
                if (success){
                    DLog(@"sent device token");
                }
                else{
                    DLog(@"failed to send device token");
                }
            }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self notifyReceivedRemoteNotificationWithData:userInfo foreground:self.appInForeground];
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.altruusapp.Altruus" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Altruus" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Altruus.sqlite"];
    
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - UIWindow

- (UIWindow *)window
{
    if (!_window){
        _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return _window;
}
#pragma mark - App delegate custom
+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Branch.io stuff
- (void)createFriendshipWithUserID:(NSString *)userID
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInviteFriendNotification object:self userInfo:@{@"userID":userID}];
    DLog(@"create friend with id %@",userID);
}

#pragma mark - Push Notifications

- (void)notifyReceivedRemoteNotificationWithData:(NSDictionary *)data
                                      foreground:(BOOL)foreground
{
    // Notify home controller that a notification came in 
    //NSMutableDictionary *mutableData = [data mutableCopy];
    //mutableData[@"foreground"] = [NSNumber numberWithBool:foreground];

    //[[NSNotificationCenter defaultCenter] postNotificationName:kRecievedRemoteNotification object:self userInfo:mutableData];
    
    NSString *styleName = @"basicNotification";
    NSString *alert = data[@"alert"];
    [JDStatusBarNotification addStyleNamed:styleName
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = [UIColor colorWithHexString:kColorGreen];
                                       style.textColor = [UIColor whiteColor];
                                       style.font = [UIFont fontWithName:kAltruusFontBold size:13];
                                       
                                       return style;
                                   }];
    
    if (![alert isEqualToString:@""]){
        [JDStatusBarNotification showWithStatus:alert dismissAfter:4 styleName:styleName];
    }
    
    
    
}

@end
