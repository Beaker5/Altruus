//
//  MenuController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/2/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "MenuController.h"
#import "AppDelegate.h"
#import "constants.h"
#import "CODefaultsHelper.h"
#import "COUtils.h"
#import "EasyFacebook.h"
#import "User+Utils.h"
#import "SlideNavigationController.h"
#import "FriendsViewController.h"
#import "PromosViewController.h"
#import "TermsWebViewController.h"
#import <UIDevice+BFKit.h>
#import <SCLAlertView.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import "CObutton.h"
#import <Branch.h>
#import <Crashlytics/Answers.h>

typedef NS_ENUM(NSInteger, ToggleSocial)
{
    ToggleSocialFacebook,
    ToggleSocialTwitter
};


@interface MenuController()

@property (strong,nonatomic) User *localUser;
@property (weak, nonatomic) IBOutlet CObutton *promosButton;
@property (weak, nonatomic) IBOutlet CObutton *logoutButton;
@property (weak, nonatomic) IBOutlet CObutton *termButton;
@property (weak, nonatomic) IBOutlet CObutton *friendsButton;

@property (weak, nonatomic) IBOutlet CObutton *inviteButton;

@property (weak, nonatomic) IBOutlet CObutton *locationsButton;

//icons
@property (weak, nonatomic) IBOutlet UIImageView *instagramIcon;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIcon;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;



// switches
@property (weak, nonatomic) IBOutlet UISwitch *instagramSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceSelectLabelConstraint;

@property BOOL facebookIsLoggingIn;
@property BOOL nonFacebookIsLoggingIn;

@end
@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    [self listenForNotifs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    [self.instagramIcon setImage:nil];
    [self.facebookIcon setImage:nil];
    [self.twitterIcon setImage:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setup

{
    // hide twitter button
    self.twitterSwitch.hidden = YES;
    self.twitterSwitch.alpha = 0;
    self.twitterIcon.hidden = YES;
    self.twitterIcon.alpha = 0;
    // since label isnt a property, scan for it then hide i
    for (UIView *view in self.view.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            UILabel *label = (UILabel *)view;
            if ([label.text isEqualToString:NSLocalizedString(@"TWITTER", nil)]){
                label.hidden = YES;
                label.alpha = 0;
            }
        }
    }
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    //self.localUser = [User getLocalUserInContext:context];
    self.localUser = [User getLocalUserSesion:context];
    
    [COUtils convertButton:self.promosButton withText:NSLocalizedString(@"GIFTS", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    [COUtils convertButton:self.logoutButton withText:NSLocalizedString(@"LOG OUT", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    
    [COUtils convertButton:self.termButton withText:NSLocalizedString(@"TERMS", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    [COUtils convertButton:self.friendsButton withText:NSLocalizedString(@"FRIENDS", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    [COUtils convertButton:self.inviteButton withText:NSLocalizedString(@"INVITE", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    [COUtils convertButton:self.locationsButton withText:NSLocalizedString(@"LOCATIONS", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    
    BOOL fbon = NO;
    if ( [self.localUser.fbPostPermission boolValue] || [EasyFacebook sharedEasyFacebookClient].isPublishPermissionsAvailableQuickCheck){
        fbon = YES;
    }
    self.instagramSwitch.on = [self.localUser.linkedIG boolValue];
    self.facebookSwitch.on = fbon;
    self.twitterSwitch.on = [self.localUser.linkedTW boolValue];
    
    if (IS_IPHONE_6 || IS_IPHONE_6P){
        self.topSpaceSelectLabelConstraint.constant = 50;
    }
    
}

- (void)listenForNotifs
{
    // Listen for this notification to know when menu closes (for logout)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillOpen) name:SlideNavigationControllerDidReveal object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFacebookLogin:)
                                                 name:EasyFacebookUserInfoFetchedNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markFacebookLogin)
                                                 name:EasyFacebookLoggedInNotification object:nil];
}



- (IBAction)tappedLogout:(UIButton *)sender {
    // ask if they are sure first then continue
    
    [self logout];
}


- (IBAction)tappedTerms:(UIButton *)sender {
    UIViewController *terms = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardTermsScreen];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:terms withCompletion:nil];

}

- (IBAction)tappedPromos:(UIButton *)sender {
    UIViewController *promoVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardPromosScreen];
    if ([promoVC isKindOfClass:[PromosViewController class]]){
        ((PromosViewController *)promoVC).localUser = self.localUser;
        ((PromosViewController *)promoVC).screenType = PromosScreenAll;
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:promoVC withCompletion:nil];
}

- (IBAction)tappedFriends:(id)sender {
    UIViewController *friendsVc = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardFriendsScreen];
    if ([friendsVc isKindOfClass:[FriendsViewController class]]){
        ((FriendsViewController *)friendsVc).localUser = self.localUser;
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:friendsVc withCompletion:nil];
}

- (IBAction)tappedInvite:(id)sender {
    //NSString *inviteText = [NSString stringWithFormat:@"I just sent you a gift! Download Altruus from the following link to redeem."];
    //NSString *inviteText = [NSString stringWithFormat:@"Become happier by becoming a giver! Download Altrüus from the following link:"];
    NSString *inviteText = NSLocalizedString(@"Become happier by becoming a giver! Download Altrüus from the following link:", nil);
    if (![self.localUser.userID boolValue]){
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"Please log out and then log back in to use the new invite feature!", nil)];
    }
    
    NSDictionary *params = @{@"userID":self.localUser.userID,
                             @"username":self.localUser.username};
    
    UIActivityItemProvider *itemProvider = [Branch getBranchActivityItemWithParams:params
                                                                           feature:@"invite_friends"
                                                                             stage:@"pre_invite"];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[inviteText,itemProvider] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToTwitter,UIActivityTypeAirDrop];
    //[self presentViewController:activityVC animated:YES completion:nil];
    
    if (IS_IPAD){
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)]){
            activityVC.popoverPresentationController.sourceView = self.view;
            
        }
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:(@selector(setCompletionWithItemsHandler:))]){
        // If above iOS 7
        [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *error){
            if (!completed){
                return;
            }
            
            [Answers logInviteWithMethod:@"Invited_Friends" customAttributes:@{@"invited_using":activityType,
                                                                               @"name":self.localUser.username,
                                                                               @"email":self.localUser.email}];
            
        }];
        
    }
    else{
        // iOS 7 or below
        [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed){
            if (!completed){
                return;
            }
            
            [Answers logInviteWithMethod:@"Invited_Friends" customAttributes:@{@"invited_using":activityType,
                                                                               @"name":self.localUser.username,
                                                                               @"email":self.localUser.email}];
        }];
        
    }
    
    
    [[SlideNavigationController sharedInstance] presentViewController:activityVC animated:YES completion:^{
        // something

    }];

}

- (IBAction)tappedLocations:(id)sender {
    FAKIonIcons *alertIcon = [FAKIonIcons alertIconWithSize:30];
    [alertIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *alertImage = [alertIcon imageWithSize:CGSizeMake(30, 30)];

    
    NSString *title = NSLocalizedString(@"Next Update", nil);
    NSString *subtitle = NSLocalizedString(@"List of businesses coming soon!", nil);
    NSString *closeButton = NSLocalizedString(@"OK", nil);
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    //alert.showAnimationType = SlideInFromCenter;
    //alert.hideAnimationType = SlideInToCenter;
    [alert showCustom:alertImage color:[UIColor colorWithHexString:kColorYellow] title:title subTitle:subtitle closeButtonTitle:closeButton duration:0.0f];
    //[alert showInfo:title subTitle:subtitle closeButtonTitle:closeButton duration:0.0f];
    
}


- (IBAction)swipedIGSwtich:(UISwitch *)sender {
    CODefaultsHelper *helper = [CODefaultsHelper new];
    [helper addBool:sender.on forKey:kIconInstagram];
    
    self.localUser.linkedIG = [NSNumber numberWithBool:sender.on];
    [self.localUser.managedObjectContext save:nil];
}

- (IBAction)swipedFBSwitch:(UISwitch *)sender {
    CODefaultsHelper *helper = [CODefaultsHelper new];
    [helper addBool:sender.on forKey:kIconFacebook];
    
    if (sender.on){
        
        if (![self.localUser.fbUser boolValue]){
            self.nonFacebookIsLoggingIn = YES;
            [[EasyFacebook sharedEasyFacebookClient] logIn];
            
        }
        
        else if (![EasyFacebook sharedEasyFacebookClient].isPublishPermissionsAvailableQuickCheck){
            [[EasyFacebook sharedEasyFacebookClient] requestPublishPermissions:^(BOOL granted, NSError *error) {
                    if (granted){
                        
                        // send server oauth data
                        NSMutableDictionary *fbDict = [@{} mutableCopy];
                        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
                        NSString *uID = [FBSDKAccessToken currentAccessToken].userID;
                        NSString *username = self.localUser.username;
                        
                        if (token){
                            fbDict[@"token"] = token;
                        }
                        if (uID){
                            fbDict[@"uid"] = uID;
                        }
                        if (username){
                            fbDict[@"name"] = username;
                        }
                        NSDictionary *params = @{@"provider":fbDict};
                        [User linkProvider:APIProviderFacebook
                                withParams:params
                                     block:^(BOOL success) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                             if (success){
                                                     self.localUser.linkedFB = [NSNumber numberWithBool:YES];
                                                     self.localUser.fbPostPermission = [NSNumber numberWithBool:YES];
                                                     self.facebookSwitch.on = YES;
                                                    [self sendNotificationForSocial:ToggleSocialFacebook];
                                                
                                             }
                                             else{
                                                 self.localUser.linkedFB = [NSNumber numberWithBool:NO];
                                                 self.localUser.fbPostPermission = [NSNumber numberWithBool:NO];
                                                 self.facebookSwitch.on = NO;
                                                 NSString *title = NSLocalizedString(@"Error", nil);
                                                 NSString *message = NSLocalizedString(@"There was an error linking your Facebook account", nil);
                                                 [self showMessageWithTitle:title andMessage:message];
                                             }
                                         });
                                         
                                     }];
                    }
                    else{
                        DLog(@"error is %@",error.localizedDescription);
                        self.localUser.linkedFB = [NSNumber numberWithBool:NO];
                        self.localUser.fbPostPermission = [NSNumber numberWithBool:NO];
                        [self.localUser.managedObjectContext save:nil];
                        self.facebookSwitch.on = NO;
                        NSString *developerMessage = error.userInfo[FBSDKErrorDeveloperMessageKey];
                        NSString *userMessage = error.userInfo[FBSDKErrorLocalizedDescriptionKey];
                        if (!userMessage){
                            userMessage = NSLocalizedString(@"Altruus was denied access to Facebook. Go to Facebook in your phone settings and allow Altruus access.", nil);
                        }
                        NSString *title = NSLocalizedString(@"Error", nil);
                        [self showMessageWithTitle:title andMessage:userMessage];
                        
                        NSString *fullErrorMessage = [NSString stringWithFormat:@"User message (FB):%@\nDeveloper message (FB):%@",userMessage,developerMessage];
                        [self sendError:fullErrorMessage];
                    }

            }];
        }
        else{
            // Alredy have the facebook permission so just get tokens and send
            NSMutableDictionary *fbDict = [@{} mutableCopy];
            NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
            NSString *uID = [FBSDKAccessToken currentAccessToken].userID;
            NSString *username = self.localUser.username;
            
            if (token){
                fbDict[@"token"] = token;
            }
            if (uID){
                fbDict[@"uid"] = uID;
            }
            if (username){
                fbDict[@"name"] = username;
            }
            
            NSDictionary *params = @{@"provider":fbDict};
            [User linkProvider:APIProviderFacebook
                    withParams:params
                         block:^(BOOL success) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (success){
                                     self.localUser.linkedFB = [NSNumber numberWithBool:YES];
                                     self.localUser.fbPostPermission = [NSNumber numberWithBool:YES];
                                     self.facebookSwitch.on = YES;
                                     [self sendNotificationForSocial:ToggleSocialFacebook];
                                     
                                 }
                                 else{
                                     self.localUser.linkedFB = [NSNumber numberWithBool:NO];
                                     self.localUser.fbPostPermission = [NSNumber numberWithBool:NO];
                                     self.facebookSwitch.on = NO;
                                     NSString *title = NSLocalizedString(@"Error", nil);
                                     NSString *message = NSLocalizedString(@"There was an error linking your Facebook account", nil);
                                     [self showMessageWithTitle:title andMessage:message];
                                 }
                                 
                             });

                         }];
        }
    }
    else{
        [User deleteProvider:APIProviderFacebook
                       block:^(BOOL success) {
                           if (success){
                               self.localUser.linkedFB = [NSNumber numberWithBool:NO];
                               self.localUser.fbPostPermission = [NSNumber numberWithBool:NO];
                               [self sendNotificationForSocial:ToggleSocialFacebook];
                           }
                           else{
                               // keep this on since we failed turning it off
                               self.facebookSwitch.on = YES;
                               NSString *title = NSLocalizedString(@"Error", nil);
                               NSString *message = NSLocalizedString(@"There was an error unlinking your Facebook account.", nil);
                               [self showMessageWithTitle:title andMessage:message];
                           }
                       }];
    
    }
    
}
- (IBAction)swipedTWSwitch:(UISwitch *)sender {
    
    
    /*
    if (sender.on){
        // no twitter token so fetch
        if (!self.localUser.twToken){
            [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
                
                  if (session){
                      // prepeare to send to server
                      NSMutableDictionary *twDict = [@{} mutableCopy];
                      NSString *token = session.authToken;
                      NSString *uID = session.userID;
                      NSString *name = session.userName;
                      NSString *secret = session.authTokenSecret;
                      if (token){
                          twDict[@"token"] = token;
                      }
                      if (uID){
                          twDict[@"uid"] = uID;
                      }
                      if (name){
                          twDict[@"name"] = name;
                      }
                      if (secret){
                          twDict[@"secret"] = secret;
                      }

                      NSDictionary *params = @{@"provider":twDict};
                      [User linkProvider:APIProviderTwitter
                              withParams:params
                                   block:^(BOOL success) {
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (success){
                                               self.localUser.twUsername = session.userName;
                                               self.localUser.twID = session.userID;
                                               self.localUser.twToken = session.authToken;
                                               self.twitterSwitch.on = YES;
                                               self.localUser.linkedTW = [NSNumber numberWithBool:YES];
                                               [self sendNotificationForSocial:ToggleSocialTwitter];
                                           }
                                           else{
                                               self.twitterSwitch.on = NO;
                                               NSString *title = NSLocalizedString(@"Error", nil);
                                               NSString *message = NSLocalizedString(@"There was an error linking your Twitter account.", nil);
                                               [self showMessageWithTitle:title andMessage:message];
                                           }
                                           
                                    });
                                }];
                    }
                    else{
                        [self showMessageWithTitle:NSLocalizedString(@"Error", nil)  andMessage:NSLocalizedString(@"There was am error connecting your Twitter account.", nil)];
                        DLog(@"error is %@",[error localizedDescription]);
                        self.localUser.linkedTW = [NSNumber numberWithBool:NO];
                        [self.localUser.managedObjectContext save:nil];
                        self.twitterSwitch.on = NO;
                        //[[Twitter sharedInstance] logOut];
                    
                        [self sendNotificationForSocial:ToggleSocialTwitter];
                    }
                
            }];
        }
    }
    // mark off
    else{
        [User deleteProvider:APIProviderTwitter
                       block:^(BOOL success) {
                           if (success){
                               self.localUser.linkedTW = [NSNumber numberWithBool:NO];
                               self.localUser.twToken = nil;
                               //[[Twitter sharedInstance] logOut];
                               
                               // Global Notfication
                               [self sendNotificationForSocial:ToggleSocialTwitter];
                           }
                           else{
                               // keep this on since we failed turning it off
                               self.twitterSwitch.on = YES;
                               NSString *title = NSLocalizedString(@"Error", nil);
                               NSString *message = NSLocalizedString(@"There was an error unlinking your Twitter account", nil);
                               [self showMessageWithTitle:title andMessage:message];
                           }
                           
                       }];
    }
    
    
    //CODefaultsHelper *helper = [CODefaultsHelper new];
    //[helper addBool:sender.on forKey:kIconTwitter];
        
    */

}

- (void)sendError:(NSString *)errorString
{
    // This is just a private method thats used to send error data to server
    if (!errorString){
        return;
    }
    
    NSMutableDictionary *errorDict = [@{@"error":errorString}mutableCopy];
    NSString *device = [UIDevice devicePlatform];
    NSInteger iosVersionNumber = [UIDevice iOSVersion];

    if (device){
        errorDict[@"device"] = device;
    }
    
    if (iosVersionNumber){
        NSString *iosNumber = [NSString stringWithFormat:@"iOS %ld",(long)iosVersionNumber];
        errorDict[@"platform"] = iosNumber;
    }
    NSDictionary *params = @{@"error":errorDict};
    
    [User sendErrorToServerWithParams:params];
    
}
- (IBAction)swipedPreviewSwitch:(UISwitch *)sender {
}


- (void)sendNotificationForSocial:(ToggleSocial)social
{
    NSString *notifName;
    if (social == ToggleSocialFacebook){
        notifName = kToggleFacebookNotification;
    }
    else if (social == ToggleSocialTwitter){
        notifName = kToggleTwitterNotification;
    }
    else{
        return;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:notifName object:self];
}

- (void)checkSocialSwitches
{
    if (![self.localUser.fbPostPermission boolValue] || ![EasyFacebook sharedEasyFacebookClient].isPublishPermissionsAvailableQuickCheck){
        self.facebookSwitch.on = NO;
    }
    else{
        self.facebookSwitch.on = YES;
    }
    
    if (![self.localUser.linkedIG boolValue]) {
       // no IG use yet
    }
    else{

    }
    
    if(![self.localUser.linkedTW boolValue] || !self.localUser.twToken){
        self.twitterSwitch.on = NO;
    }
    else{
        self.twitterSwitch.on = YES;
    }

}
- (void)logout
{
    CODefaultsHelper *helper = [CODefaultsHelper new];
    if ([helper isLoggedIn]){
        [helper toggleLoggedIn];
    }
    
    
    self.localUser.loggedIn = [NSNumber numberWithBool:NO];
    [self.localUser.managedObjectContext save:nil];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    [User eliminaUsuario:context];
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
    
    
}

-(void)menuWillOpen
{
    // remove icons on memory warning so put them back when opening menu
    if (!self.instagramIcon.image){
        self.instagramIcon.image = [UIImage imageNamed:kIconInstagram];
    }
    
    if (!self.facebookIcon.image){
        self.facebookIcon.image = [UIImage imageNamed:kIconFacebook];
    }
    
    if(!self.twitterIcon.image){
        self.twitterIcon.image = [UIImage imageNamed:kIconTwitter];
    }
    
    [self checkSocialSwitches];
    
}

- (void)handleFacebookLogin:(NSNotification *)notif
{
    if (self.facebookIsLoggingIn){
        
        //EasyFacebook *sender = notif.object;
        //NSString *firstname = sender.UserFirstName;
        //NSString *lastname = sender.UserLastName;
        //NSString *username = sender.UserName;
        //NSString *email = sender.UserEmail;
        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbuserid = [FBSDKAccessToken currentAccessToken].userID;
        
        self.localUser.fbID = fbuserid;
        self.localUser.fbToken = token;
        self.localUser.fbUser = [NSNumber numberWithBool:YES];
        
        if (self.nonFacebookIsLoggingIn){
            [self swipedFBSwitch:self.facebookSwitch];
        }
        
        
    }
    
}


- (void)markFacebookLogin
{
    // Used to keep track if we're logging in with fbook or not (method below)
    self.facebookIsLoggingIn = YES;
}

#pragma mark Helpers

-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
}
@end
