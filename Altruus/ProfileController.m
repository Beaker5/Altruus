//
//  ProfileController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/2/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//


#import "ProfileController.h"
#import "PromosViewController.h"
#import "constants.h"
#import "CODefaultsHelper.h"
#import "COUtils.h"
#import "EasyFacebook.h"
#import "RSKImageCropViewController.h"
#import "SlideNavigationController.h"
#import "QRScreenViewController.h"
#import "FeedbackViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "LoginViewController.h"
#import "SignupController.h"
#import "AppDelegate.h"
#import "User+Utils.h"
#import "AMPopTip.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Tweaks/FBTweakInline.h>


@interface ProfileController()<UIImagePickerControllerDelegate,RSKImageCropViewControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,LoginDelegate,SignUpDelegate>

@property (strong,nonatomic) User *localUser;

//Top banner
@property (weak, nonatomic) IBOutlet UIView *bannerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *bannerDisplayLabel;

// Mid section


@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileBorder;
@property (strong, nonatomic) UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *linkedSocialContainerView;

@property (weak, nonatomic) IBOutlet UILabel *linkedSocialLabel;

//Buttons

@property (weak, nonatomic) IBOutlet UIButton *giftButton;

@property (weak, nonatomic) IBOutlet UIImageView *giftBoxIcon;


@property (strong, nonatomic) NSString *tempQrString;
@property (strong, nonatomic) NSString *feedbackQrString;
@property (strong, nonatomic) NSString *feedbackMerchant;

@property (assign,nonatomic) BOOL laidOutSubviews;
@property (assign,nonatomic) BOOL setLocalPicture;
@property (assign,nonatomic) BOOL setFBPicture;
@property (assign,nonatomic) BOOL showFeedbackScreen;

//Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbIconWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twIconWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *igIconWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fbIconLeftSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *igAndFBIconHorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twAndIGIconHorizontalConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swirlBGBottomSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileBorderToTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileBorderHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileBorderWidthConstraint;


@end

@implementation ProfileController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get local user and set it
    if (!self.localUser){
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        //self.localUser = [User getLocalUserInContext:context];
        self.localUser = [User getLocalUserSesion:context];
    }
    
    // UI setup etc
    [self setup];
    [self handleProfilePic];
    
    // Notifications to be listening for
    [self listenForNotifs];

    
    // bounce here cause it removes delay from first time using menu
    [[SlideNavigationController sharedInstance] bounceMenu:MenuRight withCompletion:nil];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    
    
    self.navigationController.navigationBarHidden = NO;
    
    // Check if user is logged in properly via FB or otherwise
    
    if ([self.localUser.loggedIn boolValue]){
        if (![self.localUser.userID boolValue]){
            self.localUser.loggedIn = [NSNumber numberWithBool:NO];
            [self.localUser.managedObjectContext save:nil];
            [self showLoginScreen];
        }
        
    }
    if ([self.localUser.fbUser boolValue]){
        // Facebook user
        
        FBSDKAccessToken *fbToken = [FBSDKAccessToken currentAccessToken];
        if ([self.localUser.loggedIn boolValue] && fbToken){
            // ignore log in screen and go to profile
            
            // check if token is expired and log out if so
            NSDate *nowDate = [NSDate date];
            NSDate *tokenExpires = fbToken.expirationDate;
            if ([tokenExpires compare:nowDate] != NSOrderedDescending){
                DLog(@"%@ token expired",fbToken);
                [self showLoginScreen];
            }
        }
        else{
            // show login screen because we're either not logged in or dont have token
            [self showLoginScreen];
        }
    }
    else{
        // Non Facebook user
        if (![self.localUser.loggedIn boolValue]){
            [self showLoginScreen];
        }
        
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // get font names
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
     */
    
    
    // Check for pending pop tips or change username if needed
    [self updateUI];
    // App is useless if we dont have FB publish permission, so check everytime screen appears
    //[self facebookPermissionCheck];
    [self checkServerForLinkedSocial];
    [self handleProfilePic];
    [self invitePendingFriends];
    
    if (self.localUser){
        if ([self.localUser.managedObjectContext hasChanges]){
            [self.localUser.managedObjectContext save:nil];
        }
    }
    
    if (self.showFeedbackScreen){
        self.showFeedbackScreen = NO;
        [self presentFeedbackScreen];
    }
    
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // in autolayout can get accurate frames in here
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showLoginScreen
{
    
    UIViewController *loginNav = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardLogin];
    if ([loginNav isKindOfClass:[UINavigationController class]]){
        UINavigationController *nav = (UINavigationController *)loginNav;
        if ([nav.topViewController isKindOfClass:[LoginViewController class]]){
            LoginViewController *login = (LoginViewController *)nav.topViewController;
            login.delegate = self;
            login.localUser = self.localUser;
        }
    }
    [self.navigationController presentViewController:loginNav animated:NO completion:nil];
}

- (void)listenForNotifs
{
    // Listen for this notification to know when menu closes (for logout)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuCloseHandler) name:SlideNavigationControllerDidClose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSocialIcons) name:kToggleFacebookNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSocialIcons) name:kToggleTwitterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markFeedbackScreen:) name:kFeedbackDisplayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeTempQrCode:) name:kStoreQRCodeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purgeTempQrCode) name:kPurgeQRCodeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteNotification:) name:kRecievedRemoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invitedFriendsCheck:) name:kInviteFriendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invitePendingFriends) name:kUserIDSetNotification object:nil];
}



- (void)setup
{
    // Add menu icon to slide navigation
    FAKIonIcons *backIcon = [FAKIonIcons naviconRoundIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    
    [SlideNavigationController sharedInstance].rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    
    //FAKIonIcons *giftIcon = [FAKIonIcons ribbonBIconWithSize:35];
    //[giftIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    //UIImage *giftImage = [giftIcon imageWithSize:CGSizeMake(35, 35)];
    
    //[SlideNavigationController sharedInstance].leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:giftImage style:UIBarButtonItemStylePlain target:self action:@selector(showAllGifts)];
    
    [[SlideNavigationController sharedInstance] enableSwipeGesture];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];
    

    
    //setup top banner
    FBTweakBind(self.bannerDisplayLabel, text, @"Home", @"Profile Banner", @"Label",@"Profile");
    self.bannerContainerView.backgroundColor = [UIColor colorWithHexString:kColorGreen];
    self.bannerDisplayLabel.textColor = [UIColor whiteColor];
    self.bannerDisplayLabel.text = NSLocalizedString(@"PROFILE", nil);
    self.bannerDisplayLabel.font = [UIFont fontWithName:kAltruusFontBold size:20];
    
    //setup mid section (social)
    self.linkedSocialContainerView.backgroundColor = [UIColor colorWithHexString:kColorYellow];
    self.linkedSocialLabel.text = NSLocalizedString(@"Linked Social Media:", nil);
    self.linkedSocialLabel.textColor = [UIColor whiteColor];
    self.linkedSocialLabel.font = [UIFont fontWithName:kAltruusFontBold size:15];
    
    //setup buttons
    //[COUtils convertButton:self.giftButton withText:NSLocalizedString(@"GIFT ∞ REDEEM", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorGreen]];
    self.giftButton.layer.cornerRadius = 5.f;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedProfile)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self.profileBorder addGestureRecognizer:tap];
    self.profileBorder.userInteractionEnabled = YES;
    self.profileBorder.clipsToBounds = YES;
    
    // Add constraint for profile border image frame to resize
    float ar = self.profileBorder.image.size.width/self.profileBorder.image.size.height;
    NSLayoutConstraint *aspectConstraint = [NSLayoutConstraint constraintWithItem:self.profileBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.profileBorder attribute:NSLayoutAttributeHeight multiplier:ar constant:0];
    [self.view addConstraint:aspectConstraint];
    
    self.usernameTextField.text = [self.localUser localUsername];
    self.usernameTextField.delegate = self;

    if (IS_IPHONE_4_OR_LESS){
        self.profileBorderToTopConstraint.constant = 55;
        self.profileBorderHeightConstraint.constant = 130;
        self.profileBorderWidthConstraint.constant = 130;
        self.swirlBGBottomSpaceConstraint.constant = 185;
    }
    if (IS_IPHONE_5){
        // if less then 6 plus or 6 then make swirl background taller to fit profile pic and label
        self.swirlBGBottomSpaceConstraint.constant = 200;
    }

    [self.view bringSubviewToFront:self.giftButton];

}


- (void)invitePendingFriends
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [defaults valueForKey:kAltruusLocalUserAuthKey];
    if (!key){
        // so this isnt called repeatedly just make sure we have the auth token then make request
        return;
    }
    
    NSNumber *userID = [defaults valueForKey:kBranchInviteUser];
    if (userID){
        DLog(@"creating friendship between user %@ and %@",self.localUser.userID,userID);
        NSDictionary *params = @{@"friend_id":userID,
                                 @"platform":@"altruus"};
        NSDictionary *params2 = @{@"friendship":params};
        [User createFriendshipWithParams:params2
                                   block:^(BOOL success) {
                                       if (success){
                                           DLog(@"Created friendship");
                                           [defaults removeObjectForKey:kBranchInviteUser];
                                       }
                                       else{
                                           DLog(@"Failed to create friendship");
                                       }
                                   }];
    

    }
}

- (void)invitedFriendsCheck:(NSNotification *)notif
{
    // If loggged in, check to see if we done branch stuff like add user id
    NSDictionary *data = notif.userInfo;
    NSNumber *userID = data[@"userID"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userID forKey:kBranchInviteUser];
    if (userID && [self.localUser.userID boolValue]){
     // create friendship then delete
        DLog(@"creating friendship between user %@ and %@",self.localUser.userID,userID);
        NSDictionary *params = @{@"friend_id":userID,
                                 @"platform":@"altruus"};
        NSDictionary *params2 = @{@"friendship":params};
        [User createFriendshipWithParams:params2
                                   block:^(BOOL success) {
                                       if (success){
                                           DLog(@"Created friendship");
                                       }
                                       else{
                                           DLog(@"Failed to create friendship");
                                       }
                                   }];

    }
    
}
- (void)facebookPermissionCheck
{
    if (![self.localUser.fbUser boolValue]){
        return;
    }
    
    if ([self.localUser.loggedIn boolValue] && ![self.localUser.fbPostPermission boolValue]){
        if (![EasyFacebook sharedEasyFacebookClient].isPublishPermissionsAvailableQuickCheck){
            [[EasyFacebook sharedEasyFacebookClient] requestPublishPermissions:^(BOOL granted, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted){
                        self.localUser.linkedFB = [NSNumber numberWithBool:YES];
                        self.localUser.fbPostPermission = [NSNumber numberWithBool:YES];
                    }
                    else{
                        DLog(@"error is %@",error.localizedDescription);
                        self.localUser.linkedFB = [NSNumber numberWithBool:NO];
                        self.localUser.fbPostPermission = [NSNumber numberWithBool:NO];
                        NSString *title = NSLocalizedString(@"Error", nil);
                        NSString *message = NSLocalizedString(@"Altruus needs to be allowed to post to your wall to work.", nil);
                        [self showMessageWithTitle:title andMessage:message];
                        
                    }

                });
            }];
            
        }
        else{
            self.localUser.fbPostPermission = [NSNumber numberWithBool:YES];
            self.localUser.linkedFB = [NSNumber numberWithBool:YES];
        }
    }
                     
}


- (void)handleProfilePic
{
    // try to grab profile path from defaults
    CODefaultsHelper *helper = [CODefaultsHelper new];
    NSData *profilePicData = [helper getValueforKey:kAltruusProfilePicPath];
    
    UIImage *personImage = nil;
    CGSize profileBorderSize = self.profileBorder.bounds.size;
    int width = profileBorderSize.width - (profileBorderSize.width/3);
    int height = profileBorderSize.height - (profileBorderSize.height/3);
    
    if (profilePicData){
        if (!self.setLocalPicture){
            personImage = [UIImage imageWithData:profilePicData];
            self.profileImageView = [[UIImageView alloc] initWithImage:personImage];
            self.setLocalPicture = YES;
        }
        
    }
    else if ([self.localUser.fbUser boolValue]){
        
        if (!self.setFBPicture){
            // generate placeholder icon
            FAKIonIcons *personIcon = [FAKIonIcons androidPersonAddIconWithSize:80];
            [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
            personImage = [personIcon imageWithSize:CGSizeMake(profileBorderSize.width ,profileBorderSize.height)];
            
            // build facebook profile image
            NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.localUser.fbID];
            NSURL * fbUrl = [NSURL URLWithString:fbString];
            [self.profileImageView sd_setImageWithURL:fbUrl placeholderImage:personImage options:SDWebImageRefreshCached];
            //UIImage *fbPic = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:fbUrl]];
            //self.profileImageView = [[UIImageView alloc] initWithImage:fbPic];
            self.setFBPicture = YES;
        }
        
    }
    else{
        // If we dont have one show icon
        FAKIonIcons *personIcon = [FAKIonIcons androidPersonAddIconWithSize:80];
        [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        personImage = [personIcon imageWithSize:CGSizeMake(profileBorderSize.width ,profileBorderSize.height)];
   
        
        
        self.profileImageView = [[UIImageView alloc] initWithImage:personImage];
    }
    
    
    
    self.profileImageView.frame = CGRectMake(0, 0,width, height);
    self.profileImageView.center = [self.profileBorder convertPoint:self.profileBorder.center fromView:self.profileBorder.superview];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.profileImageView.layer.cornerRadius = height/2;
    self.profileImageView.clipsToBounds = YES;
    
    // Since this is called repeatedly, remove image before adding new one so there
    // isnt a build up of subviews
    self.profileImageView.tag = 89;
    UIView *removeView = [self.profileBorder viewWithTag:89];
    [removeView removeFromSuperview];
    
    
    [self.profileBorder addSubview:self.profileImageView];
    

}

- (void)checkServerForLinkedSocial
{
    [User getProvidersWithBlock:^(BOOL fbLinked, BOOL twLinked, NSString *fbToken, NSString *twToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fbLinked){
                self.localUser.linkedFB = [NSNumber numberWithBool:YES];
                self.localUser.fbToken = fbToken;
            }
            else{
                self.localUser.linkedFB = [NSNumber numberWithBool:NO];
                self.localUser.fbPostPermission = [NSNumber numberWithBool:NO];
                self.localUser.fbToken = nil;
            }
            
            if (twLinked){
                self.localUser.linkedTW = [NSNumber numberWithBool:YES];
                self.localUser.twToken = twToken;
            }
            else{
                self.localUser.linkedTW = [NSNumber numberWithBool:NO];
                self.localUser.twToken = nil;
            }
            
            [self checkSocialIcons];
        });

    }];
}


- (void)checkSocialIcons
{
    // Adjust the constraints (visibility) if need be for social icons
    
    //CODefaultsHelper *helper = [CODefaultsHelper new];
    
    //FB Checks
    if (![self.localUser.linkedFB boolValue]){
        self.fbIconWidthConstraint.constant = 0;
        self.fbIconLeftSpaceConstraint.constant = 149;
    }
    else if (![self.localUser.fbPostPermission boolValue] || ![EasyFacebook sharedEasyFacebookClient].isPublishPermissionsAvailableQuickCheck){
        self.fbIconWidthConstraint.constant = 0;
        self.fbIconLeftSpaceConstraint.constant = 149;
    }
    else{
        self.fbIconWidthConstraint.constant = 40;
        self.fbIconLeftSpaceConstraint.constant = 169;
    }
    
    
    //IG Checks
    if (![self.localUser.linkedIG boolValue]) {
        self.igIconWidthConstraint.constant = 0;
        self.igAndFBIconHorizontalConstraint.constant = 0;
    }
    else{
        self.igIconWidthConstraint.constant = 40;
        self.igAndFBIconHorizontalConstraint.constant = 8;
    }
    
    
    //TW Checks
    if(![self.localUser.linkedTW boolValue] || !self.localUser.twToken){
        self.twIconWidthConstraints.constant = 0;
    }
    else{
        self.twIconWidthConstraints.constant = 40;

    }
    
    if (![self.localUser.fbPostPermission boolValue] && ![self.localUser.linkedTW boolValue]){
        self.linkedSocialLabel.text = NSLocalizedString(@"Link Social Accounts in the menu", nil);
        
    }
    else{
        self.linkedSocialLabel.text = NSLocalizedString(@"Linked Social Media:", nil);
    }
   

}

- (void)updateUI
{
    // add other ui elements like pic here
     self.usernameTextField.text = [self.localUser localUsername];
    
    // check to see if I should show pop tips
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger shownPopTip = [defaults integerForKey:@"shownPopTip"];
    if (!shownPopTip){
        shownPopTip = 0;
    }
    if (shownPopTip <= 3){
        
        [[AMPopTip appearance] setTextColor:[UIColor whiteColor]];
        [[AMPopTip appearance] setPopoverColor:[UIColor colorWithHexString:kColorGreen]];
        [[AMPopTip appearance] setAnimationIn:1];
        [[AMPopTip appearance] setAnimationOut:1];
        AMPopTip *popTip = [AMPopTip popTip];
        NSString *text = NSLocalizedString(@"Tap to edit picture or username", nil);
        [popTip showText:text direction:AMPopTipDirectionUp
                maxWidth:200 inView:self.view fromFrame:self.profileBorder.frame
                duration:5];
        //[popTip bounce];
        
        shownPopTip += 1;
        [defaults setInteger:shownPopTip forKey:@"shownPopTip"];
        
    }
    
}
    

    
- (IBAction)tappedGift:(UIButton *)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardQRScreen];
    if ([controller isKindOfClass:[QRScreenViewController class]]){
        ((QRScreenViewController *)controller).screenType = QRScreenTypeGift;
        ((QRScreenViewController *)controller).localUser = self.localUser;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

   
- (void)tappedProfile
{
    //need to ask first
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else{
        NSLog(@"no camarea");
    }
    
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)markFeedbackScreen:(NSNotification *)notif
{
    // mark this so we know to present feedback screen with data
    self.showFeedbackScreen = YES;
    
    NSString *merchant = notif.userInfo[@"merchant"];
    NSString *code = notif.userInfo[@"code"];
    if (merchant && code){
        self.feedbackMerchant = notif.userInfo[@"merchant"];
        self.feedbackQrString = notif.userInfo[@"code"];
    }
    
}
- (void)presentFeedbackScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardFeedbackScreen];
    if ([controller isKindOfClass:[FeedbackViewController class]]){
        ((FeedbackViewController *)controller).qrString = self.feedbackQrString;
        ((FeedbackViewController *)controller).localUser = self.localUser;
        ((FeedbackViewController *)controller).merchant_name = self.feedbackMerchant;
        ((FeedbackViewController *)controller).screenType = FeedbackScreenFeedback;
        
        UINavigationController *baseFeedback = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:baseFeedback animated:YES completion:nil];
    }
}

- (void)storeTempQrCode:(NSNotification *)notif
{
    NSString *code = notif.userInfo[@"code"];
    self.tempQrString = code;
}

- (void)purgeTempQrCode
{
    
    self.tempQrString = nil;
}

- (void)handleRemoteNotification:(NSNotification *)notif
{
    DLog(@"remote notification received");
}

#pragma mark Menu actions
- (void)showMenu
{
    //[[SlideNavigationController sharedInstance] toggleRightMenu];
    
    [[SlideNavigationController sharedInstance] openMenu:MenuRight withCompletion:^{
        NSLog(@"tell menu to prepare");
    }];
    
}

- (void)showAllGifts
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardPromosScreen];
    if ([controller isKindOfClass:[PromosViewController class]]){
        ((PromosViewController *)controller).localUser = self.localUser;
        ((PromosViewController *)controller).screenType = PromosScreenAll;
    }
    else{
        DLog(@"CONTROLLER IS NOT PROMO SCREEN!")
        return;
    }
    
    UINavigationController *navBase = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navBase animated:YES completion:nil];
}

#pragma mark Handlers

- (void)menuCloseHandler
{
    
    // check to see if we been logged out
    /*
    CODefaultsHelper *helper = [CODefaultsHelper new];
    if (![helper isLoggedIn]){
        
        [[EasyFacebook sharedEasyFacebookClient] logOut];
        UIViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardBaseLogin];
        [self presentViewController:login animated:YES completion:nil];
        
    }
     */
    
    if (![self.localUser.loggedIn boolValue]){
        [[EasyFacebook sharedEasyFacebookClient] logOut];
        
        UIViewController *loginNav = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardLogin];
        if ([loginNav isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav = (UINavigationController *)loginNav;
            if ([nav.topViewController isKindOfClass:[LoginViewController class]]){
                LoginViewController *login = (LoginViewController *)nav.topViewController;
                login.delegate = self;
                login.localUser = self.localUser;
                [self presentViewController:loginNav animated:YES completion:nil];
            }
        }

    }
    
    if (self.localUser){
        if([self.localUser.managedObjectContext hasChanges]){
            [self.localUser.managedObjectContext save:nil];
        }
    }
    // Need this here to either add or remove social icons (constraints)
    [self checkSocialIcons];
}


#pragma mark Saving and Retrieving files

- (NSString *)saveImage:(NSData *)image
               filename:(NSString *)name
{
    // filename can be /test/another/test.jpg
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *profileDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"profile"];
        
        NSError *e;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:profileDirectory withIntermediateDirectories:YES attributes:nil error:&e]){
            DLog(@"%@",e);
        }
        
        
        NSString* path = [profileDirectory stringByAppendingPathComponent:name];
        if (![image writeToFile:path options:0 error:&e]){
            DLog(@"%@",e);
            
            return nil;
        }
        
        
        return path;
    }
    
    return nil;
}

- (UIImage *)loadImagewithFileName:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:name];
}


#pragma -mark Login and signup delegates
-(void)controller:(UIViewController *)controller loggedInUser:(User *)user
{
    
    
    self.localUser = user;
}

- (void)signupcontroller:(UIViewController *)controller loggedInUser:(User *)user
{
    self.localUser = user;
}


#pragma -mark Slide delegate
-(BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return NO;
}

-(BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}

#pragma -mark Image cropper
-(void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage
{
    
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle
{
    [controller dismissViewControllerAnimated:YES completion:^{
       
        self.profileImageView.image = croppedImage;
        
        NSData *imageData = UIImagePNGRepresentation(croppedImage);
        CODefaultsHelper *helper = [CODefaultsHelper new];
        [helper addValue:imageData forKey:kAltruusProfilePicPath withStoreType:UserDefaultStoreObject];
        
        /*
        // store the image locally
        NSString *storedProfileImage = [self saveImage:UIImagePNGRepresentation(croppedImage) filename:kAltruusProfilePicFile];
        
        // If successful store the path to the image in defaults
        if (storedProfileImage){
            CODefaultsHelper *helper = [CODefaultsHelper new];
            [helper addValue:storedProfileImage forKey:kAltruusProfilePicPath withStoreType:UserDefaultStoreValue];
        }
         */

    }];

}

-(void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
        self.profileImageView.image = croppedImage;
        
        NSData *imageData = UIImagePNGRepresentation(croppedImage);
        CODefaultsHelper *helper = [CODefaultsHelper new];
        [helper addValue:imageData forKey:kAltruusProfilePicPath withStoreType:UserDefaultStoreObject];
        
        /*
        // store the image locally
        NSString *storedProfileImage = [self saveImage:UIImagePNGRepresentation(croppedImage) filename:kAltruusProfilePicFile];
        
        // If successful store the path to the image in defaults
        if (storedProfileImage){
            CODefaultsHelper *helper = [CODefaultsHelper new];
            [helper addValue:storedProfileImage forKey:kAltruusProfilePicPath withStoreType:UserDefaultStoreValue];
        }

        */
    }];

}


#pragma -mark Image picker stuff
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //NSLog(@"cancled");
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   UIImage *originalImage = nil;
                                   originalImage = info[UIImagePickerControllerOriginalImage];
                                   
                                    RSKImageCropViewController *crop = [[RSKImageCropViewController alloc] initWithImage:originalImage];
                                   
                                   crop.delegate = self;
                                   [self presentViewController:crop animated:YES completion:nil];
                               }];
}

#pragma mark Uitextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // do something with new username
    [textField resignFirstResponder];
    self.usernameTextField.text = textField.text;
    
    return YES;
}


#pragma mark Getters



-(UIImageView *)profileImageView
{
    if (!_profileImageView){
        CGSize profileBorderSize = self.profileBorder.bounds.size;
        
        //FAKIonIcons *personIcon = [FAKIonIcons androidPersonAddIconWithSize:80];
        //[personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        //UIImage *personImage = [personIcon imageWithSize:CGSizeMake(profileBorderSize.width ,profileBorderSize.height)];
        
        _profileImageView = [[UIImageView alloc] init];
        int width = profileBorderSize.width - (profileBorderSize.width/3);
        int height = profileBorderSize.height - (profileBorderSize.height/3);
        
        _profileImageView.frame = CGRectMake(0, 0,width, height);
        _profileImageView.center = [self.profileBorder convertPoint:self.profileBorder.center fromView:self.profileBorder.superview];
        _profileImageView.contentMode = UIViewContentModeScaleAspectFit;
        _profileImageView.layer.cornerRadius = height/2;
        _profileImageView.clipsToBounds = YES;

    }
    
    return _profileImageView;
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
