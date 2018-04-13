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

@property (nonatomic, weak) NSString *messageService;


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
    

    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    self.paymentTextField = paymentTextField;
    
    CGFloat width = self.view.frame.size.width;
    width = width - self.textField.frame.size.width;
    width = width / 2;
    
    self.paymentTextField.frame = CGRectMake(width, self.textField.frame.origin.y, self.textField.frame.size.width, self.textField.frame.size.height);
    [self.view addSubview:paymentTextField];
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
    self.messageService = @"";
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
                                                  [self.delegate exampleViewController:self didFinishWithError:error andMessage:@"Error"];
                                              }
                                              @try {
                                                  if ([DataProvider networkConnected]) {
                                                      NSInteger code = [self guardaTarjeta:token.tokenId];
                                                      //NSInteger code = 200;
                                                      if (code == 200) {
                                                          [self.delegate exampleViewController:self didFinishWithMessage:@"Card Added" andLast4:self.paymentTextField.cardParams.last4];
                                                      }else{
                                                          [self.delegate exampleViewController:self didFinishWithError:error andMessage:self.messageService];
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
    
}

-(NSInteger)guardaTarjeta:(NSString*)token{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    [dict setObject:token forKey:@"cardToken"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&cardToken=%@", NEW_CARD_V3, self.localUser.session, token ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"URL: %@, URLSTRING: %@", urlString, url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:0.0];
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger codeService = [httpResponse statusCode];
    NSInteger code = 0;
    NSString *message;
    
    if (codeService == 200) {
        NSLog(@"Dictionary : %@", dictionary);
        code = [[dictionary objectForKey:@"code"] integerValue];
        message = [dictionary objectForKey:@"message"];
        self.messageService = message;
        return code;
    }else{
        return codeService;
    }
    
}

-(void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField{
    if(textField.isValid){
        [textField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
