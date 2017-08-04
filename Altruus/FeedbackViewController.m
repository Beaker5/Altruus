//
//  FeedbackViewController.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/20/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "FeedbackViewController.h"
#import "RedeemViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>
#import "constants.h"
#import "NSString+utils.h"
#import "COUtils.h"
#import <Branch.h>


@interface FeedbackViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *bannerDisplayLabel;

@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;

@property (weak, nonatomic) IBOutlet UIView *anonContainerView;

@property (weak, nonatomic) IBOutlet UIButton *addLinkButton;
@property (strong,nonatomic) NSString *url;
@property (nonatomic) BOOL leaveAnon;
@property (strong,nonatomic) MBProgressHUD *hud;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceTextViewToBannerConstraint; // 42


@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    if (IS_IPHONE_4_OR_LESS){
        // if iphone4 need to move textview up if keyboard shows
        [self listenForNotifs];
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.screenType == FeedbackScreenFacebookAndTwitter){
        [self sendNotif];
        
        NSString *message;
        NSString *title = NSLocalizedString(@"Success", nil);
        NSString *ok = NSLocalizedString(@"OK", nil);
        if (self.result == GiftResultGift){
            message = NSLocalizedString(@"You successfully sent the gift to your friends! Now share your experience with Facebook", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)listenForNotifs
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBeingShown) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBeingHidden) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardBeingShown
{
    [self.view layoutIfNeeded];
    self.topSpaceTextViewToBannerConstraint.constant = 10;
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardBeingHidden
{
    [self.view layoutIfNeeded];
    self.topSpaceTextViewToBannerConstraint.constant = 42;
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
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

- (void)setup
{

    // Carry share link
    NSMutableDictionary *params = [@{} mutableCopy];
    if (self.localUser){
        params[@"userID"] = self.localUser.userID;
        params[@"username"] = self.localUser.username;
    }
    
    UIActivityItemProvider *itemProvider = [Branch getBranchActivityItemWithParams:params
                                                                           feature:@"social_share"
                                                                             stage:@"feedback"];
    NSURL *url = itemProvider.item;
    self.url = [url absoluteString];
    
    // Leave Anonymously
    self.leaveAnon = NO;
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];
    
    self.bannerDisplayLabel.textColor = [UIColor whiteColor];
    self.feedbackTextView.delegate = self;
    
    self.feedbackTextView.textColor = [UIColor lightGrayColor];
    self.feedbackTextView.layer.cornerRadius = 10;
    self.anonContainerView.backgroundColor = [UIColor clearColor];
    
    if (self.screenType == FeedbackScreenFeedback){
        self.bannerDisplayLabel.text = NSLocalizedString(@"Would you like to provide this business with feedback?", nil);
        self.bannerDisplayLabel.font = [UIFont fontWithName:kAltruusFontBold size:15];
        self.feedbackTextView.text = NSLocalizedString(@"Provide your feedback here...", nil);
        self.addLinkButton.hidden = YES;
    }
    else {
        self.bannerDisplayLabel.text = NSLocalizedString(@"Would you like to share on Facebook or Twitter?", nil);
        self.bannerDisplayLabel.font = [UIFont fontWithName:kAltruusFontBold size:15];
        self.feedbackTextView.text = NSLocalizedString(@"Don't forget to mention Altruus...", nil);
        self.anonContainerView.hidden = YES;
        [COUtils convertButton:self.addLinkButton withText:NSLocalizedString(@"ADD LINK TO ALTRUUS", nil) textColor:[UIColor whiteColor] buttonColor:[UIColor colorWithHexString:kColorYellow]];
    }

    

    
    
     FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
     [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
     UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    FAKIonIcons *checkIcon = [FAKIonIcons checkmarkRoundIconWithSize:35];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *checkImage = [checkIcon imageWithSize:CGSizeMake(35, 35)];
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithImage:checkImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedSend)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    if (IS_IPHONE_4_OR_LESS){
        //self.textViewHeightConstraint.constant = 110;
    }
}

- (IBAction)swipedLeaveAnonymous:(UISwitch *)sender {
    self.leaveAnon = sender.on;
}

- (void)tappedSend
{
    // check if leave anonymous then send to server
    //DLog(@"tapped send and anon:%@",[NSNumber numberWithBool:self.leaveAnon]);
    [self.feedbackTextView resignFirstResponder];
    
    
    if (self.screenType == FeedbackScreenFeedback){
        if ([self.feedbackTextView.text containsString:@"Provide your feedback here"]){
            NSString *title = NSLocalizedString(@"Error", nil);
            NSString *message = NSLocalizedString(@"Please enter feedback before sending.", nil);
            [self showAlertWithTitle:title message:message];
            return;
        }
        
        if (self.localUser){
            NSDictionary *feedback = @{@"notes":self.feedbackTextView.text,
                                       @"anonymous":[NSNumber numberWithBool:self.leaveAnon]};
            
            NSDictionary *parms = @{@"code":self.qrString,
                                    @"feedback":feedback};
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = NSLocalizedString(@"Sending Feedback...", nil);
            
            [User submitFeedbackWithParams:parms
                                     block:^(APIRequestStatus status, NSString *merchant_name) {
                                         [self.hud hide:YES];
                                         self.merchant_name = merchant_name;
                                         if (status == APIRequestStatusSuccess){
                                             [self doneSendingFeeback];
                                         }
                                         else if (status == APIRequestStatusFail){
                                             [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an error sending your feedback, please try again.", nil)];
                                         }
                                     }];
        }

    }
    
    else {
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = NSLocalizedString(@"Sharing caption...", nil);
        
        NSMutableDictionary *params = [@{@"message":self.feedbackTextView.text}mutableCopy];
        if (self.redeemID){
            params[@"id"] = self.redeemID;
        }
        
        [User socialShareWithParams:params block:^(APIRequestStatus success) {
            if (success == APIRequestStatusSuccess) {
                [self doneSendingFeeback];
            }
            else{
                [self.hud hide:YES];
                [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an error sharing your caption.", nil)];
            }
        }];

    }

    
}

- (IBAction)tappedAddLinkButton:(id)sender {
    [self addAltruusLink];
}


- (void)addAltruusLink
{
    if (!self.url){
        self.url = kAltruusInviteLink;
    }
    if ([self.feedbackTextView.text isEqualToString:@"Don't forget to mention Altruus..."] || [self.feedbackTextView.text isEqualToString:@""]){
        self.feedbackTextView.text = self.url;
    }
    else{
        self.feedbackTextView.text = [NSString stringWithFormat:@"%@ %@",self.feedbackTextView.text,self.url];
    }
}

- (void)doneSendingFeeback
{
    
    if (self.screenType == FeedbackScreenFeedback){
        NSString *title = NSLocalizedString(@"Success", nil);
        NSString *message = NSLocalizedString(@"Feedback Submitted", nil);
        [self showAlertWithTitle:title message:message];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    else{
        NSString *title = NSLocalizedString(@"Success", nil);
        NSString *message = NSLocalizedString(@"Message Posted", nil);
        [self showAlertWithTitle:title message:message];
        [self.navigationController popToRootViewControllerAnimated:YES]; 
    }
}

-(void)tappedCancel
{
    if (self.screenType == FeedbackScreenFeedback){
        // being presented by Profile controller here
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    else{
        // being presented after redeem screen here
        [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark Helpers

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}


#pragma mark UITextView Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSString *englishString;
    if (self.screenType == FeedbackScreenFeedback){
        englishString = NSLocalizedString(@"Provide your feedback here...", nil);
    }
    else{
        englishString = NSLocalizedString(@"Don't forget to mention Altruus...", nil);
    }
    
    if ([textView.text isEqualToString:englishString]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    NSString *englishString;
    if (self.screenType == FeedbackScreenFeedback){
        englishString = NSLocalizedString(@"Provide your feedback here...", nil);
    }
    else{
        englishString = NSLocalizedString(@"Don't forget to mention Altruus...", nil);
    }
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = englishString;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
}


@end
