//
//  GiftReceivedDetailViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 30/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "GiftReceivedDetailViewController.h"
#import "GiftReceivedViewController.h"
#import "Servicios.h"
#import "constants.h"
#import "DataProvider.h"

@interface GiftReceivedDetailViewController ()<RedeemControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *backContainerView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *adressLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *giftButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *giftImageHeightConstant;

@end

@implementation GiftReceivedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

-(void)setup{
    NSLog(@"Localuser: %@", self.localUser);
    NSLog(@"Gift: %@", self.giftReceived);
    
    self.navigationItem.title = NSLocalizedString(@"", nil);
    
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
    
    self.giftButton.layer.cornerRadius = 5.0;
    
    NSString *url = [NSString stringWithFormat:@"%@%@", PREFIJO_PHOTO_DETALLE,[self.giftReceived objectForKey:@"image"]];
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    NSLog(@"Imagen: %@",[self.giftReceived objectForKey:@"image"]);
    
    self.titleLabel.text = [self.giftReceived objectForKey:@"giftName"];
    self.adressLabel.text = [self.giftReceived objectForKey:@"merchantName"];
    
    @try {
        if ([DataProvider networkConnected]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
            [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
            [dict setObject:[self.giftReceived objectForKey:@"id"] forKey:@"giftId"];
            
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GIFT_INFO]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = jsonData;
            
            NSURLResponse *res = nil;
            NSError *err = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
            
            NSInteger code = [httpResponse statusCode];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSLog(@"Code: %ld, Dictionary: %@", (long)code, dictionary);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)tappedRedeemGiftButton:(UIButton*)sender{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"giftReceived"];
    ((GiftReceivedViewController*)controller).gift = self.giftReceived;
    ((GiftReceivedViewController*)controller).delegate = self;
    NSLog(@"Gift Received %@", self.giftReceived);
    NSString *price = [self.giftReceived objectForKey:@"price"];
    
    if(![price isEqualToString:@"0.00"]){
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        
        //NSLog(@"self.gift: %@", self.giftReceived);
        @try {
            if ([DataProvider networkConnected]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
                [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
                [dict setObject:[self.giftReceived objectForKey:@"giftCode"] forKey:@"code"];
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REDEEM_GIFT]];
                request.HTTPMethod = @"POST";
                [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                request.HTTPBody = jsonData;
                
                NSURLResponse *res = nil;
                NSError *err = nil;
                
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                
                NSInteger code = [httpResponse statusCode];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                //NSInteger code = 200;
                //NSLog(@"Code: %ld, Dictionary: %@", (long)code, dictionary);
                if (code == 200) {
                    [self presentViewController:controller animated:YES completion:nil];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"App Error"
                                          message:[NSString stringWithFormat:@"Error %ld", (long)code]
                                          delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
                    [alert show];
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
}

#pragma mark - RedeemControllerDelegate

-(void)cierraPantallaRedeem{
    [self.navigationController popViewControllerAnimated:NO];
}
/*
UIStoryboard *sb = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"giftReceived"];
((GiftReceivedViewController*)controller).gift = [self.data objectAtIndex:indexPath.row];
[self presentViewController:controller animated:YES completion:nil];
*/


@end
