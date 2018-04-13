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
    self.codeLabel.text = [NSString stringWithFormat:@"%@", [self.gift objectForKey:@"redeemCode"]];
    self.titleLabel.text = [self.gift objectForKey:@"giftName"];
    //self.dateLabel.text = [self.gift objectForKey:@"date"];
    self.dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.dateLabel.numberOfLines = 0;
    
    NSString *dateAux = [self.gift objectForKey:@"date"];
    NSArray *arrayAux = [dateAux componentsSeparatedByString:@" "];
    NSString *date, *hour;
    
    @try {
        date = [NSString stringWithFormat:@"%@ %@ %@", [arrayAux objectAtIndex:0],[arrayAux objectAtIndex:1],[arrayAux objectAtIndex:2]];
        hour = [NSString stringWithFormat:@"%@", [arrayAux objectAtIndex:3]];
    } @catch (NSException *exception) {
        
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%@\n%@",date,hour];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)tappedDone:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate cierraPantallaRedeem];
    
}



@end
