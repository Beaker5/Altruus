//
//  RedeemViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/23/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "RedeemViewController.h"
#import "constants.h"
#import "COUtils.h"
#import "Promo+Utils.h"
#import "FeedbackViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <ZXingObjC.h>

@interface RedeemViewController ()
@property (weak, nonatomic) IBOutlet UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redeemCircleImage;


@property (weak, nonatomic) IBOutlet UIImageView *uniqueCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *uniqueCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTextToBannerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTextToBadgeConstraint;

@end

@implementation RedeemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    //[self createPromoObj];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendNotif];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setup
{
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];
    
    // Get current time and date
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hhmmayyMMd" options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    CGSize couponSize = self.redeemCircleImage.bounds.size;
    UILabel *dateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, couponSize.height - 53, couponSize.width - 10, 15)];
    dateTimeLabel.text = dateString;
    dateTimeLabel.textColor = [UIColor whiteColor];
    dateTimeLabel.font = [UIFont fontWithName:kAltruusFontBold size:12];
    
    UILabel *couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, couponSize.width-10, couponSize.height)];
    NSString *couponText;
    // Using white space for styling below
    if (self.screenType == CouponScreenGift){
        couponText = NSLocalizedString(@"Gifts Sent", nil);
    }
    else if (self.screenType == CouponScreenRedeem){
        couponText = NSLocalizedString(@"     Gift\nRedeemed", nil);
    }
    couponLabel.text = couponText;
    couponLabel.numberOfLines = 0;
    couponLabel.textColor = [UIColor whiteColor];
    couponLabel.font = [UIFont fontWithName:kAltruusFontBold size:17];
    
    [self.redeemCircleImage addSubview:couponLabel];
    [self.redeemCircleImage addSubview:dateTimeLabel];
    
    // Set up banners
    self.bannerLabel.text = NSLocalizedString(@"COUPON", nil);
    self.bannerLabel.textColor = [UIColor whiteColor];
    self.bannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:20];
    
    self.uniqueCodeLabel.textColor = [UIColor colorWithHexString:kColorBlue];
    self.uniqueCodeLabel.text = self.confirmation_number;
    
    self.companyNameLabel.textColor = [UIColor colorWithHexString:kColorBlue];
    self.companyNameLabel.text = self.merchant_name;
    
    
    [COUtils convertButton:self.homeButton withText:NSLocalizedString(@"DONE", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedHome:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    

    
    if (IS_IPHONE_4_OR_LESS){
        // move badge up and hide code label if iphone 4
        [self.uniqueCodeLabel removeConstraints:self.uniqueCodeLabel.constraints];
        self.uniqueCodeLabel.hidden = YES;
        self.topTextToBannerConstraint.constant = 15;
        self.topTextToBadgeConstraint.constant = 20;
    }
    
    // BArcode
    if (self.confirmation_number){
        NSError *error = nil;
        ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
        ZXBitMatrix *result = [writer encode:self.confirmation_number
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

- (IBAction)tappedHome:(UIButton *)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardFeedbackScreen];
    if ([vc isKindOfClass:[FeedbackViewController class]]){
        ((FeedbackViewController *)vc).screenType = FeedbackScreenFacebookAndTwitter;
        ((FeedbackViewController *)vc).redeemID = self.redeemID;
        ((FeedbackViewController *)vc).result = GiftResultGiftAndRedeem;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sendNotif
{
    if (!self.qrString && !self.merchant_name){
        return;
    }
    
    NSMutableDictionary *data = [@{}mutableCopy];
    if (self.qrString){
        data[@"code"] = self.qrString;
    }
    if (self.merchant_name){
        data[@"merchant"] = self.merchant_name;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedbackDisplayNotification object:self userInfo:data];
}

- (void)createPromoObj
{
   
    Promo *promo = [NSEntityDescription insertNewObjectForEntityForName:[Promo name] inManagedObjectContext:self.localUser.managedObjectContext];
    promo.shareText = self.shareText;
    promo.title = self.merchant_name;
    promo.from = self.merchant_name;
    promo.user = self.localUser;
    NSError *error;
    if (![promo.managedObjectContext save:&error]){
        DLog(@"Error is %@",error.localizedDescription);
    }
    
    
    
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
