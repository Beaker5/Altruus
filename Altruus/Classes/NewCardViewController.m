//
//  NewCardViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 02/04/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//
#import <Stripe/Stripe.h>
#import "NewCardViewController.h"
#import "ChooseCardViewController.h"
#import "constants.h"
#import "Servicios.h"
#import "DataProvider.h"

//@interface NewCardViewController ()<STPPaymentCardTextFieldDelegate, NewCardViewControllerDelegate>
@interface NewCardViewController ()<STPPaymentCardTextFieldDelegate>

@property (strong, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) IBOutlet UIView *backContainerView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *addCardButton;


@end

@implementation NewCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
}

-(void)setup{
    self.backContainerView.layer.cornerRadius = 10;
    self.backContainerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
    self.backContainerView.layer.shadowOpacity = 0.7;
    self.backContainerView.layer.shadowRadius = 20;
    self.backContainerView.layer.shadowOffset = CGSizeZero;
    
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
    self.containerView.layer.shadowOpacity = 0.7;
    self.containerView.layer.shadowRadius = 1;
    self.containerView.layer.shadowOffset = CGSizeMake(10, 10);
    
    self.backContainerView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    self.addCardButton.layer.cornerRadius = 10;
    
    // Setup payment view
    //STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    //paymentTextField.delegate = self;
    //self.paymentTextField = paymentTextField;
    /*
    self.paymentTextField = [[STPPaymentCardTextField alloc] init];
    self.paymentTextField.delegate =self;
    self.paymentTextField.frame = CGRectMake(200, 300, 200, 40);
    [self.view addSubview:self.paymentTextField];
    */
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    //paymentTextField.cursorColor = [UIColor purpleColor];
    self.paymentTextField = paymentTextField;
    //self.paymentTextField.frame = CGRectMake(200, 200, 200, 40);
    
    CGFloat width = self.view.frame.size.width;
    width = width - self.textField.frame.size.width;
    width = width / 2;
    
    self.paymentTextField.frame = CGRectMake(width, self.textField.frame.origin.y, self.textField.frame.size.width, self.textField.frame.size.height);
    [self.view addSubview:paymentTextField];
    
    
    //self.paymentTextField = [[STPPaymentCardTextField alloc] init];
    //self.paymentTextField.delegate = self;
    
    
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
}

-(IBAction)tappedSaveCardButton:(UIButton*)sender{
    if (![self.paymentTextField isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        [self.delegate exampleViewController:self didFinishWithMessage:@"Please set a Stripe Publishable Key in Constants.m" andLast4:@""];
        return;
    }
    [self.activityIndicator startAnimating];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  [self.delegate exampleViewController:self didFinishWithError:error];
                                              }
                                              @try {
                                                  if ([DataProvider networkConnected]) {
                                                      NSInteger code = [self guardaTarjeta:token.tokenId];
                                                      //NSInteger code = 200;
                                                      if (code == 200) {
                                                          [self.delegate exampleViewController:self didFinishWithMessage:@"Card Added" andLast4:self.paymentTextField.cardParams.last4];
                                                      }else{
                                                          [self.delegate exampleViewController:self didFinishWithError:error];
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
                                              
                                              
                                          }];
    //if(![self.paymentTextField isValid]){ return;
        /*
        if (![self.paymentTextField isValid]) {
            NSLog(@"No es válida");
            return;
        }
        if (![Stripe defaultPublishableKey]) {
            NSError *error = [NSError errorWithDomain:StripeDomain
                                                 code:STPInvalidRequestError
                                             userInfo:@{
                                                        NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constant.h"
                                                        }];
            [self.delegate newCardViewController:self didFinish:error];
            return;
        }
        [self.activityIndicator startAnimating];
        [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.card
                                              completion:^(STPToken *token, NSError *error) {
                                                  [self.activityIndicator stopAnimating];
                                                  if (error == nil) {
                                                      [self.delegate newCardViewController:self didFinish:error];
                                                  }
                                              }];

       */
    //}
/*
    [self.activityIndicator startAnimating];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.card
                                          completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
                                              [self.activityIndicator stopAnimating];
                                              if (error == nil) {
                                                  [self.delegate newCardViewController:self didFinish:error];
                                              }
                                          }];
 */
}

-(NSInteger)guardaTarjeta:(NSString*)token{
    /*****************************************************************************/
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    //ELIMINAR
    //[dict setObject:@"kj4mopn72lbqts89k50p0k7ouu" forKey:@"token"];
    //[dict setObject:@"5" forKey:@"userId"];
    [dict setObject:token forKey:@"cardToken"];
    NSLog(@"Token: %@", token);
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:NEW_CARD]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    
    NSInteger code = [httpResponse statusCode];
    NSLog(@"Código: %ld, err: %@", (long)code, res);
    
    return code;
}

-(void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField{
    //NSLog(textField.isValid ? @"YES" : @"NO");
}
/*
- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    NSLog(textField.isValid ? @"YES" : @"NO");
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
