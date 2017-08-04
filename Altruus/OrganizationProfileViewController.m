//
//  OrganizationProfileViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/7/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "OrganizationProfileViewController.h"
#import "constants.h"
#import <UIImageView+WebCache.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import "GiftsViewController.h"


@interface OrganizationProfileViewController ()

@property (weak, nonatomic) IBOutlet UIView *backContainerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *popularGift1;
@property (weak, nonatomic) IBOutlet UIImageView *popularGift2;
@property (weak, nonatomic) IBOutlet UIImageView *popularGift3;


@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *popularGiftsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

// Autolayout constants

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileTopSpaceConstraint;



@end

@implementation OrganizationProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setup
{
    
    NSLog(@"Viene de amigos: %@, Friend: %@", self.vieneDeAmigos ? @"YES" : @"NO", self.friend);
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];

    if (self.organizationName){
        self.navigationItem.title = self.organizationName;
    }
    else{
        self.navigationItem.title = NSLocalizedString(@"Organizations", nil);
    }
    
    
    self.backContainerView.layer.cornerRadius = 10;
    self.backContainerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
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
    
    
    // Check if popular gifts, if not remove popular gifts label
    // and images
    if (1){
        self.popularGiftsLabel.text = @"3 most pupular gift including @Free bottle Pepsi";
    }
    self.bottomLabel.text = NSLocalizedString(@"Active gifts", nil);
    
    
    // My container views are colored in storyboard so i can see them
    // I added these tag numbers so now i change color to clrear
    for (UIView *view in self.containerView.subviews){
        if (view.tag == 22 || view.tag == 23 || view.tag == 24 || view.tag == 25){
            view.backgroundColor = [UIColor clearColor];
        }
    }
    
    
    for (UIView *view in [self.containerView subviews]){
        // Set first profile image here
        if ([view isKindOfClass:[UIImageView class]]){
            //((UIImageView *)view).image = [UIImage imageNamed:@"pepsi"];
            if (self.organization) {
                ((UIImageView *)view).image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.organization objectForKey:@"image"]]]];
                self.profileNameLabel.text = [self.organization objectForKey:@"name"];
                self.profileLocationLabel.text = [NSString stringWithFormat:@"Distance %@", [self.organization objectForKey:@"distance"]];
                
            }
            
            
            
            //self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PREFIJO_PHOTO, [dictionary objectForKey:@"picture"]]]]];
        }
        
        // Because container view contains bottom imgave view set them here
        if (view.tag == 22){
            for (UIView *view2 in view.subviews){
                if (view2.tag == 1 || view2.tag == 3 || view2.tag == 2){
                    break;
                }
                if ([view2 isKindOfClass:[UIImageView class]]){
                    [((UIImageView *)view2) sd_setImageWithURL:[NSURL URLWithString:@"http://loremflickr.com/320/240"] placeholderImage:nil];
                    
                    
                }
            }
        }
    }
    
    // size changes for smaller devices
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
        self.bottomContainerHeightConstant.constant = 40;
        self.profileTopSpaceConstraint.constant = 5;
        self.profileHeightConstant.constant = 85;
        self.profileWidthConstant.constant = 85;

    }
    else{
        //self.bottomContainerHeightConstant.constant = 80;
        self.profileTopSpaceConstraint.constant = 25;
        self.profileHeightConstant.constant = 100;
        self.profileWidthConstant.constant = 100;
    }
    

    

}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)tappedViewGifts:(UIButton *)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardGiftsHome];
    if ([controller isKindOfClass:[GiftsViewController class]]){
        ((GiftsViewController *)controller).removeSplashScreenIntro = YES;
        ((GiftsViewController *)controller).showBackButton = YES;
        ((GiftsViewController *)controller).gifterName = [self.organization objectForKey:@"name"];
        ((GiftsViewController *)controller).dontShowSearch = YES;
        ((GiftsViewController *)controller).organizationID = [[self.organization objectForKey:@"id"] integerValue];
        ((GiftsViewController *)controller).vieneDeAmigos = self.vieneDeAmigos;
        ((GiftsViewController *)controller).friend = self.friend;
    }
    
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:base animated:YES completion:nil];
    
}


@end
