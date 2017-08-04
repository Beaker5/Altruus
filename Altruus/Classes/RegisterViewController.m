//
//  RegisterViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 07/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "RegisterViewController.h"
#import <NSStringMask/UITextFieldMask.h>
#import "Servicios.h"
#import "AppDelegate.h"
#import "constants.h"
#import "DataProvider.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UITextFieldMask *phoneTextField;
@property (nonatomic, weak) IBOutlet UITextFieldMask *birthdayTextField;
@property (nonatomic, weak) IBOutlet UITextField *countryPicker;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

-(void)setup{
    self.phoneTextField.placeholder = @"Enter your phone number";
    self.birthdayTextField.placeholder = @"Enter your birthday";
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
    
    //heTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //theTextField.textAlignment = UITextAlignmentCenter;
    
    /*
     
    self.textField.mask = [[NSStringMask alloc] initWithPattern:@"\\+ (\\d{2}) \\((\\d{3})\\) (\\d{5})-(\\d{4})" placeholder:@"_"];
     */
    NSLog(@"Local User: %@", self.localUser);
}

- (IBAction)tappedRegister:(UIButton *)sender {
    @try {
        if ([DataProvider networkConnected]) {
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

- (void)saveLocalUserToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:kAltruusLocalUserAuthKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
