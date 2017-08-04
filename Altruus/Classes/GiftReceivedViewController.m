//
//  GiftReceivedViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 08/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "GiftReceivedViewController.h"
#import <MZFormSheetController.h>
#import "constants.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "GiftReceivedDetailViewController.h"

@interface GiftReceivedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *uniqueCodeImageView;
@property (weak, nonatomic) IBOutlet UIView *midContainerView;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong,nonatomic) AVPlayer *avPlayer;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midContainerViewHeight;

@end

@implementation GiftReceivedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void)setup{
    
    //NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:[self.gift objectForKey:@"image"]]];
    //UIImage *image = [UIImage imageWithData: data];
    //self.imageView.image = image;
    self.codeLabel.text = [NSString stringWithFormat:@"%@", [self.gift objectForKey:@"giftCode"]];
    self.titleLabel.text = [self.gift objectForKey:@"giftName"];
    //self.dateLabel.text = [self.gift objectForKey:@"date"];
    self.dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.dateLabel.numberOfLines = 0;
    
    NSString *dateAux = [self.gift objectForKey:@"date"];
    NSArray *arrayAux = [dateAux componentsSeparatedByString:@" "];
    NSString *date, *hour;
    @try {
        date = [arrayAux objectAtIndex:0];
        hour = [arrayAux objectAtIndex:1];
    } @catch (NSException *exception) {
        
    }
    
    NSArray *dateSeparate = [date componentsSeparatedByString:@"/"];
    NSString *fechaFinal;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale currentLocale]];
    NSArray *months = [dateFormat monthSymbols];
    NSInteger mes = [[dateSeparate objectAtIndex:1] integerValue];
    NSInteger dia = [[dateSeparate objectAtIndex:0] integerValue];
    
    /*
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    if ([countryCode isEqualToString:@"MX"]) {
        fechaFinal = [NSString stringWithFormat:@"%@ %@ %@", [[months objectAtIndex:mes-1] capitalizedString], [dateSeparate objectAtIndex:0], [dateSeparate objectAtIndex:2]];
    }else{
        fechaFinal = [NSString stringWithFormat:@"%@ %@th %@", [[months objectAtIndex:mes-1] capitalizedString], [dateSeparate objectAtIndex:0], [dateSeparate objectAtIndex:2]];
    }*/
    fechaFinal = [NSString stringWithFormat:@"%@ %ld %@", [[months objectAtIndex:mes-1] capitalizedString], (long)dia, [dateSeparate objectAtIndex:2]];
    //NSLog(@"Fecha: %@", fechaFinal);
    
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@\n%@",fechaFinal,hour];
    
    //self.codeLabel.text = [self.gift objectForKey:@"giftCode"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)tappedDone:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate cierraPantallaRedeem];
    
    /*
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        // do something
        [[NSNotificationCenter defaultCenter] postNotificationName:kV2NotificationRedeemDone object:nil];
        
    }];
     */
}



@end
