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
        self.birthdayTextField.placeholder = @"Enter your birthday dd/mm/yyyy";
        self.countryPicker.placeholder = @"Pick your country";
        
        self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.birthdayTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.birthdayTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        if ([countryCode isEqualToString:@"MX"]) {
            self.birthdayTextField.placeholder = @"Enter your birthday dd/mm/yyyy";
        }else{
            self.birthdayTextField.placeholder = @"Enter your birthday mm/dd/yyyy";
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
                                    if(result.isCancelled){
                                        UIAlertView *alert = [[UIAlertView alloc]
                                                              initWithTitle:nil
                                                              message:@"Di clic en cancelar!"
                                                              delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                              otherButtonTitles:nil];
                                        [alert show];
                                        
                                    }
                                    if(error){
                                        UIAlertView *alert = [[UIAlertView alloc]
                                                              initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                              delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                              otherButtonTitles:nil];
                                        [alert show];
                                    }
                                    
                                }else{
                                    NSLog(@"Correcto");
                                    if ([FBSDKAccessToken currentAccessToken]) {
                                        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, first_name, last_name, email, id, gender, timezone, locale"}]
                                         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                             if (!error) {
                                                 //[self signInFacebook:result];
                                                 [self signInFacebookv3:result];
                                             }else{
                                                 NSLog(@"Error al obtener valores de Facebook %@",error);
                                                 [self.hud hide:YES];
                                             }
                                         }];
                                    }
                                }
                            }];
}

-(void)signInFacebookv3:(NSDictionary*)result{
    @try{
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        
        NSString *pushId = delegate.pushId;
        NSString *email = [result objectForKey:@"email"];
        NSString *idFB = [result objectForKey:@"id"];
        NSString *name = [result objectForKey:@"name"];
        
        if (email == NULL || email == nil || !email || email == (id)[NSNull null] || [email isEqualToString:@"(null)"]) {
            email =@"__________@altruus.com";
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:pushId forKey:@"pushId"];
        [dict setObject:email forKey:@"email"];
        [dict setObject:@"2" forKey:@"deviceTypeId"];
        [dict setObject:idFB forKey:@"facebookId"];
        [dict setObject:idFB forKey:@"imei"];
        
        NSLog(@"Dict: %@", dict);
        
        NSString *urlString = [NSString stringWithFormat:@"%@?email=%@&facebookId=%@&deviceType=2&imei=%@&pushId=%@", FACEBOOK_LOGIN_V3, email, idFB, idFB, pushId ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:0.0];
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger codeService = [httpResponse statusCode];
        
        //NSLog(@"Dictionary: %@. Respuesta: %@, HttpResponse: %@", dictionary, response, httpResponse);
        if (codeService == 200) {
            NSDictionary *dictStatus = [dictionary objectForKey:@"status"];
            NSLog(@"%@", dictStatus);
            NSInteger code = [[dictStatus objectForKey:@"code"] integerValue];
            NSString *message = [dictStatus objectForKey:@"message"];
            
            if (code == 200) {
                //Usuario encontrado
                NSString *firstName = [dictionary objectForKey:@"firstName"];
                NSString *lastName = [dictionary objectForKey:@"lastName"];
                email = [dictionary objectForKey:@"email"];
                if (email == NULL || email == nil || !email || email == (id)[NSNull null] || [email isEqualToString:@"(null)"]) {
                    email =@"__________@altruus.com";
                }
                NSString *phone = [dictionary objectForKey:@"phone"];
                NSString *session = [dictionary objectForKey:@"session"];
                NSString *sessionCreated = [dictionary objectForKey:@"sessionCreatedAt"];
                NSString *sessionExpires = [dictionary objectForKey:@"sessionExpiresAt"];
                
                AppDelegate *delegate = [AppDelegate sharedAppDelegate];
                NSManagedObjectContext *context = delegate.managedObjectContext;
                
                [User eliminaUsuario:context];
                
                User *usuario = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
                usuario.email = email;
                usuario.fbID = idFB;
                usuario.username = name;
                usuario.firstname = firstName;
                usuario.lastname = lastName;
                usuario.firstLogin = [NSNumber numberWithBool:NO];
                usuario.loggedIn = [NSNumber numberWithBool:YES];
                usuario.fbIDAltruus = idFB;
                
                usuario.tokenAltruus = session;
                //usuario.fbToken = token;
                usuario.pushID = pushId;
                usuario.userIDAltruus = @"1";
                usuario.session = session;
                usuario.sessionExpires = [NSString stringWithFormat:@"%@", sessionExpires];
                usuario.sessionCreated = [NSString stringWithFormat:@"%@", sessionCreated];;
                usuario.phoneNumber = phone;
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                }
                
                self.localUser = [User getLocalUserSesion:context];
                
                [self.hud hide:YES];
                
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.delegate controller:self];
                
            }else if (code == 401){
                if ([message isEqualToString:@"USER_ACCOUNT_NOT_REGISTERED"]) {
                    //Aquí se manda a llamar al registro de Facebook
                    [self.hud hide:YES];
                    _resultadoFacebook = result;
                    self.versionLabel.hidden = YES;
                    self.facebookButton.hidden = YES;
                    
                    self.phoneTextField.hidden = NO;
                    self.birthdayTextField.hidden = NO;
                    self.countryPicker.hidden = NO;
                    self.registerButton.hidden = NO;
                }else if([message isEqualToString:@"USER_ACCOUNT_NOT_ACTIVATED"]){
                    [self.hud hide:YES];
                    NSString *message = [NSString stringWithFormat:@"USER ACCOUNT NOT ACTIVATED"];
                    [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                }else if([message isEqualToString:@"USER_BLOCKED"]){
                    [self.hud hide:YES];
                    NSString *message = [NSString stringWithFormat:@"USER BLOCKED"];
                    [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                }else if([message isEqualToString:@"USER_BANNED"]){
                    [self.hud hide:YES];
                    NSString *message = [NSString stringWithFormat:@"USER BANNED"];
                    [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                }else if([message isEqualToString:@"WRONG_CREDENTIALS"]){
                    [self.hud hide:YES];
                    NSString *message = [NSString stringWithFormat:@"WRONG CREDENTIALS"];
                    [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                }
            }else if(code == 500){
                [self.hud hide:YES];
                NSString *message = [NSString stringWithFormat:@"Code 500"];
                [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
            }
        }else{
            [self.hud hide:YES];
            NSString *message = [NSString stringWithFormat:@"Server Down"];
            [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
        }
    }@catch(NSException *exception){
        [self.hud hide:YES];
        NSString *message = [NSString stringWithFormat:@"There was an error logging you in. Please try again. %@", exception.reason];
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
        NSLog(@"ERROR: %@", exception.reason);
        
    }@finally{
        
    }
}

- (IBAction)tappedRegisterv3:(UIButton *)sender {
    @try {
        if ([DataProvider networkConnected]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
            NSString *cCode = [currentLocale objectForKey:NSLocaleCountryCode];
            if ([cCode isEqualToString:@"MX"]) {
                [dateFormat setDateFormat:@"dd/mm/yyyy"];
            }else{
                [dateFormat setDateFormat:@"mm/dd/yyyy"];
            }
            
            NSDate *date = [dateFormat dateFromString:self.birthdayTextField.text];
            NSTimeInterval seconds = [date timeIntervalSince1970];
            double milliseconds = seconds*1000;
            //NSLog(@"Milliseconds: %f", milliseconds);
            
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
            //NSString *name = [_resultadoFacebook objectForKey:@"name"];
            NSString *first_name = [_resultadoFacebook objectForKey:@"first_name"];
            NSString *last_name = [_resultadoFacebook objectForKey:@"last_name"];
            //NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
            
            if (email == NULL || email == nil || !email || email == (id)[NSNull null] || [email isEqualToString:@"(null)"]) {
                email =@"__________@altruus.com";
            }
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:self.pickerCountry.text forKey:@"country"];
            [dict setObject:[NSNumber numberWithDouble:milliseconds] forKey:@"birthday"];
            [dict setObject:self.phoneTextField.text forKey:@"phone"];
            [dict setObject:email forKey:@"email"];
            [dict setObject:idFB forKey:@"facebookId"];
            [dict setObject:first_name forKey:@"firstName"];
            [dict setObject:last_name forKey:@"lastName"];
            [dict setObject:@"facebook" forKey:@"userType"];
            NSString *userType = @"facebook";
            NSString *phone = [self.phoneTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *country = self.pickerCountry.text;
            
            first_name = [first_name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            last_name = [last_name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            country = [country stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            NSString *urlString = [NSString stringWithFormat:@"%@?firstName=%@&lastName=%@&email=%@&facebookId=%@&phone=%@&userType=%@&birthDate=%@&country=%@", FACEBOOK_SIGN_UP_V3, first_name, last_name, email, idFB, phone, userType,[NSNumber numberWithDouble:milliseconds],country];
            NSURL *url = [NSURL URLWithString:urlString];
            @try{
                url = [NSURL URLWithString:urlString];
                NSLog(@"Correcto");
            }@catch(NSException *exception){
                NSLog(@"Error: %@", exception.reason);
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:0.0];
            NSURLResponse *response;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger codeService = [httpResponse statusCode];
            if(codeService == 200){
                NSInteger code = [[dictionary objectForKey:@"code"] integerValue];
                NSString *message = [dictionary objectForKey:@"message"];
                
                if (code == 201) {
                    //Usuario creado
                    [self signInFacebookv3:_resultadoFacebook];
                }else if (code == 400){
                    if ([message isEqualToString:@"WRONG_ENCRYPTION"]) {
                        NSString *message = [NSString stringWithFormat:@"WRONG ENCRYPTION"];
                        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                    }else if ([message isEqualToString:@"WRONG_DATE"]){
                        NSString *message = [NSString stringWithFormat:@"WRONG DATE"];
                        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                    }
                }else if (code == 401){
                    if ([message isEqualToString:@"USER_ALREADY_EXISTS"]) {
                        NSString *message = [NSString stringWithFormat:@"USER ALREADY EXISTS"];
                        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                    }else if ([message isEqualToString:@"PHONE_ALREADY_EXISTS"]){
                        NSString *message = [NSString stringWithFormat:@"PHONE ALREADY EXISTS"];
                        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                    }
                }else if (code == 500){
                    NSString *message = [NSString stringWithFormat:@"Code 500"];
                    [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(message, nil)];
                }
            }else{
                
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
                [dateFormat setDateFormat:@"dd/mm/yyyy"];
            }else{
                [dateFormat setDateFormat:@"mm/dd/yyyy"];
            }
            
            NSDate *date = [dateFormat dateFromString:self.birthdayTextField.text];
            NSTimeInterval seconds = [date timeIntervalSince1970];
            double milliseconds = seconds*1000;
            
            
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
            NSInteger countryCode = [self.pickerCountry selectedIndex] + 1;
            [dict setObject:[NSNumber numberWithInteger:countryCode] forKey:@"countryId"];
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
