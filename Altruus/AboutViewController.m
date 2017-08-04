//
//  AboutViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/14/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "AboutViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"
#import "RoundedImageView.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIView *backContainerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet RoundedImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setup
{
 
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:30];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(30, 30)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.title = NSLocalizedString(@"About", nil);
    
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
    
    self.titleLabel.text = NSLocalizedString(@"About Altrüus", nil);
    self.subTitleLabel.text = NSLocalizedString(@"Our Idea", nil);
}

-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
