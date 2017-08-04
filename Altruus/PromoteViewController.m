//
//  PromoteViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/21/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "PromoteViewController.h"
#import "RedeemViewController.h"
#import "FeedbackViewController.h"
#import "constants.h"
#import "COUtils.h"
#import "CObutton.h"
#import "CODefaultsHelper.h"
#import "EasyFacebook.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>
#import "COPromoCell.h"

typedef NS_ENUM(NSInteger, SocialCheck)
{
    SocialCheckFacebook,
    SocialCheckTwitter
};

@interface PromoteViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleBannerLabel;

@property (weak, nonatomic) IBOutlet UITableView *giftTableView;
@property (weak, nonatomic) IBOutlet UITableView *redeemTableView;
@property (strong,nonatomic) NSArray *giftData;
@property (strong,nonatomic) NSArray *redeemData;

@property (weak, nonatomic) IBOutlet CObutton *cancelButton;
@property (weak, nonatomic) IBOutlet CObutton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonsContainerView;

@property (strong, nonatomic) NSString *merchant_name;
@property (strong, nonatomic) NSNumber *redeemID;
@property (strong, nonatomic) NSString *confirmation_number;

@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) MBProgressHUD *giftHud;
@property (strong,nonatomic) MBProgressHUD *redeemHud;


// constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannersHeightConstraint;



@end

@implementation PromoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self fetchUserGiftsToShare];
    [self fetchUserRedeems];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)setup
{
    //NSDictionary *promotions = @{@"name":@"Test Promotion",@"description":@"Another description",@"first_name":@"Cj",@"last_name":@"ogbuehi"};
    //self.redeemData = [NSArray arrayWithObject:@{@"merchant_name":@"test1",@"promotions":promotions}];
    //self.giftData = [NSArray arrayWithObject:@{@"merchant_name":@"test1",@"promotions":promotions}];
    //[self.giftTableView reloadData];
    //[self.redeemTableView reloadData];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];

    self.bannerLabel.textColor = [UIColor whiteColor];
    self.middleBannerLabel.textColor = [UIColor whiteColor];
    
    if (IS_IPHONE_4_OR_LESS){
        self.bannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:13];
        self.middleBannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:13];
        self.bannersHeightConstraint.constant = 30;
    }
    else{
        self.bannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
        self.middleBannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
        self.bannersHeightConstraint.constant = 40;
    }
    
    self.bannerLabel.textColor = [UIColor whiteColor];
    self.bannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
    self.middleBannerLabel.textColor = [UIColor whiteColor];
    self.middleBannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
    
    [COUtils convertButton:self.cancelButton withText:NSLocalizedString(@"Cancel", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
    [COUtils convertButton:self.shareButton withText:NSLocalizedString(@"Next", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorYellow]];
    self.cancelButton.small = YES;
    self.shareButton.small = YES;
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:50];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(50, 50)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedCancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.bannerLabel.text = NSLocalizedString(@"GIFTING", nil);
    self.middleBannerLabel.text = NSLocalizedString(@"REDEEMING", nil);
    self.bottomButtonsContainerView.backgroundColor = [UIColor clearColor];
    
    
    self.giftTableView.delegate = self;
    self.giftTableView.dataSource = self;
    self.redeemTableView.delegate = self;
    self.redeemTableView.dataSource = self;
    self.giftTableView.allowsSelection = NO;
    self.redeemTableView.allowsSelection = NO;
    
    //self.bottomContainerBottomLayoutConstraint.constant = -self.bottomButtonsContainerView.frame.size.height;
    
    
}

- (void)fetchUserGiftsToShare
{
    // Gifting promos from merchant
    
    self.giftHud = [MBProgressHUD showHUDAddedTo:self.redeemTableView animated:YES];
    self.giftHud.mode = MBProgressHUDModeIndeterminate;
    
    [User fetchMerchantGiftsWithParams:@{@"code":self.qrString}
                                 block:^(APIRequestStatus status, NSArray *gifts, NSString *merchant, NSNumber *friendsCount) {
                                     if (status == APIRequestStatusSuccess){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.redeemHud hide:YES];
                                             self.giftData = gifts;
                                             self.merchant_name = merchant;
                                             if ([gifts count] > 0){
                                                 if (friendsCount){
                                                     NSString *giftingText = NSLocalizedString(@"GIFTING", nil);
                                                     NSString *friendsText = NSLocalizedString(@"FRIENDS", nil);
                                                     self.bannerLabel.text = [NSString stringWithFormat:@"%@ %@ %@",giftingText,friendsCount,friendsText];
                                                 }
                                                else{
                                                     self.bannerLabel.text = NSLocalizedString(@"GIFTING", nil);
                                                 }
                                                 
                                                 NSDictionary *promo = [self.giftData firstObject];
                                                 if ([promo isKindOfClass:[NSNull class]]){
                                                     self.bannerLabel.text = NSLocalizedString(@"NO PROMOTIONS ACTIVE", nil);
                                                      self.bottomContainerBottomLayoutConstraint.constant = -self.bottomButtonsContainerView.frame.size.height;
                                                 }
                                                 
                                                 [self.giftTableView reloadData];
                                             }
                                             else{
                                                 self.bannerLabel.text = NSLocalizedString(@"NO GIFTS FOUND", nil);
                                                  self.bottomContainerBottomLayoutConstraint.constant = -self.bottomButtonsContainerView.frame.size.height;
                                             }
                                             
                                         });
                                     }
                                     else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.redeemHud hide:YES];
                                             self.bannerLabel.text = NSLocalizedString(@"ERROR FETCHING GIFTS", nil);
                                             
                                         });
                                     }
                                 }];

    
    
}

- (void)fetchUserRedeems
{
    // Redeeming gifts from friends
    self.redeemHud = [MBProgressHUD showHUDAddedTo:self.giftTableView animated:YES];
    self.redeemHud.mode = MBProgressHUDModeIndeterminate;
    [User fetchMerchantRedeemsWithParams:@{@"code":self.qrString}
                                   block:^(APIRequestStatus status, NSArray *gifts, NSString *merchant, NSNumber *friendsCount) {
                                       if (status == APIRequestStatusSuccess){
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.giftHud hide:YES];
                                               self.redeemData = gifts;
                                               self.merchant_name = merchant;
                                               if ([gifts count] > 0){
                                                   self.middleBannerLabel.text = NSLocalizedString(@"REDEEMING", nil);
                                                   [self.redeemTableView reloadData];
                                               }
                                               else{
                                                   self.middleBannerLabel.text = NSLocalizedString(@"NO GIFTS TO REDEEM", nil);
                                               }
                                               
                                               NSNumber *giftId = [gifts firstObject][@"id"];
                                               self.giftID = giftId;
                                               
                                               
                                           });
                                       }
                                       else{
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.giftHud hide:YES];
                                               self.bannerLabel.text = NSLocalizedString(@"ERROR FETCHING GIFTS TO REDEEM", nil);
                                               
                                           });
                                       }
                                   }];

}



- (IBAction)tappedCancel:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)tappedShare:(UIButton *)sender {
      
    if (!self.qrString){
        [self.hud hide:YES];
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"There was an error getting the QR code.", nil)];
        return;
    }
    
    [self shareGiftsWithFriends];

        
    


}

- (void)redeemMerchantGifts
{
    if ([self.redeemData count] > 0){
        if (!self.giftID){
            NSString *title = NSLocalizedString(@"Error", nil);
            NSString *message = NSLocalizedString(@"There was an error storing gift id", nil);
            [self showMessageWithTitle:title andMessage:message];
            return;
        }
        self.hud = [MBProgressHUD showHUDAddedTo:self.redeemTableView animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = NSLocalizedString(@"Now lets redeem your gifts...", nil);
        
        NSDictionary *params = @{@"code":self.qrString,
                                 @"gift_id":self.giftID};
        
        [User redeemMerchantRedeemsWithParams:params
                                        block:^(APIRequestStatus status, id promoData) {
                                            if (status == APIRequestStatusSuccess){
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self.redeemID = promoData[@"redemption"][@"id"];
                                                    NSString *confirm = promoData[@"redemption"][@"promotion"][@"confirmation"];
                                                    if (confirm){
                                                        self.confirmation_number = confirm;
                                                    }
                                                    else{
                                                        self.confirmation_number = self.qrString;
                                                    }
                                                    
                                                    [self showRedeemScreen];
                                                });
                                            }
                                            else{
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.hud hide:YES];
                                                    NSString *title = NSLocalizedString(@"Error", nil);
                                                    NSString *message = NSLocalizedString(@"There was an error redeeming your gift", nil);
                                                    [self showMessageWithTitle:title andMessage:message];
                                                });
                                            }
                                        }];
    }
    else{
        [self showFacebookTwitterFeedbackScreen];

    }

}

- (void)shareGiftsWithFriends
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.giftTableView animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"First lets gift your friends...", nil);
    
    [User shareMerchantGiftsWithParams:@{@"code":self.qrString}
                                 block:^(APIRequestStatus status, id promoData) {
                                     if (status == APIRequestStatusSuccess){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.hud hide:YES];
                                             [self redeemMerchantGifts];
                                         });
                                     }
                                     else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             
                                             [self.hud hide:YES];
                                             NSString *title = NSLocalizedString(@"Error", nil);
                                             NSString *message = NSLocalizedString(@"There was an error sharing your gift with friends.", nil);
                                             [self showMessageWithTitle:title andMessage:message];
                                         });

                                     }
                                 }];
}


- (void)showRedeemScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardRedeemScreen];
    if ([controller isKindOfClass:[RedeemViewController class]]){
        ((RedeemViewController *)controller).localUser = self.localUser? self.localUser:nil;
        ((RedeemViewController *)controller).qrString = self.qrString? self.qrString:@"";
        ((RedeemViewController *)controller).merchant_name = self.merchant_name? self.merchant_name:@"";
        ((RedeemViewController *)controller).redeemID = self.redeemID? self.redeemID:nil;
        ((RedeemViewController *)controller).confirmation_number = self.confirmation_number? self.confirmation_number:@"";
        ((RedeemViewController *)controller).screenType = CouponScreenRedeem;
      
        // add some property to the controller or something
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)showFacebookTwitterFeedbackScreen
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardFeedbackScreen];
    if ([vc isKindOfClass:[FeedbackViewController class]]){
        ((FeedbackViewController *)vc).screenType = FeedbackScreenFacebookAndTwitter;
        ((FeedbackViewController *)vc).redeemID = self.redeemID;
        ((FeedbackViewController *)vc).result = GiftResultGift;
        ((FeedbackViewController *)vc).merchant_name = self.merchant_name;
        ((FeedbackViewController *)vc).qrString = self.qrString;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma -mark Tableview Datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // data count
    if (tableView == self.giftTableView){
        NSDictionary *promo = [self.giftData firstObject];
        if ([promo isKindOfClass:[NSNull class]]){
            return 0;
        }
        return [self.giftData count];
    }
    else if (tableView == self.redeemTableView){
        NSDictionary *promo = [self.redeemData firstObject];
        if ([promo isKindOfClass:[NSNull class]]){
            return 0;
        }
        return [self.redeemData count];
    }
    else{
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"promoCell"];
    if (!cell){
        [tableView registerNib:[UINib nibWithNibName:@"PromoCustomCell" bundle:nil] forCellReuseIdentifier:@"promoCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"promoCell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *promo;
    NSString *promoName;
    NSString *fromName;
    NSString *merchantName;
    
    
    ((COPromoCell *)cell).addressLabel.hidden = YES;
    ((COPromoCell *)cell).addressTitleLabel.hidden = YES;

    if (tableView == self.giftTableView){
        promo = [self.giftData objectAtIndex:indexPath.section];
        if (![promo isKindOfClass:[NSNull class]]){
            promoName = promo[@"name"]? promo[@"name"]:@"No Name Provided";
            merchantName = promo[@"merchant"][@"name"]? promo[@"merchant"][@"name"]:@"No Merchant Provided";
            //NSString *first = promo[@"promotions"][@"first_name"];
            //NSString *last = promo[@"promotions"][@"last_name"];
            fromName = merchantName;
        }
        else{
            self.bannerLabel.text = NSLocalizedString(@"NO PROMOTIONS ACTIVE", nil);
            //return;
        }
        
        ((COPromoCell *)cell).fromLabel.hidden = YES;
        ((COPromoCell *)cell).fromTitleLabel.hidden = YES;
    
        
    }
    else if (tableView == self.redeemTableView){
        promo = [self.redeemData objectAtIndex:indexPath.section];
        if (![promo isKindOfClass:[NSNull class]]){
            promoName = promo[@"promotion"][@"name"]? promo[@"promotion"][@"name"]:@"No Promotion Provided";
            merchantName = promo[@"merchant"][@"name"]? promo[@"merchant"][@"name"]:@"No Merchant Provided";
            NSString *first = promo[@"gifter"][@"first_name"];
            NSString *last = promo[@"gifter"][@"last_name"];
            fromName = [NSString stringWithFormat:@"%@ %@",first,last];
        }
        else{
            self.middleBannerLabel.text = NSLocalizedString(@"No Gifts To Redeem", nil);
            //return;
        }
        
    }
    

    
    ((COPromoCell *)cell).titleLabel.text = promoName;
    if (!fromName){
        ((COPromoCell *)cell).fromTitleLabel.hidden = YES;
        ((COPromoCell *)cell).fromLabel.hidden = YES;
    }
    else{
        ((COPromoCell *)cell).fromLabel.text = fromName;
    }
    ((COPromoCell *)cell).expiresTitleLabel.text = NSLocalizedString(@"Company:", nil);
    ((COPromoCell *)cell).expiresLabel.text = merchantName;
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view layoutIfNeeded];
    self.bottomContainerBottomLayoutConstraint.constant = 0;
    [UIView animateWithDuration:1 delay:0 options:0
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

#pragma -mark UIScrollview delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.view layoutIfNeeded];
    self.bottomContainerBottomLayoutConstraint.constant = 0;
    [UIView animateWithDuration:1 delay:0 options:0
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view layoutIfNeeded];
    self.bottomContainerBottomLayoutConstraint.constant = -self.bottomButtonsContainerView.frame.size.height;
    [UIView animateWithDuration:1 delay:0 options:0
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:nil];

}

#pragma -mark Helpers
-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
}


@end
