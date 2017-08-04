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

//@interface ChooseCardViewController ()<NewCardViewControllerDelegate, ExampleViewControllerDelegate>
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
    
    /*****************************************************************************/
    self.titleLabel.text = [self.gift objectForKey:@"giftName"];
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PREFIJO_PHOTO, [self.gift objectForKey:@"picture"]]]]];
    
    [self devuelveListaTarjetas];
    
    NSLog(@"GiftingAction : %ld", (long)self.giftingAction);
    
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
            /*****************************************************************************/
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
            [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
            //ELIMINAR
            //[dict setObject:@"kj4mopn72lbqts89k50p0k7ouu" forKey:@"token"];
            //[dict setObject:@"5" forKey:@"userId"];
            
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LIST_CARDS]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = jsonData;
            
            NSURLResponse *res = nil;
            NSError *err = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
            
            NSInteger code = [httpResponse statusCode];
            //NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            _cards = [NSMutableArray new];
            _arrayCards = [NSMutableArray new];
            _indexSelected = -1;
            
            if (code == 200) {
                NSLog(@"Array %@", array);
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
            /*****************************************************************************/
            
            //NSArray *cards = @[@"**** 3456", @"**** 5424", @"Add new card"];
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
        //((NewCardViewController*)controller).local = self.gift;
        ((NewCardViewController*)controller).localUser = self.localUser;
        ((NewCardViewController*)controller).delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else{
        self.payButton.enabled = YES;
    }
}

-(IBAction)payGifts:(UIButton*)sender{
    NSInteger index = [self.pickerCard selectedIndex];
    //NSLog(@"Index: %ld", (long)index);
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
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:friend.phoneNumber forKey:@"friendPhone"];
                    [dict setObject:[self.gift objectForKey:@"id"] forKey:@"giftId"];
                    [dict setObject:[card objectForKey:@"id"] forKey:@"paymentMethodId"];
                    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
                    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
                    //ELIMINAR
                    //[dict setObject:@"kj4mopn72lbqts89k50p0k7ouu" forKey:@"token"];
                    //[dict setObject:@"5" forKey:@"userId"];
                    
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SEND_PAID_GIFT]];
                    request.HTTPMethod = @"POST";
                    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    request.HTTPBody = jsonData;
                    
                    NSURLResponse *res = nil;
                    NSError *err = nil;
                    
                    //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                    [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                    
                    NSInteger code = [httpResponse statusCode];
                    NSLog(@"Code: %ld, Response: %@", (long)code, httpResponse);
                    if (code != 200) {
                        error = YES;
                    }
                }//Fin for
                
            }else if(self.giftingAction == GiftingActionSendGiftToOneUser) {
                NSInteger index = [self.pickerCard selectedIndex];
                NSDictionary *card = [_arrayCards objectAtIndex:index];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:self.friend.phoneNumber forKey:@"friendPhone"];
                [dict setObject:[self.gift objectForKey:@"id"] forKey:@"giftId"];
                [dict setObject:[card objectForKey:@"id"] forKey:@"paymentMethodId"];
                [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
                [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SEND_PAID_GIFT]];
                request.HTTPMethod = @"POST";
                [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                request.HTTPBody = jsonData;
                
                NSURLResponse *res = nil;
                NSError *err = nil;
                
                //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                
                NSInteger code = [httpResponse statusCode];
                NSLog(@"Code: %ld, Response: %@", (long)code, httpResponse);
                if (code != 200) {
                    error = YES;
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

- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        //UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Can't Save Card" preferredStyle:UIAlertControllerStyleAlert];
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
