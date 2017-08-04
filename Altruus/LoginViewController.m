//
//  LoginViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 3/30/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "constants.h"
#import "COKeyboardView.h"
#import "CODefaultsHelper.h"
#import "UIView+BFKit.h"
#import "EasyFacebook.h"
#import "User+Utils.h"
#import "SignupController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "AppDelegate.h"
#import <MBProgressHUD.h>
#import <CoreLocation/CoreLocation.h>
#import <Crashlytics/Crashlytics.h>
#import "Servicios.h"
#import "RegisterViewController.h"
#import <NSStringMask/UITextFieldMask.h>

typedef NS_ENUM(NSInteger, LoginFieldType)
{
    LoginFieldTypeUsername,
    LoginFieldTypePassword,
    LoginFieldTypeNone
    
};

@interface LoginViewController ()<UITextFieldDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *fbID;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *idAltruus;


@property (nonatomic, weak) IBOutlet UITextFieldMask *phoneTextField;
@property (nonatomic, weak) IBOutlet UITextFieldMask *birthdayTextField;
@property (nonatomic, weak) IBOutlet UITextField *countryPicker;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;


@property (strong,nonatomic) CLLocationManager *locationManger;
@property (strong, nonatomic) NSString *userCountry;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomSignUp;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet COKeyboardView *scrollview;
@property (strong,nonatomic) MBProgressHUD *hud;

// Constraints

// Original 209
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;
// Original 185
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
// Original 35
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopspaceConstraint;
// Original 29
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextTopspaceConstraint;


// This is to verify we're attempting to login with fbook
@property BOOL facebookIsLoggingIn;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    [self setupRegister];
    [self listenForNotifs];

    
    // Hide for animations
    self.logoImageView.hidden = YES;
    self.logoImageView.alpha = 0;
    self.facebookButton.hidden = YES;
    self.facebookButton.alpha = 0;
    self.emailField.hidden = YES;
    self.emailField.alpha = 0;
    self.passwordField.hidden = YES;
    self.passwordField.alpha = 0;
    self.bottomLabel.hidden = YES;
    self.bottomLabel.alpha = 0;
    self.signupButton.hidden = YES;
    self.signupButton.alpha = 0;
    self.loginButton.hidden = YES;
    self.loginButton.alpha = 0;
    
    


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
       
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    [UIView animateWithDuration:1 animations:^{
        self.logoImageView.hidden = NO;
        self.logoImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
            self.facebookButton.hidden = NO;
            self.facebookButton.alpha = 1;
            self.emailField.hidden = NO;
            self.emailField.alpha = 1;
            self.passwordField.hidden = NO;
            self.passwordField.alpha = 1;
            self.bottomLabel.hidden = YES;
            self.bottomLabel.alpha = 0;
            self.signupButton.hidden = YES;
            self.signupButton.alpha = 0;
            self.loginButton.hidden = NO;
            self.loginButton.alpha = 1;

        } completion:nil];
    }];
    
    //[self getUsersLocation]; //comente
    //[self logOutOfFacebook]; //comente

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)setupRegister{
    @try {
        self.phoneTextField.placeholder = @"Enter your phone number";
        self.birthdayTextField.placeholder = @"Enter your birthday dd/MM/yyyy";
        self.countryPicker.placeholder = @"Pick your country";
        
        self.phoneTextField.mask = [[NSStringMask alloc] initWithPattern:@"(\\d{3})-(\\d{3})-(\\d{4})" placeholder:@"_"];
        self.birthdayTextField.mask = [[NSStringMask alloc] initWithPattern:@"(\\d{2})/(\\d{2})/(\\d{4})" placeholder:@"_"];
        
        self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.phoneTextField.textAlignment = NSTextAlignmentCenter;
        
        self.birthdayTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.birthdayTextField.textAlignment = NSTextAlignmentCenter;
        
        self.countryPicker.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.countryPicker.textAlignment = NSTextAlignmentCenter;
        
        NSArray *countries = [NSArray arrayWithObjects:@"United States", @"Mexico" , @"Canada", nil];
        
        self.pickerCountry = [[DownPicker alloc] initWithTextField:self.countryPicker withData:countries];
        [self.pickerCountry setPlaceholder:@"Choose a country"];
        self.pickerCountry.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        self.registerButton.layer.cornerRadius = 10;
        
        self.phoneTextField.hidden = YES;
        self.birthdayTextField.hidden = YES;
        self.countryPicker.hidden = YES;
        self.registerButton.hidden = YES;
        NSLog(@"Pasé setupRegister");
    } @catch (NSException *exception) {
        NSLog(@"Error setupRegister: %@", exception.reason);
    }
}

- (void)setup
{
    

    // Need this for Uibuttons working in scrollview
    self.scrollview.delaysContentTouches = NO;
    
    
    self.navigationController.navigationBarHidden = YES;
    self.loginButton.userInteractionEnabled = YES;
    self.signupButton.userInteractionEnabled = YES;
    
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    if (IS_IPHONE_4_OR_LESS){
        self.logoTopspaceConstraint.constant = -10;
        self.logoHeightConstraint.constant = 190;
        self.bottomTextTopspaceConstraint.constant = 15;
    }
    
    //NSDictionary *info = [[NSBundle mainBundle] infoDictionary]; //COMENTE 250617
    //NSString *version = info[@"CFBundleShortVersionString"]; //COMENTE 250617
    self.bottomLabel.text = NSLocalizedString(@"Don't have an account yet?", nil);
    [self.bottomSignUp setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
    //self.versionLabel.text = [NSString stringWithFormat:@"Altruus v%@",version];
    self.versionLabel.textColor = [UIColor lightGrayColor];
    
    self.versionLabel.hidden = NO;
    self.facebookButton.hidden = NO;
    
}

- (void)listenForNotifs
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFacebookLogin:)
                                                 name:EasyFacebookUserInfoFetchedNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markFacebookLogin)
                                                 name:EasyFacebookLoggedInNotification object:nil];
    
}

- (void)logOutOfFacebook
{
    [[EasyFacebook sharedEasyFacebookClient] logOut];
}


- (void)getUsersLocation
{
    
    
    if (!self.userCountry){
        self.locationManger = [[CLLocationManager alloc] init];
        self.locationManger.delegate = self;
        self.locationManger.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        if (IS_IOS8){
            [self.locationManger requestWhenInUseAuthorization];
        }
        [self.locationManger startUpdatingLocation];
    }
    
    
}


- (void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder* reverseGeocoder = [[CLGeocoder alloc] init];
    if (reverseGeocoder) {
        [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = [placemarks firstObject];
            if (placemark) {
                //Using blocks, get zip code
                self.userCountry = placemark.ISOcountryCode;
                
            }
        }];
    }
}


- (IBAction)tappedLogin:(UIButton *)sender
{
    if (![self checkFields]){
        NSString *title = NSLocalizedString(@"Oops", nil);
        NSString *message = NSLocalizedString(@"Please ensure all fields are all filled out.", nil);
        [self showMessageWithTitle:title andMessage:message];
        return;
    }

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Logging In..", nil);
    
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    NSDictionary *userDict = @{@"email":email,
                               @"password":password};
    NSDictionary *params = @{@"user":userDict};
    [User registerWithParams:params
                    block:^(APIRequestStatus status, NSString *userToken,NSDictionary *userData) {
                        if (status == APIRequestStatusSuccess){
                            NSString *firstName = userData[@"user"][@"first_name"];
                            NSString *lastName = userData[@"user"][@"last_name"];
                            NSString *email = userData[@"user"][@"email"];
                            NSNumber *_id = userData[@"user"][@"id"];
                            self.localUser.loggedIn = [NSNumber numberWithBool:YES];
                            if (firstName){
                                self.localUser.firstname = firstName;
                            }
                            if (lastName){
                                self.localUser.lastname = lastName;
                            }
                            if (email){
                                self.localUser.email = email;
                            }
                            if (_id){
                                self.localUser.userID = _id;
                            }
                            if (userToken){
                                [self saveLocalUserToken:userToken];
                            }
                            
                            
                            // use delegate to pass user back to profile
                            if ([self.delegate respondsToSelector:@selector(controller:loggedInUser:)]){
                                [self.delegate controller:self loggedInUser:self.localUser];
                            }
                            
                            [self dismissViewControllerAnimated:YES completion:^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":_id}];
                            }];
                            
                        }
                        else if (status == APIRequestStatusFail){
                            [self.hud hide:YES];
                            [self showRegisterError];
                        }
                    }];
    
}


- (IBAction)tappedSignUp:(UIButton *)sender {

    DLog(@"Tapped sign up");
    
    /*
    UIViewController *signup = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardSignup];
    if (signup){
        ((SignupController *)signup).localUser = self.localUser;
        ((SignupController *)signup).userCountry = self.userCountry;
        //((SignupController *)signup).delegate = self.baseProfile;
        [self.navigationController pushViewController:signup animated:YES];
    }
     */
    
    
}

-(BOOL)checkFields
{
    if ([self.emailField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]){
        return NO;
    }
    else{
        return YES;
    }
    
}


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

#pragma -mark CLLocation delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    DLog(@"failed to get location with %@",error.localizedDescription);
    
    if([CLLocationManager locationServicesEnabled]){
        
        DLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    
    CLLocation *locationObject = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self reverseGeocodeLocation:locationObject];
    
}



#pragma mark Facebook Login

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
        //[self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"There was an error logging you in. Please try again.", nil)];
        
        [EasyFacebook sharedEasyFacebookClient].readPermissions = @[@"public_profile", @"email", @"user_friends"];
        [[EasyFacebook sharedEasyFacebookClient] logIn];
        self.localUser.loggedIn = [NSNumber numberWithBool:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [EasyFacebook sharedEasyFacebookClient].readPermissions = @[@"public_profile", @"email", @"user_friends",@"user_birthday"];
        [[EasyFacebook sharedEasyFacebookClient] logIn];
        
    }
     
    
    
    
}

- (void)markFacebookLogin
{
    // Used to keep track if we're logging in with fbook or not (method below)
    self.facebookIsLoggingIn = YES;
}

- (void)saveLocalUserToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:kAltruusLocalUserAuthKey];
}

- (void)handleFacebookLogin:(NSNotification *)notif
{
    if (self.facebookIsLoggingIn){
        
        //self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //self.hud.mode = MBProgressHUDModeIndeterminate;
        //self.hud.labelText = NSLocalizedString(@"Logging In..", nil);
        
        NSLog(@"Sender: %@", notif.object);
        
        EasyFacebook *sender = notif.object;
        NSString *firstname = sender.UserFirstName;
        NSString *lastname = sender.UserLastName;
        NSString *username = sender.UserName;
        NSString *email = sender.UserEmail;
        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbuserid = [FBSDKAccessToken currentAccessToken].userID;
        
        if (email == NULL || email == nil || !email || email == (id)[NSNull null] || [email isEqualToString:@"(null)"]) {
            email =@"__________@altruus.com";
        }
        
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
        
        if (self.userCountry){
            oauth[@"country"] = self.userCountry;
        }
        
        NSMutableDictionary *data = [@{@"oauth":oauth}mutableCopy];
        
        
        NSLog(@"need to send this data to server : %@",data);
        
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSString *pushId = delegate.pushId;
        //pushId = @"8278-2335-gdfg-335"; //ELIMINAR PUSHID
       
        //[User registerWithParams:data block:^(APIRequestStatus status, NSString *userToken, NSDictionary *userData) {
            //if (status == APIRequestStatusSuccess){
                // make sure to grab authkey and set in defaults
                self.localUser.username = username;
                self.localUser.fbUser = [NSNumber numberWithBool:YES];
                self.localUser.fbID = fbuserid;
                self.localUser.firstname = firstname;
                self.localUser.lastname = lastname;
                self.localUser.email = email;
                self.localUser.loggedIn = [NSNumber numberWithBool:YES];
                self.localUser.fbToken = token;
                //self.localUser.userID = userData[@"user"][@"id"];
            
                self.localUser.pushID = pushId;
                [self signInFacebook:pushId andMail:email andFirstName:firstname andLastName:lastname andCountry:self.userCountry andFacebookId:fbuserid];
                /*
                self.localUser.fbIDAltruus = _fbID;
                self.localUser.userIDAltruus = _idAltruus;
                self.localUser.tokenAltruus = _token;
                self.localUser.userID = [NSNumber numberWithInteger:[_idAltruus integerValue]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":_idAltruus}];
                if (_token){
                    [self saveLocalUserToken:_token];
                }
                //[[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":userData[@"user"][@"id"]}];
                
                //if (userToken){
                //    [self saveLocalUserToken:userToken];
                //}
                [self.localUser.managedObjectContext save:nil];
                
                if ([self.delegate respondsToSelector:@selector(controller:loggedInUser:)]){
                    [self.delegate controller:self loggedInUser:self.localUser];
                }
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":_idAltruus}];
                  }];
                 
                 */
                //[[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":userData[@"user"][@"id"]}];
                //}];
           // }
            //else{
            //    [self.hud hide:YES];
            //    [self showRegisterError];
            //}
       // }];
    }
    
    /*
    CODefaultsHelper *helper = [CODefaultsHelper new];
    if (![helper isLoggedIn]){
        [helper toggleLoggedIn];
        [helper removeFirstLogin];
    }

     */
}

-(NSInteger)returnCountryCode:(NSString*)country{
    if ([country isEqualToString:@"US"]) {
        return 1;
    }else if([country isEqualToString:@"MX"]){
        return 2;
    }else{
        return 1000;
    }
}

-(void)signInFacebook:(NSString*)pushID andMail:(NSString*)email andFirstName:(NSString*)firstname andLastName:(NSString*)lastname andCountry:(NSString*)country andFacebookId:(NSString*)fbuserid{
    //NSString *url = @"http://138.197.95.215:8080/altruus-v2-authentication/api/v2/consumer/facebook_sign_in";
    
    @try {
        
    
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:pushID forKey:@"pushId"];
    [dict setObject:email forKey:@"email"];
    [dict setObject:@"2" forKey:@"deviceTypeId"];
    [dict setObject:@"imei_123" forKey:@"imei"];
    //[dict setObject:@"1dd608f2-c6a1-11e3-851d-000c2940e62c" forKey:@"pushId"];
    //[dict setObject:@"john@email.com" forKey:@"email"];
    //[dict setObject:@"hLd2KmCZifCbkbmaj6iokQ==" forKey:@"password"];
    NSLog(@"Dict: %@", dict);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    NSString *jsonString;
    if (!jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FACEBOOK_SIGN_IN]];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSLog(@"****************************************************************************************************");
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    
    NSInteger code = [httpResponse statusCode];
    
    //NSLog(@"Res: %ld, Data: %@", code, dictionary);
    switch (code) {
        case 200:{
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Dictionary: %@", dictionary);
            _fbID = [dictionary objectForKey:@"facebookId"];
            _idAltruus = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
            //_idAltruus = [NSString [dictionary objectForKey:@"id"];
            //_idAltruus = [dictionary objectForKey:@"id"];
            _token = [dictionary objectForKey:@"token"];
            
            
            self.localUser.fbIDAltruus = _fbID;
            self.localUser.userIDAltruus = _idAltruus;
            self.localUser.tokenAltruus = _token;
            self.localUser.userID = [NSNumber numberWithInteger:[_idAltruus integerValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":_idAltruus}];
            if (_token){
                [self saveLocalUserToken:_token];
            }
            //[[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":userData[@"user"][@"id"]}];
            
            //if (userToken){
            //    [self saveLocalUserToken:userToken];
            //}
            [self.localUser.managedObjectContext save:nil];
            
            if ([self.delegate respondsToSelector:@selector(controller:loggedInUser:)]){
                [self.delegate controller:self loggedInUser:self.localUser];
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":_idAltruus}];
            }];
            
            
            break;
        }
        case 406:{
            self.versionLabel.hidden = YES;
            self.facebookButton.hidden = YES;
            
            self.phoneTextField.hidden = NO;
            self.birthdayTextField.hidden = NO;
            self.countryPicker.hidden = NO;
            self.registerButton.hidden = NO;
            
            
            
            //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
            //controller = [sb instantiateViewControllerWithIdentifier:@"register"];
            //((RegisterViewController*)controller).localUser = self.localUser;
            //[self presentViewController:controller animated:NO completion:nil];
            //[self dismissViewControllerAnimated:YES completion:nil];
            
            /*
            dict = [[NSMutableDictionary alloc]init];
            NSInteger countryCode = [self returnCountryCode:country];
            [dict setObject:[NSNumber numberWithInteger:countryCode] forKey:@"countryId"];
            [dict setObject:@"01/01/1990" forKey:@"birthday"];
            [dict setObject:email forKey:@"email"];
            [dict setObject:fbuserid forKey:@"facebookId"];
            [dict setObject:firstname forKey:@"firstName"];
            [dict setObject:lastname forKey:@"lastName"];
            
            jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FACEBOOK_SIGN_UP]];
            
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = jsonData;
            
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
            httpResponse = (NSHTTPURLResponse *)res;
            
            NSInteger code2 = [httpResponse statusCode];
            if(code2 == 200){
                dict = [[NSMutableDictionary alloc]init];
                [dict setObject:pushID forKey:@"pushId"];
                [dict setObject:email forKey:@"email"];
                [dict setObject:@"2" forKey:@"deviceTypeId"];
                [dict setObject:@"imei_123" forKey:@"imei"];
                [dict setObject:@"hLd2KmCZifCbkbmaj6iokQ==" forKey:@"password"];
                
                jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FACEBOOK_SIGN_IN]];
                
                request.HTTPMethod = @"POST";
                [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                request.HTTPBody = jsonData;
                
                data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                httpResponse = (NSHTTPURLResponse *)res;
                code2 = [httpResponse statusCode];
                if (code2 == 200) {
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    _fbID = [dictionary objectForKey:@"facebookId"];
                    _idAltruus = [dictionary objectForKey:@"id"];
                    _token = [dictionary objectForKey:@"token"];
                }else{
                    _fbID = @"";
                    _idAltruus = @"";
                    _token = @"";
                    
                }
            }
            */
            break;
        }
        default:
            break;
    }
        NSLog(@"LoginViewController Exitoso");
    } @catch (NSException *exception) {
        NSLog(@"Error Loginviewcontroller: %@", exception.reason);
    }
    /*
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        NSLog(@"Response: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
        
        NSLog(@"Dictionary: %@",dictionary);
        
        // do stuff
    }];
     */
}

- (IBAction)tappedRegister:(UIButton *)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    //NSInteger countryCode = [self returnCountryCode:country];
    NSInteger countryCode = [self.pickerCountry selectedIndex] + 1;
    [dict setObject:[NSNumber numberWithInteger:countryCode] forKey:@"countryId"];
    [dict setObject:self.birthdayTextField.text forKey:@"birthday"];
    [dict setObject:self.phoneTextField.text forKey:@"phone"];
    [dict setObject:self.localUser.email forKey:@"email"];
    [dict setObject:self.localUser.fbID forKey:@"facebookId"];
    [dict setObject:self.localUser.firstname forKey:@"firstName"];
    [dict setObject:self.localUser.lastname forKey:@"lastName"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FACEBOOK_SIGN_UP]];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    
    NSInteger code2 = [httpResponse statusCode];
    if(code2 == 200){
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSString *pushId = delegate.pushId;
        //pushId = @"8278-2335-gdfg-335"; //ELIMINAR PUSHID
        
        dict = [[NSMutableDictionary alloc]init];
        [dict setObject:pushId forKey:@"pushId"];
        [dict setObject:self.localUser.email forKey:@"email"];
        [dict setObject:@"2" forKey:@"deviceTypeId"];
        [dict setObject:@"imei_123" forKey:@"imei"];
        [dict setObject:@"hLd2KmCZifCbkbmaj6iokQ==" forKey:@"password"];
        
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FACEBOOK_SIGN_IN]];
        
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = jsonData;
        
        data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
        httpResponse = (NSHTTPURLResponse *)res;
        code2 = [httpResponse statusCode];
        if (code2 == 200) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.localUser.fbIDAltruus= [dictionary objectForKey:@"facebookId"];
            self.localUser.userIDAltruus =  [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"id"]];
            self.localUser.tokenAltruus = [dictionary objectForKey:@"token"];
            self.localUser.userID = [dictionary objectForKey:@"id"];
            
            [self.localUser.managedObjectContext save:nil];
            if ([dictionary objectForKey:@"token"]){
                [self saveLocalUserToken:[dictionary objectForKey:@"token"]];
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserIDSetNotification object:self userInfo:@{@"localuserID":[dictionary objectForKey:@"id"]}];
            }];
            
        }
    }
}

/*
-(NSInteger)signInFacebook:(NSString*)pushID andMail:(NSString*)email{
    NSString *url = @"http://138.197.95.215:8080/altruus-v2-authentication/api/v2/consumer/facebook_sign_in";
 
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
 
    [dict setObject:pushID forKey:@"pushId"];
    [dict setObject:@"2" forKey:@"deviceTypeId"];
    [dict setObject:email forKey:@"email"];
    [dict setObject:@"imei_123" forKey:@"imei"];
    [dict setObject:@"hLd2KmCZifCbkbmaj6iokQ==" forKey:@"password"];
    
    [dict setObject:@"1dd608f2-c6a1-11e3-851d-000c2940e62c" forKey:@"pushId"];
    [dict setObject:@"2" forKey:@"deviceTypeId"];
    [dict setObject:@"john@email.com" forKey:@"email"];
    [dict setObject:@"imei_123" forKey:@"imei"];
    [dict setObject:@"hLd2KmCZifCbkbmaj6iokQ==" forKey:@"password"];
     
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString;
    if (!jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    __block NSInteger code;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        code = [httpResponse statusCode];
        NSLog(@"Code %ld, Data: %@", (long)code, data);
        switch (code) {
            case 200:{
                
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
                _fbID = [dictionary objectForKey:@"facebookId"];
                _idAltruus = [dictionary objectForKey:@"id"];
                _token = [dictionary objectForKey:@"token"];
                break;
            }
            default:{
                _fbID = @"";
                _idAltruus = @"";
                _token = @"";
                break;
            }
        }
    }];
    
    NSLog(@"%@, %@, %@", _fbID, _idAltruus, _token);
    return code;
}

-(void)prueba{
    NSString *url = @"http://138.197.95.215:8080/altruus-v2-authentication/api/v2/consumer/facebook_sign_in";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"1dd608f2-c6a1-11e3-851d-000c2940e62c" forKey:@"pushId"];
    [dict setObject:@"2" forKey:@"deviceTypeId"];
    [dict setObject:@"john@email.com" forKey:@"email"];
    [dict setObject:@"imei_123" forKey:@"imei"];
    [dict setObject:@"hLd2KmCZifCbkbmaj6iokQ==" forKey:@"password"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    NSString *jsonString;
    if (!jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSString *pushId = delegate.pushId;
    
    NSLog(@"****************************************************************************************************");
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        NSLog(@"Response: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
        
        NSLog(@"Dictionary: %@",dictionary);
        
        // do stuff
    }];
    
    
}
*/

- (void)showRegisterError
{
    NSString *title = NSLocalizedString(@"Error", nil);
    NSString *message = NSLocalizedString(@"There was an error signing you in. Maybe wrong username or password.Try again.", nil);
    [self showMessageWithTitle:title andMessage:message];
    
}


#pragma -mark UITextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self tappedLogin:nil];
    return NO;
}


@end
