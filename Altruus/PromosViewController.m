//
//  PromosViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 5/15/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "PromosViewController.h"
#import "PromoteViewController.h"
#import "RedeemViewController.h"
#import "MapViewController.h"
#import "QRScreenViewController.h"
#import "COPromoCell.h"
#import "constants.h"
#import "Promo+Utils.h"
#import "COButton.h"
#import "COUtils.h"
#import <NSDate+DateTools.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>
#import <SCLAlertview.h>
#import <UIKit/UIKit.h>


@interface PromosViewController ()<UITableViewDelegate,UITableViewDataSource,COPromoCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSArray *promosData;
@property (strong, nonatomic) NSString *merchantName;
@property (strong,nonatomic) MBProgressHUD *hud;

// Bottom buttons
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;
@property (weak, nonatomic) IBOutlet CObutton *cancelButton;
@property (weak, nonatomic) IBOutlet CObutton *shareButton;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerBottomSpaceConstraint;

@end

@implementation PromosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    switch (self.screenType) {
        case PromosScreenGifts:
        {
            [self fetchMerchantsGifts];
        }
            break;
        case PromosScreenRedeem:
        {
            [self fetchUsersGifts];
        }
            break;
        case PromosScreenLast:
        {
            [self fetchUsersLastRedeem];
        }
            break;
        case PromosScreenAll:
        {
            [self fetchUserGiftsFromFriends];
        }
            break;
        default:
        {
             DLog(@"NO SCREENTYPE SET!");
        }
            break;
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setup
{
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    //self.tableview.contentInset = UIEdgeInsetsMake(0, 100, 0, 0);
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:50];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(50, 50)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];
    
    // show loading hud in imageview
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Loading Gifts..", nil);
    
    self.displayLabel.textColor = [UIColor whiteColor];
    self.displayLabel.font = [UIFont fontWithName:kAltruusFontBold size:20];
    
    if (self.screenType == PromosScreenGifts){
        self.tableview.allowsSelection = NO;
        self.displayLabel.text = NSLocalizedString(@"Share Gifts!", nil);
    
        self.buttonsContainer.backgroundColor = [UIColor clearColor];
        self.cancelButton.small = YES;
        self.shareButton.small = YES;

        [COUtils convertButton:self.cancelButton withText:NSLocalizedString(@"Cancel", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorBlue]];
        [COUtils convertButton:self.shareButton withText:NSLocalizedString(@"Share", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorYellow]];
        
        // remove bottom buttons for animation
        [self.view layoutIfNeeded];
        CGSize bottomSize = self.buttonsContainer.frame.size;
        self.buttonContainerBottomSpaceConstraint.constant = -bottomSize.height;
        [self.view layoutIfNeeded];
    }
    else if (self.screenType == PromosScreenRedeem){
        self.displayLabel.text = NSLocalizedString(@"Redeem Gifts!", nil);
        [self removeBottomButtons];
    }
    
    else if (self.screenType == PromosScreenLast){
        self.hud.labelText = NSLocalizedString(@"Loading Gift", nil);
        self.tableview.allowsSelection = NO;
        [self removeBottomButtons];
    }
    else if (self.screenType == PromosScreenAll){
        self.tableview.allowsSelection = YES;
        self.displayLabel.text = NSLocalizedString(@"Gifts From Friends!", nil);
        self.hud.labelText = NSLocalizedString(@"Loading Gifts", nil);
        [self removeBottomButtons];
    }

    
}

- (void)removeBottomButtons
{

    [self.buttonsContainer removeConstraints:self.buttonsContainer.constraints];
    [self.buttonsContainer removeFromSuperview];
    self.buttonsContainer = nil;
}

- (IBAction)tappedCancel:(UIButton *)sender {
    [self goBack];
}

- (IBAction)tappedShare:(UIButton *)sender {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Sharing With Friends..", nil);
    
    [User shareMerchantGiftsWithParams:@{@"code":self.qr_string}
                                 block:^(APIRequestStatus status, id promoData) {
                                     if (status == APIRequestStatusSuccess){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self showCouponScreen];
                                         });

                                     }
                                     else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.hud hide:YES];
                                             NSString *message = NSLocalizedString(@"There was an error sharing gifts.", nil);
                                             [self showError:message];
                                             
                                         });
                                     }
                                 }];
    
    
}



- (void)showCouponScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardRedeemScreen];
    if ([controller isKindOfClass:[RedeemViewController class]]){
        ((RedeemViewController *)controller).localUser = self.localUser;
        ((RedeemViewController *)controller).qrString = self.qr_string;
        ((RedeemViewController *)controller).merchant_name = self.merchantName;
        ((RedeemViewController *)controller).screenType = CouponScreenGift;
        
        // add some property to the controller or something
        [self.navigationController pushViewController:controller animated:YES];
    }

}

- (void)sendQRCodePurgeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPurgeQRCodeNotification object:self userInfo:nil];
}

- (void)showError:(NSString *)message
{
    NSString *title = NSLocalizedString(@"Error", nil);
    if (!message){
        message = NSLocalizedString(@"There was an error grabbing gifts.", nil);
    }
    self.displayLabel.text = title;
    [self sendQRCodePurgeNotification];
    [self showMessageWithTitle:title andMessage:message];
}

- (void)goBack
{
   
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark Fetches
- (void)fetchMerchantsGifts
{
    [User fetchMerchantGiftsWithParams:@{@"code":self.qr_string}
                                 block:^(APIRequestStatus status, NSArray *gifts, NSString *merchant, NSNumber *friendsCount) {
                                     if (status == APIRequestStatusSuccess){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             self.merchantName = merchant;
                                             self.displayLabel.text = [NSString stringWithFormat:@"Share Gifts from %@!",merchant];
                                             self.displayLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
                                             self.promosData = gifts;
                                             [self checkPromoCountAndIsGift:YES];
                                             [self.hud hide:YES];
                                             //NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [gifts count])];
                                             //[self.tableview reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
                                             
                                             // Animate bottom buttons up
                                             self.buttonContainerBottomSpaceConstraint.constant = 0;
                                             if (self.screenType == PromosScreenGifts){
                                                 [UIView animateWithDuration:1 delay:0
                                                                     options:UIViewAnimationOptionCurveEaseIn
                                                                  animations:^{
                                                                      [self.view layoutIfNeeded];
                                                                  } completion:nil];
                                             }
                                             
                                             [self.tableview reloadData];
                                             
                                             
                                         });
                                         
                                     }
                                     else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.hud hide:YES];
                                             [self showError:nil];
                                         });
                                         
                                     }
                                 }];
}

- (void)fetchUsersGifts
{
    BOOL all = NO;
    if (self.screenType == PromosScreenAll){
        all = YES;
    }
    [User fetchMerchantRedeemsWithParams:@{@"code":self.qr_string}
                                   block:^(APIRequestStatus status, NSArray *gifts, NSString *merchant, NSNumber *friendsCount) {
                                       if (status == APIRequestStatusSuccess){
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               self.merchantName = merchant;
                                                self.displayLabel.text = [NSString stringWithFormat:@"Gifts from %@!",merchant];
                                               self.displayLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
                                               self.promosData = gifts;
                                               [self checkPromoCountAndIsGift:YES];
                                               [self.hud hide:YES];
                                               [self.tableview reloadData];
                                           });
                                       }
                                       else{
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.hud hide:YES];
                                               [self showError:nil];
                                           });
                                           
                                       }
                                   }];
}

- (void)fetchUserGiftsFromFriends
{
    [User fetchUsersGiftsWithBlock:^(APIRequestStatus status, NSArray *gifts) {
        if (status == APIRequestStatusSuccess){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.promosData = gifts;
                [self checkPromoCountAndIsGift:YES];
                [self.hud hide:YES];
                [self.tableview reloadData];
            });

        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self showError:nil];
            });
        }
    }];
}
- (void)fetchUsersLastRedeem
{
    [User fetchAllRedeemsWithBlock:^(APIRequestStatus status, NSArray *gifts) {
        if (status == APIRequestStatusSuccess){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                id firstObject = [gifts lastObject];
                if (firstObject){
                    self.promosData = @[firstObject];
                    [self checkPromoCountAndIsGift:NO];
                    [self.tableview reloadData];
                }
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self showError:nil];
            });
        }
    }];
}

- (void)checkPromoCountAndIsGift:(BOOL)gift
{
    if ([self.promosData count] == 0){
        NSString *text = NSLocalizedString(@"No redemptions found",nil);
        if (gift){
            text = NSLocalizedString(@"No gifts found", nil);
        }
        self.displayLabel.text = text;
        
        NSString *error = NSLocalizedString(@"Oops", nil);
        NSString *message = NSLocalizedString(@"You have no gifts yet.", nil);
        [self showMessageWithTitle:error andMessage:message];
    }
}

#pragma -mark Tableview Datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.promosData count];
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

    NSDictionary *promo = [self.promosData objectAtIndex:indexPath.section];
    
    NSString *promoName;
    if (self.screenType == PromosScreenGifts){
        promoName = promo[@"name"];
    }
    else{
        promoName = promo[@"promotion"][@"name"];
    }
    
    return 200;
    /*
    if(promoName.length < 50){
        return 140;
    }
    else if (promoName.length > 50 && promoName.length < 90){
        return 170;
    }
    else{
        return 210;
    }
     */
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
    
    NSDictionary *promo = [self.promosData objectAtIndex:indexPath.section];
    
    NSString *promoName;
    NSString *fromName;
    NSString *merchantName;
    
    if (self.screenType == PromosScreenGifts){
        promoName= promo[@"name"];
        merchantName = promo[@"merchant"][@"name"];
    }
    else if (self.screenType == PromosScreenRedeem || self.screenType == PromosScreenAll){
        promoName = promo[@"promotion"][@"name"];
        merchantName = promo[@"merchant"][@"name"];
        NSString *first = promo[@"gifter"][@"first_name"];
        NSString *last = promo[@"gifter"][@"last_name"];
        fromName = [NSString stringWithFormat:@"%@ %@",first,last];
        NSString *street = promo[@"division"][@"address"];
        NSString *city = promo[@"division"][@"city"];
        NSString *state = promo[@"division"][@"state"];
        NSString *zip = promo[@"division"][@"postal"];
        NSString *address = NSLocalizedString(@"No address provided", nil);
        if ([street isKindOfClass:[NSNull class]] || [city isKindOfClass:[NSNull class]] || [state isKindOfClass:[NSNull class]] ){
            // not there so remove it
            ((COPromoCell *)cell).addressLabel.text = address;
            ((COPromoCell *)cell).addressLabel.textColor = [UIColor colorWithHexString:kColorBlue];
            ((COPromoCell *)cell).addressLabel.userInteractionEnabled = NO;
        }
        else{
            address = [NSString stringWithFormat:@"%@, %@, %@ %@",street,city,state,zip];
            ((COPromoCell *)cell).addressLabel.text = address;
        }
    }
    else if (self.screenType == PromosScreenLast){
        promoName = promo[@"promotion"][@"name"];
        merchantName = promo[@"merchant"][@"name"];
    }
    
    
    ((COPromoCell *)cell).titleLabel.text = promoName;
    ((COPromoCell *)cell).titleLabel.font = [UIFont fontWithName:kAltruusFontBold size:16];
    if (!fromName){
        ((COPromoCell *)cell).fromTitleLabel.hidden = YES;
        ((COPromoCell *)cell).fromLabel.hidden = YES;
    }
    else{
        ((COPromoCell *)cell).fromLabel.text = fromName;
    }
    ((COPromoCell *)cell).expiresTitleLabel.text = NSLocalizedString(@"Company:", nil);
    ((COPromoCell *)cell).expiresLabel.text = merchantName;
    ((COPromoCell *)cell).delegate = self;
    
    
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //dateFormat.dateFormat = @"MM/d/yyyy";
    //((COPromoCell *)cell).expiresLabel.text = [dateFormat stringFromDate:promo.expires];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.screenType == PromosScreenAll){
     
        FAKIonIcons *alertIcon = [FAKIonIcons arrowGraphUpRightIconWithSize:30];
        [alertIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *alertImage = [alertIcon imageWithSize:CGSizeMake(30, 30)];
        
        
        NSString *title = NSLocalizedString(@"Redeem Gift", nil);
        NSString *subtitle = NSLocalizedString(@"Are you ready to scan and redeem your gift?", nil);
        NSString *closeButton = NSLocalizedString(@"Cancel", nil);
        NSString *redeemButton = NSLocalizedString(@"Scan", nil);
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        //alert.showAnimationType = SlideInFromTop;
        //alert.hideAnimationType = SlideOutToBottom;
        [alert alertIsDismissed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            });

        }];
        
        [alert addButton:redeemButton actionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardQRScreen];
                if ([controller isKindOfClass:[QRScreenViewController class]]){
                    ((QRScreenViewController *)controller).screenType = QRScreenTypeGift;
                    ((QRScreenViewController *)controller).localUser = self.localUser;
                    [self.navigationController pushViewController:controller animated:YES];
                }

                //[self.navigationController popToRootViewControllerAnimated:YES];
            });
        }];
        [alert showCustom:alertImage color:[UIColor colorWithHexString:kColorBlue] title:title subTitle:subtitle closeButtonTitle:closeButton duration:0.0f];
        
    }
    else if (self.screenType == PromosScreenRedeem){
        NSDictionary *promo = [self.promosData objectAtIndex:indexPath.section];
        NSString *promoName = promo[@"promotion"][@"name"];
        NSString *description = promo[@"message"];
        NSNumber *giftID = promo[@"id"];
        NSString *first = promo[@"gifter"][@"first_name"];
        NSString *last = promo[@"gifter"][@"last_name"];
        NSString *gifterName = [NSString stringWithFormat:@"%@ %@",first,last];
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardPromoteScreen];
        if ([controller isKindOfClass:[PromoteViewController class]]){
            ((PromoteViewController *)controller).giftDescription = description;
            ((PromoteViewController *)controller).giftID = giftID;
            ((PromoteViewController *)controller).giftMerchantName = self.merchantName;
            ((PromoteViewController *)controller).giftName = promoName;
            ((PromoteViewController *)controller).giftSender = gifterName;
            ((PromoteViewController *)controller).qrString = self.qr_string;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    }
}

#pragma -mark CoPromoCell delegate

- (void)promoCell:(COPromoCell *)cell tappedAddressWithString:(NSString *)string
{
    DLog(@"cell %@ wants to show %@",cell,string);
    CLGeocoder *gecoder = [[CLGeocoder alloc] init];
    NSString *name = cell.expiresLabel.text;
    [gecoder geocodeAddressString:string
                completionHandler:^(NSArray *placemarks, NSError *error) {
                    if ([placemarks count] > 0){
                        CLPlacemark *placemark = [placemarks objectAtIndex:0];
                        CLLocation *location = placemark.location;
                        CLLocationCoordinate2D coordinate = location.coordinate;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardMapScreen];
                            if ([controller isKindOfClass:[MapViewController class]]){
                                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                annotation.coordinate = coordinate;
                                annotation.title = @"CJ Ogbuehis house";
                                ((MapViewController *)controller).coordinates = coordinate;
                                ((MapViewController *)controller).merchantName = name;
                                ((MapViewController *)controller).merchantAddress = string;
                                UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
                                [self presentViewController:base animated:YES completion:nil];
                            }
                            
                        });
                    }
                }];
    
}
#pragma -mark Getter
- (NSArray *)promosData
{
    if (!_promosData){
        _promosData = [NSArray array];
    }
    
    return _promosData;
}

#pragma mark Helpers

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
/*
 self.promosData = @[@{@"name":@"this is name",
 @"promotion":@{@"name":@"Truth Like AI Monday"},
 @"division":@{@"name":@"Coolio patterson and dipset i love new york and jay z wow",
 @"address":@"1203 Wilshire ct, Allen, TX"},
 @"gifter":@{@"first_name":@"CJ",
 @"last_name":@"Ogbuehi"}
 },
 @{@"name":@"this is name",
 @"promotion":@{@"name":@"Truth Like AI Monday"},
 @"division":@{@"name":@"Coolio patterson and dipset i love new york and jay z wow",
 @"address":@"345 E 7th st, Cincinnati, OH"},
 @"gifter":@{@"first_name":@"CJ",
 @"last_name":@"Ogbuehi"}
 },
 @{@"name":@"this is name",
 @"promotion":@{@"name":@"Truth Like AI Monday"},
 @"division":@{@"name":@"Coolio patterson and dipset i love new york and jay z wow"},
 @"gifter":@{@"first_name":@"CJ",
 @"last_name":@"Ogbuehi"}
 },
 @{@"name":@"this is name",
 @"promotion":@{@"name":@"Truth Like AI Monday"},
 @"division":@{@"name":@"Coolio patterson and dipset i love new york and jay z wow"},
 @"gifter":@{@"first_name":@"CJ",
 @"last_name":@"Ogbuehi"}
 }];
 */
@end
