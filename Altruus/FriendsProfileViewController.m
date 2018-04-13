//
//  FriendsProfileViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "FriendsProfileViewController.h"
#import "GiftsViewController.h"
#import "Friends2ViewController.h"
#import "OrganizationsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "constants.h"
#import "RoundedImageView.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>


@interface FriendsProfileViewController ()

@property (weak, nonatomic) IBOutlet UIView *backContainerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet RoundedImageView *mutualImageView1;
@property (weak, nonatomic) IBOutlet RoundedImageView *mutualImageview2;
@property (weak, nonatomic) IBOutlet RoundedImageView *mutualImageView3;

@property (weak, nonatomic) IBOutlet UIImageView *fbImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *fbImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *fbImageView3;


@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (weak, nonatomic) IBOutlet UIButton *allFriends;

@property (weak, nonatomic) IBOutlet UIButton *sendGiftButton;

// Autolayout constants

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleStatsWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleStatsHeightConstant;




@end

@implementation FriendsProfileViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setup];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)setup{
    self.mutualImageView1.hidden = YES;
    self.mutualImageview2.hidden = YES;
    self.mutualImageView3.hidden = YES;
    self.mutualFriendsLabel.hidden = YES;
    self.fbImageView1.hidden = YES;
    self.fbImageView2.hidden = YES;
    self.fbImageView3.hidden = YES;
    self.allFriends.hidden = YES;
    
    NSLog(@"Viene de amigos: %@, Friend: %@", self.vieneDeAmigos ? @"YES" : @"NO", self.friend.photo);
    
    NSParameterAssert(self.friend);
    if (self.showBackButton) {
        FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:35];
        [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Profile", self.friend.firstName];
    
    self.navigationItem.title = NSLocalizedString(@"Profile", nil);
    
    self.backContainerView.layer.cornerRadius = 5;
    self.containerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
    self.backContainerView.layer.shadowOpacity = 0.7;
    self.backContainerView.layer.shadowRadius = 20;
    self.backContainerView.layer.shadowOffset = CGSizeZero;
    
    self.containerView.layer.cornerRadius = 5;
    self.containerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
    self.containerView.layer.shadowOpacity = 0.7;
    self.containerView.layer.shadowRadius = 1;
    self.containerView.layer.shadowOffset = CGSizeMake(10, 10);
    
    self.backContainerView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    self.profileNameLabel.text = self.friend.fullName;
    NSString *sendGiftString = NSLocalizedString(@"Send Gift To", nil);
    
    [self.sendGiftButton setTitle:[NSString stringWithFormat:@"%@ %@", sendGiftString,self.friend.firstName] forState:UIControlStateNormal];
    
    for (UIView *view in self.containerView.subviews) {
        if (view.tag == 22 || view.tag == 23 || view.tag == 24 || view.tag == 25 ) {
            view.backgroundColor = [UIColor clearColor];
        }
    }
    
    if (![self.friend.photo isEqualToString:@""]) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.friend.photo]];
        self.profileImageView.image = [UIImage imageWithData:imageData];
    }
    if (self.estaFacebook) {
        NSData *imageData = [NSData dataWithContentsOfURL:self.urlPhoto];
        self.profileImageView.image = [UIImage imageWithData:imageData];
    }
    
    //Botón
    self.sendGiftButton.layer.cornerRadius = 5.0;
    
    // size changes for smaller devices
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
        self.bottomContainerHeightConstant.constant = 40;
        self.profileTopSpaceConstraint.constant = 5;
        self.profileHeightConstant.constant = 85;
        self.profileWidthConstant.constant = 85;
        self.middleStatsHeightConstant.constant = 60;
    }
    else{
        self.bottomContainerHeightConstant.constant = 80;
        self.profileTopSpaceConstraint.constant = 25;
        self.profileHeightConstant.constant = 100;
        self.profileWidthConstant.constant = 100;
        self.middleStatsHeightConstant.constant = 85;
    }
}

-(void)showMenu{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"menu2"] animated:NO];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)tappedEditButton:(UIButton*)sender{
    DLog(@"Tapped Button");
}

-(IBAction)tappedSendGiftButton:(UIButton*)sender{
    
    //Organizations
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Organizations"];
    if ([controller isKindOfClass:[OrganizationsViewController class]]) {
        ((OrganizationsViewController*)controller).friend = self.friend;
        ((OrganizationsViewController*)controller).vieneDeAmigos = YES;
        
    }
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)tappedViewFriends:(UIButton*)sender{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardFriendsList];
    if ([controller isKindOfClass:[Friends2ViewController class]]) {
        ((Friends2ViewController*)controller).showBackButton = YES;
    }
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:base animated:YES completion:nil];
}

@end
