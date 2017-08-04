//
//  SignupController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/1/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "COKeyboardView.h"
#import "CODefaultsHelper.h"
#import "SignupController.h"
#import "EasyFacebook.h"
#import "constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>

@interface SignupController()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet COKeyboardView *scrollview;
@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (strong,nonatomic) MBProgressHUD *hud;
// Constraints


// This is to verify we're attempting to login with fbook
@property BOOL facebookIsLoggingIn;

@end

@implementation SignupController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    [self setup];
    [self listenForNotifs];
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setup
{
    // Need this for Uibuttons working in scrollview
    self.scrollview.delaysContentTouches = NO;

    self.navigationController.navigationBarHidden = NO;
    self.topLabel.text = NSLocalizedString(@"Sign Up For Altruus!", nil);
    self.topLabel.textColor = [UIColor colorWithHexString:kColorBlue];
    //self.topLabel.font = [UIFont fontWithName:kAltruusFontBold size:25];
    
    // Add back arrow icon image to navbar
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:50];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(50, 50)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    // Adcd logo to top
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];

    self.firstnameField.delegate = self;
    self.lastnameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;

    
}

- (void)listenForNotifs
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markFacebookLogin)
                                                 name:EasyFacebookLoggedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFacebookLogin:) name:EasyFacebookLoggedInNotification object:nil];
}



- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveLocalUserToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:kAltruusLocalUserAuthKey];
}

- (IBAction)tappedSignup:(UIButton *)sender {

    if (![self checkFields]){
        NSString *title = NSLocalizedString(@"Oops", nil);
        NSString *message = NSLocalizedString(@"Please ensure all fields are all filled out.", nil);
        [self showMessageWithTitle:title andMessage:message];
        return;
    }
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Signing In..", nil);
    
    NSString *firstName = self.firstnameField.text;
    NSString *lastName = self.lastnameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    NSMutableDictionary *userParams = [@{@"email":email,
                                 @"password":password,
                                 @"first_name":firstName,
                                 @"last_name":lastName} mutableCopy];
    if (self.userCountry){
        userParams[@"country"] = self.userCountry;
    }
    
    NSDictionary *params = @{@"user":userParams};

    [User registerWithParams:params
                       block:^(APIRequestStatus status, NSString *userToken, NSDictionary *userData) {
                           if (status == APIRequestStatusSuccess){
                               self.localUser.firstname = firstName;
                               self.localUser.lastname = lastName;
                               self.localUser.username = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
                               self.localUser.loggedIn = [NSNumber numberWithBool:YES];
                               self.localUser.fbUser = [NSNumber numberWithBool:NO];
                               if (userToken){
                                   [self saveLocalUserToken:userToken];
                               }

                               if ([self.delegate respondsToSelector:@selector(signupcontroller:loggedInUser:)]){
                                   [self.delegate signupcontroller:self loggedInUser:self.localUser];
                               }
                               
                               
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }
                           else if (status == APIRequestStatusFail){
                               [self.hud hide:YES];
                               [self showRegisterError];
                               return;
                           }
                       }];
}


-(BOOL)checkFields
{
    if ([self.firstnameField.text isEqualToString:@""] || [self.lastnameField.text isEqualToString:@""] || [self.emailField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]){
        return NO;
    }
    else{
        return YES;
    }
    
}

- (void)showRegisterError
{
    NSString *title = NSLocalizedString(@"Error", nil);
    NSString *message = NSLocalizedString(@"There was an error signing you in. Try again.", nil);
    [self showMessageWithTitle:title andMessage:message];

}


#pragma mark Alerts
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


#pragma mark Facebook Login

- (void)markFacebookLogin
{
    // Used to keep track if we're logging in with fbook or not (method below)
    self.facebookIsLoggingIn = YES;
}

- (IBAction)tappedFacebook:(UIButton *)sender {
    
    if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn] && [self.localUser.loggedIn boolValue]){
        // skip facebook stuff and just login as usual
        CODefaultsHelper *helper = [CODefaultsHelper new];
        if (![helper isLoggedIn]){
            [helper toggleLoggedIn];
            [helper removeFirstLogin];
        }
        
        self.localUser.loggedIn = [NSNumber numberWithBool:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    else if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn] && ![self.localUser.loggedIn boolValue]){
        [[EasyFacebook sharedEasyFacebookClient] logOut];
        [self showRegisterError];
    }
    else{
        [EasyFacebook sharedEasyFacebookClient].readPermissions = @[@"public_profile", @"email", @"user_friends"];
        [[EasyFacebook sharedEasyFacebookClient] logIn];
        
    }
}

- (void)handleFacebookLogin:(NSNotification *)notif
{
    if (self.facebookIsLoggingIn){
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = NSLocalizedString(@"Signing In..", nil);
        
        EasyFacebook *sender = notif.object;
        NSString *firstname = sender.UserFirstName;
        NSString *lastname = sender.UserLastName;
        NSString *username = sender.UserName;
        NSString *email = sender.UserEmail;
        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbuserid = [FBSDKAccessToken currentAccessToken].userID;
        
        NSMutableDictionary *oauth = [@{@"provider":@"facebook"}mutableCopy];
        
        if (fbuserid){
            oauth[@"uid"] = fbuserid;
        }
        
        if (email){
            oauth[@"email"] = email;
        }
        
        if (token){
            oauth[@"token"] = token;
        }
        if (firstname){
            oauth[@"first_name"] = firstname;
        }
        
        if (lastname){
            oauth[@"last_name"] = lastname;
        }
        
        NSMutableDictionary *data = [@{@"oauth":oauth}mutableCopy];
        
        
        NSLog(@"need to send this data to server : %@",data);
        
        
        [User registerWithParams:data block:^(APIRequestStatus status, NSString *userToken, NSDictionary *userData) {
            if (status == APIRequestStatusSuccess){
                // make sure to grab authkey and set in defaults
                self.localUser.username = username;
                self.localUser.fbUser = [NSNumber numberWithBool:YES];
                self.localUser.fbID = fbuserid;
                self.localUser.firstname = firstname;
                self.localUser.lastname = lastname;
                self.localUser.email = email;
                self.localUser.loggedIn = [NSNumber numberWithBool:YES];
                self.localUser.fbToken = token;
                if (userToken){
                    [self saveLocalUserToken:userToken];
                }
                //[self.localUser.managedObjectContext save:nil];
                
                if ([self.delegate respondsToSelector:@selector(signupcontroller:loggedInUser:)]){
                    [self.delegate signupcontroller:self loggedInUser:self.localUser];
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                
                
            }
            else{
                [self.hud hide:YES];
                [self showRegisterError];
            }
        }];
    }
    
}

#pragma -mark UITextextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self tappedSignup:nil];
    return YES;
}



@end
