//
//  LoginV3ViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 17/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "LoginV3ViewController.h"
#import <NSStringMask/UITextFieldMask.h>
#import <MBProgressHUD.h>
#import "COKeyboardView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppDelegate.h"
#import "Servicios.h"
#import "User+Utils.h"
#import "DataProvider.h"


@interface LoginV3ViewController ()

@property (nonatomic, weak) IBOutlet UITextFieldMask *phoneTextField;
@property (nonatomic, weak) IBOutlet UITextFieldMask *birthdayTextField;
@property (nonatomic, weak) IBOutlet UITextField *countryPicker;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;


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

@property (strong, nonatomic) User *localUser;
@property (strong, nonatomic) NSDictionary *resultadoFacebook;

// Constraints

// Original 209
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConstraint;
// Original 185
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
// Original 35
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopspaceConstraint;
// Original 29
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextTopspaceConstraint;


@end

@implementation LoginV3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRegister];
}

-(void)setupRegister{
    @try {
        self.phoneTextField.placeholder = @"Enter your phone number";
        self.birthdayTextField.placeholder = @"Enter your birthday dd/MM/yyyy";
        self.countryPicker.placeholder = @"Pick your country";
        
        self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.birthdayTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.birthdayTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        if ([countryCode isEqualToString:@"MX"]) {
            self.birthdayTextField.placeholder = @"Enter your birthday dd/MM/yyyy";
        }else{
            self.birthdayTextField.placeholder = @"Enter your birthday MM/dd/yyyy";
        }
        
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
        
        self.facebookButton.hidden = NO;
        NSLog(@"Pasé setupRegister");
    } @catch (NSException *exception) {
        NSLog(@"Error setupRegister: %@", exception.reason);
    }
}

- (IBAction)tappedFacebook:(UIButton *)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //login.loginBehavior = FBSDKLoginBehaviorWeb;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Wait...", nil);
    
    [login logInWithReadPermissions:@[@"email"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error || result.isCancelled) {
                                    NSLog(@"Error o cancelé");
                                    [self.hud hide:YES];
                                }else{
                                    NSLog(@"Correcto");
                                    if ([FBSDKAccessToken currentAccessToken]) {
                                        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, first_name, last_name, email, id, gender, timezone, locale"}]
                                         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                             if (!error) {
                                                 [self signInFacebook:result];
                                             }else{
                                                 NSLog(@"Error al obtener valores de Facebook %@",error);
                                                 [self.hud hide:YES];
                                             }
                                         }];
                                    }
                                }
                            }];
}

-(void)signInFacebook:(NSDictionary*)result{
    @try {
        
        
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        
        NSString *pushId = delegate.pushId;
        NSString *email = [result objectForKey:@"email"];
        NSString *idFB = [result objectForKey:@"id"];
        NSString *name = [result objectForKey:@"name"];
        NSString *first_name = [result objectForKey:@"first_name"];
        NSString *last_name = [result objectForKey:@"last_name"];
        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
        //NSString *fbuserid = [FBSDKAccessToken currentAccessToken].userID;
        
        if (email == NULL || email == nil || !email || email == (id)[NSNull null] || [email isEqualToString:@"(null)"]) {
            email =@"__________@altruus.com";
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:pushId forKey:@"pushId"];
        [dict setObject:email forKey:@"email"];
        [dict setObject:@"2" forKey:@"deviceTypeId"];
        [dict setObject:idFB forKey:@"facebookId"];
        
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
        
        NSURLResponse *res = nil;
        NSError *err = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
        
        NSInteger code = [httpResponse statusCode];
        
        //NSLog(@"Res: %ld, Data: %@", code, dictionary);
        switch (code) {
            case 200:{
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *fbID = [dictionary objectForKey:@"facebookId"];
                NSString *idAltruus = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
                NSString *tokenAltruus = [dictionary objectForKey:@"token"];
                
                
                AppDelegate *delegate = [AppDelegate sharedAppDelegate];
                NSManagedObjectContext *context = delegate.managedObjectContext;
                
                [User eliminaUsuario:context];
                
                User *usuario = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
                usuario.email = email;
                usuario.fbID = idFB;
                usuario.username = name;
                usuario.firstname = first_name;
                usuario.lastname = last_name;
                usuario.firstLogin = [NSNumber numberWithBool:NO];
                usuario.loggedIn = [NSNumber numberWithBool:YES];
                usuario.fbIDAltruus = fbID;
                usuario.userIDAltruus = idAltruus;
                usuario.tokenAltruus = tokenAltruus;
                usuario.fbToken = token;
                usuario.pushID = pushId;
                usuario.userID = [NSNumber numberWithInteger:[idAltruus integerValue]];
                /*
                 if (_token){
                 [self saveLocalUserToken:_token];
                 }
                 */
                //[self.localUser.managedObjectContext save:nil];
                
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                }
                
                self.localUser = [User getLocalUserSesion:context];
                
                [self.hud hide:YES];
                
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.delegate controller:self];
                
                break;
            }
            case 406:{
                [self.hud hide:YES];
                _resultadoFacebook = result;
                self.versionLabel.hidden = YES;
                self.facebookButton.hidden = YES;
                
                self.phoneTextField.hidden = NO;
                self.birthdayTextField.hidden = NO;
                self.countryPicker.hidden = NO;
                self.registerButton.hidden = NO;
                
                break;
            }
            default:
                [self.hud hide:YES];
                break;
        }
        NSLog(@"LoginViewController Exitoso");
        
    } @catch (NSException *exception) {
        [self.hud hide:YES];
        NSString *message = [NSString stringWithFormat:@"There was an error logging you in. Please try again. %@", exception.reason];
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
        NSLog(@"ERROR: %@", exception.reason);
    } @finally {
        
    }
}

- (IBAction)tappedRegister:(UIButton *)sender {
    @try {
        if ([DataProvider networkConnected]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
            NSString *cCode = [currentLocale objectForKey:NSLocaleCountryCode];
            if ([cCode isEqualToString:@"MX"]) {
                [dateFormat setDateFormat:@"dd/MM/yyyy"];
            }else{
                [dateFormat setDateFormat:@"MM/dd/yyyy"];
            }
            
            NSDate *date = [dateFormat dateFromString:self.birthdayTextField.text];
            NSTimeInterval seconds = [date timeIntervalSince1970];
            double milliseconds = seconds*1000;
            //NSLog(@"Milliseconds: %f", milliseconds);
            /*
             NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:(milliseconds / 1000.0)];
             NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
             [dateFormat2 setDateFormat:@"dd/MM/yyyy"];
             NSString *dateString = [dateFormat2 stringFromDate:date2];
             NSLog(@"date: %@", dateString);
             */
            
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = NSLocalizedString(@"Wait...", nil);
            
            AppDelegate *delegate = [AppDelegate sharedAppDelegate];
            NSManagedObjectContext *context = delegate.managedObjectContext;
            self.localUser = [User getLocalUserSesion:context];
            NSLog(@"Local User: %@", self.localUser);
            
            //NSString *pushId = delegate.pushId;
            NSString *email = [_resultadoFacebook objectForKey:@"email"];
            NSString *idFB = [_resultadoFacebook objectForKey:@"id"];
            NSString *name = [_resultadoFacebook objectForKey:@"name"];
            NSString *first_name = [_resultadoFacebook objectForKey:@"first_name"];
            NSString *last_name = [_resultadoFacebook objectForKey:@"last_name"];
            NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
            
            if (email == NULL || email == nil || !email || email == (id)[NSNull null] || [email isEqualToString:@"(null)"]) {
                email =@"__________@altruus.com";
            }
            
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            //NSInteger countryCode = [self returnCountryCode:country];
            NSInteger countryCode = [self.pickerCountry selectedIndex] + 1;
            [dict setObject:[NSNumber numberWithInteger:countryCode] forKey:@"countryId"];
            //[dict setObject:self.birthdayTextField.text forKey:@"birthday"];
            [dict setObject:[NSNumber numberWithDouble:milliseconds] forKey:@"birthday"];
            [dict setObject:self.phoneTextField.text forKey:@"phone"];
            [dict setObject:email forKey:@"email"];
            [dict setObject:idFB forKey:@"facebookId"];
            [dict setObject:first_name forKey:@"firstName"];
            [dict setObject:last_name forKey:@"lastName"];
            
            
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
                NSString *pushId = delegate.pushId;
                //pushId = @"8278-2335-gdfg-335"; //ELIMINAR PUSHID
                
                dict = [[NSMutableDictionary alloc]init];
                [dict setObject:pushId forKey:@"pushId"];
                [dict setObject:email forKey:@"email"];
                [dict setObject:@"2" forKey:@"deviceTypeId"];
                [dict setObject:idFB forKey:@"facebookId"];
                
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
                    NSString *fbID = [dictionary objectForKey:@"facebookId"];
                    NSString *idAltruus = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
                    NSString *tokenAltruus = [dictionary objectForKey:@"token"];
                    
                    [User eliminaUsuario:context];
                    
                    User *usuario = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
                    usuario.email = email;
                    usuario.fbID = idFB;
                    usuario.username = name;
                    usuario.firstname = first_name;
                    usuario.lastname = last_name;
                    usuario.firstLogin = [NSNumber numberWithBool:NO];
                    usuario.loggedIn = [NSNumber numberWithBool:YES];
                    usuario.fbIDAltruus = fbID;
                    usuario.userIDAltruus = idAltruus;
                    usuario.tokenAltruus = tokenAltruus;
                    usuario.fbToken = token;
                    usuario.pushID = pushId;
                    usuario.userID = [NSNumber numberWithInteger:[idAltruus integerValue]];
                    
                    NSError *error;
                    if (![context save:&error]) {
                        NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                    }
                    
                    self.localUser = [User getLocalUserSesion:context];
                    
                    
                    [self dismissViewControllerAnimated:NO completion:nil];
                    [self.delegate controller:self];
                    
                    NSLog(@"Local User 3 : %@", self.localUser);
                }
            }
            [self.hud hide:YES];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"No Network Connection!"
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
    } @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"App Error"
                              message:exception.reason
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
