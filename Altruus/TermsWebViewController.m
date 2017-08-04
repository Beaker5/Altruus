//
//  TermsWebViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 5/28/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "TermsWebViewController.h"
#import <UIWebView+BFKit.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"

static NSString *const kTermsPageUrl = @"http://www.altruus.com/web/user_terms_and_conditions";


@interface TermsWebViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation TermsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    [self showTermsPageWithUrl:kTermsPageUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setup
{
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];
    
    self.bannerLabel.textColor = [UIColor whiteColor];
    self.bannerLabel.font = [UIFont fontWithName:kAltruusFontBold size:20];
    self.bannerLabel.text = NSLocalizedString(@"Terms & Conditions", nil);
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showTermsPageWithUrl:(NSString *)url
{
    //[self.webview loadWebsite:url];
    //NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
    //NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@", htmlString);
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"terms" withExtension:@"html"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:url2]];
}

@end
