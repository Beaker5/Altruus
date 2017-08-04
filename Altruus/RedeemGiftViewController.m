//
//  RedeemGiftViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/6/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "RedeemGiftViewController.h"
#import <MZFormSheetController.h>
#import "constants.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <ZXingObjC.h>


@interface RedeemGiftViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *uniqueCodeImageView;
@property (weak, nonatomic) IBOutlet UIView *midContainerView;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong,nonatomic) AVPlayer *avPlayer;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midContainerViewHeight;



@end

@implementation RedeemGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *pathVideo;
    if (self.screenType == RedeemScreenTypeRedeemGift){
        pathVideo = [[NSBundle mainBundle] pathForResource:@"redeem-gift" ofType:@"mov"];
    }
    else if (self.screenType == RedeemScreenTypeSentGift){
        pathVideo = [[NSBundle mainBundle] pathForResource:@"cake" ofType:@"mov"];
    }
    
    if (pathVideo){
        NSURL *movieURL = [NSURL fileURLWithPath:pathVideo];
        
        self.avPlayer = [AVPlayer playerWithURL:movieURL];
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        videoLayer.frame = self.imageView.layer.bounds;
        
        videoLayer.videoGravity = AVLayerVideoGravityResize;
        videoLayer.backgroundColor = [[UIColor colorWithHexString:kColorBlue] CGColor];
        
        [self.imageView.layer addSublayer:videoLayer];
        
        [self.avPlayer play];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    self.codeLabel.layer.borderWidth = 1.5;
    self.codeLabel.layer.borderColor = [[UIColor altruus_veryLightBlueColor] CGColor];
    self.codeLabel.layer.cornerRadius = 10;
    
    self.midContainerView.backgroundColor = [UIColor clearColor];
    self.midContainerView.userInteractionEnabled = NO;
    
    if (self.screenType == RedeemScreenTypeRedeemGift){
        [self.backButton setTitle:NSLocalizedString(@"Back to updates", nil) forState:UIControlStateNormal];
        self.titleLabel.text = NSLocalizedString(@"Congratulations", nil);
        
        
        
        // set barcode image
        self.confirmationNumber = @"ALTRUUS123";
        
        if (self.confirmationNumber){
            NSError *error = nil;
            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
            ZXBitMatrix *result = [writer encode:self.confirmationNumber
                                          format:kBarcodeFormatCode39
                                           width:270
                                          height:40
                                           error:&error];
            if (result){
                UIImage *image = [[UIImage alloc] initWithCGImage:[[ZXImage imageWithMatrix:result] cgimage]];
                self.uniqueCodeImageView.image = image;
            }
            else{
                DLog(@"error is %@",error.localizedDescription);
            }
            
        }

        
    }
    else if (self.screenType == RedeemScreenTypeSentGift){
        self.codeLabelHeightConstraint.constant = 0;
        self.titleLabel.text = NSLocalizedString(@"Your gift has been sent", nil);
        self.imageView.image = [UIImage imageNamed:kAltruusSentGiftPicture];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.backButton setTitle:NSLocalizedString(@"Back Home", nil) forState:UIControlStateNormal];
        
        self.subTitleLabel.hidden = YES;
        
        // clear all views in container view and add share button
        for (UIView *view in self.midContainerView.subviews){
            [view removeFromSuperview];
        }
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.shareButton.layer.cornerRadius = 10;
        [self.shareButton setTitle:@"Share on Facebook" forState:UIControlStateNormal];
        [self.shareButton setBackgroundColor:[UIColor colorWithHexString:kv2ColorFacebookBlue]];
        [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(tappedShareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
        self.shareButton.frame = CGRectMake(20, 20, 200, 40);
        self.shareButton.hidden = YES;
        //self.shareButton.center = self.midContainerView.center;
        [self.midContainerView addSubview:self.shareButton];
        self.midContainerViewHeight.constant = 100;
        
        
    }
    
    
    
    
    
}

- (IBAction)tappedDone:(UIButton *)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        // do something
        [[NSNotificationCenter defaultCenter] postNotificationName:kV2NotificationRedeemDone object:nil];
        
    }];
}


- (void)tappedShareToFacebook:(UIButton *)sender {
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
