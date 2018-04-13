//
//  ChooseCardViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 01/04/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "ChooseCardViewController.h"
#import "constants.h"
#import "NewCardViewController.h"
#import "Servicios.h"
#import <Stripe/Stripe.h>
#import <MZFormSheetController.h>
#import "RedeemGiftViewController.h"
#import "DataProvider.h"

@interface ChooseCardViewController ()<ExampleViewControllerDelegate>

@property (nonatomic, assign) NSInteger numberCards;

@property (nonatomic, weak) IBOutlet UIView *backContainerView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UITextField *payPicker;
@property (nonatomic, weak) IBOutlet UIButton *payButton;


@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *arrayCards;

@end

@implementation ChooseCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberCards = 0;
    
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated{
    [self devuelveListaTarjetas];
}

-(void)setup{
    
    
    self.navigationItem.title = NSLocalizedString(@"Paid Gift", nil);
    
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
    
    self.payButton.layer.cornerRadius = 10;
    
    self.titleLabel.text = [self.gift objectForKey:@"giftName"];
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PREFIJO_PHOTO, [self.gift objectForKey:@"picture"]]]]];
    
    [self devuelveListaTarjetas];
    
    
    float price = [[self.gift objectForKey:@"price"] floatValue];
    if ([self.selectedFriends count] > 0) {
        price = price * [self.selectedFriends count];
    }
    
    NSString *priceString = [NSString stringWithFormat:@"%.02f", price];
    
    self.payButton.enabled = NO; 
    [self.payButton setTitle:[NSString stringWithFormat:@"PAY NOW $ %@", priceString] forState:UIControlStateNormal];
}

-(void)devuelveListaTarjetas{
    @try {
        if ([DataProvider networkConnected]) {
            self.numberCards = 0;
            
            NSString *urlString = [NSString stringWithFormat:@"%@?session=%@", LIST_CARDS_V3, self.localUser.session ];
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
            if (codeService == 200) {
                NSLog(@"Dictionary : %@", dictionary);
                NSDictionary *dictStatus = [dictionary objectForKey:@"status"];
                NSInteger code = [[dictStatus objectForKey:@"code"] integerValue];
                
                _cards = [NSMutableArray new];
                _arrayCards = [NSMutableArray new];
                _indexSelected = -1;
                
                if(code == 200){
                    NSArray *array = [dictionary objectForKey:@"results"];
                    for (NSDictionary *dict in array) {
                        [_cards addObject:[NSString stringWithFormat:@"**** **** **** %@", [dict objectForKey:@"last4"]]];
                        [_arrayCards addObject:dict];
                        
                        NSString *aux = [dict objectForKey:@"last4"];
                        if ([aux isEqualToString:_last4]) {
                            _indexSelected = self.numberCards;
                        }
                        
                        self.numberCards++;
                    }
                }
            }
            
            [_cards addObject:@"Add new card"];
            self.pickerCard = [[DownPicker alloc] initWithTextField:self.payPicker withData:_cards];
            [self.pickerCard setPlaceholder:@"Choose a card"];
            [self.pickerCard addTarget:self action:@selector(dp_selected:) forControlEvents:UIControlEventValueChanged];
            
            self.pickerCard.selectedIndex = _indexSelected;
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

-(void)dp_selected:(id)dp{
    NSInteger index = [self.pickerCard selectedIndex];
    
    if (index == _numberCards) {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newCard"];
        ((NewCardViewController*)controller).localUser = self.localUser;
        ((NewCardViewController*)controller).delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else{
        self.payButton.enabled = YES;
    }
}

-(IBAction)payGifts:(UIButton*)sender{
    NSInteger index = [self.pickerCard selectedIndex];
    if (index == -1 || index == _numberCards) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:@"Select Card"
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
    }else{
        [self sendGifts];
    }
}

-(void)sendGifts{
    BOOL error = NO;
    @try {
        if ([DataProvider networkConnected]) {
            if (self.giftingAction == GiftingActionSendGift) {
                for (Friends *friend in self.selectedFriends) {
                    NSInteger index = [self.pickerCard selectedIndex];
                    NSDictionary *card = [_arrayCards objectAtIndex:index];
                    
                    NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&giftId=%@&phone=%@&paymentMethodId=%@", SEND_PAID_GIFT_V3, self.localUser.session, [self.gift objectForKey:@"id"],friend.phoneNumber,[card objectForKey:@"id"]];
                    NSURL *url = [NSURL URLWithString:urlString];
                    NSLog(@"URL: %@", url);
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                       timeoutInterval:0.0];
                    NSURLResponse *response;
                    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
                    
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    NSInteger codeService = [httpResponse statusCode];
                    if (codeService == 200) {
                        NSLog(@"Dictionary : %@", dictionary);
                        //NSDictionary *dictStatus = [dictionary objectForKey:@"status"];
                        NSInteger code = [[dictionary objectForKey:@"code"] integerValue];
                        if (code != 200) {
                            error = YES;
                        }else{
                            //PENDIENTE
                        }
                    }
                    
                }//Fin for
                
            }else if(self.giftingAction == GiftingActionSendGiftToOneUser) {
                NSInteger index = [self.pickerCard selectedIndex];
                NSDictionary *card = [_arrayCards objectAtIndex:index];
                
                NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&giftId=%@&phone=%@&paymentMethodId=%@", SEND_PAID_GIFT_V3, self.localUser.session, [self.gift objectForKey:@"id"],self.friend.phoneNumber,[card objectForKey:@"id"]];
                NSURL *url = [NSURL URLWithString:urlString];
                NSLog(@"URL: %@", url);
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                   timeoutInterval:0.0];
                NSURLResponse *response;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger codeService = [httpResponse statusCode];
                if (codeService == 200) {
                    
                    NSInteger code = [[dictionary objectForKey:@"code"] integerValue];
                    if (code != 200) {
                        error = YES;
                    }else{
                        //PENDIENTE
                    }
                }
                
            }
            
            
            
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"ERROR"
                                      message:@"Can't Send Gift"
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }else{
                [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
                [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
                [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor altruus_duckEggBlueColor]];
                
                UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardRedeem];
                if ([controller isKindOfClass:[RedeemGiftViewController class]]) {
                    ((RedeemGiftViewController*) controller).screenType = RedeemScreenTypeSentGift;
                }
                
                MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
                formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
                formSheet.presentedFormSheetSize = CGSizeMake(300, 460);
                
                formSheet.formSheetWindow.transparentTouchEnabled = YES;
                [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                    //do something
                }];
                
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

#pragma mark - PaymentViewControllerDelegate Methods
- (void)newCardViewController:(NewCardViewController*)controller didFinish:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (error) {
            [self showDialougeWithTitle:@"Error" andMessage:[error localizedDescription]];
        } else {
            [self showDialougeWithTitle:@"Success" andMessage:@"Payment Successfully Created."];
        }
    }];
}

#pragma mark - Other Methods
- (void)showDialougeWithTitle:(NSString *)strTitle andMessage:(NSString *)strMessage
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:strTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - ExampleViewControllerDelegate

- (void)exampleViewController:(UIViewController *)controller didFinishWithMessage:(NSString *)message andLast4:(NSString*)last4{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.last4 = last4;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:action];
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error andMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        __block NSString *errorMessage = [NSString stringWithFormat:@"Can't Save Card\r%@", [message stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:action];
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
