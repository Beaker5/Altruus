//
//  MenuTableViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/20/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "MenuTableViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"
#import <Branch.h>
#import <Crashlytics/Answers.h>
#import <PSTAlertController.h>
#import <MessageUI/MessageUI.h>

@interface MenuTableViewController ()<MFMailComposeViewControllerDelegate>


@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"Menu", nil);
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(goBack)];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.view];
    
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)openAppStoreUrl
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/%@",kAltruusAppID]]];
    
}

- (void)showAboutPage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"about" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:kV2StoryboardAbout];
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:base animated:YES completion:nil];
    
}

- (void)showIntroScreens
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:kV2StoryboardIntroConroller];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)sendEmail
{
    
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Altrûus Support"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[kAltruusSupportEmail]];
        
        
        [self presentViewController:mail animated:YES completion:nil];
    }
    else{
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                     message:NSLocalizedString(@"Your device can't send email.", nil)
                                                  controller:self];
    }
}


- (void)tappedShare
{
    //NSString *inviteText = [NSString stringWithFormat:@"I just sent you a gift! Download Altruus from the following link to redeem."];
    //NSString *inviteText = [NSString stringWithFormat:@"Become happier by becoming a giver! Download Altrüus from the following link:"];
    NSString *inviteText = NSLocalizedString(@"Become happier by becoming a giver! Download Altrüus from the following link:", nil);
    /*
    if (![self.localUser.userID boolValue]){
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                      message:NSLocalizedString(@"Please log out and then log back in to use the new invite feature!", nil) controller:self];
        
    }
     */
    
    
    NSDictionary *params;
    if (self.localUser){
        params = @{@"userID":self.localUser.userID,
                    @"username":self.localUser.username};
    }
    else{
        params = @{};
    }
    
    UIActivityItemProvider *itemProvider = [Branch getBranchActivityItemWithParams:params
                                                                           feature:@"invite_friends"
                                                                             stage:@"pre_invite"];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[inviteText,itemProvider] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToTwitter,UIActivityTypeAirDrop,@"com.tumblr.tumblr.Share-With-Tumblr",@"com.apple.mobilenotes.SharingExtension",@"com.apple.reminders.RemindersEditorExtension"];
    //[self presentViewController:activityVC animated:YES completion:nil];
    
    if (IS_IPAD){
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)]){
            activityVC.popoverPresentationController.sourceView = self.view;
            
        }
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:(@selector(setCompletionWithItemsHandler:))]){
        // If above iOS 7
        [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *error){
            if (!completed){
                return;
            }
            
            [Answers logInviteWithMethod:@"Invited_Friends" customAttributes:@{@"invited_using":activityType,
                                                                               @"name":self.localUser.username,
                                                                               @"email":self.localUser.email}];
            
        }];
        
    }
    else{
        // iOS 7 or below
        [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed){
            if (!completed){
                return;
            }
            
            [Answers logInviteWithMethod:@"Invited_Friends" customAttributes:@{@"invited_using":activityType,
                                                                               @"name":self.localUser.username,
                                                                               @"email":self.localUser.email}];
        }];
        
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
    

}

- (void)logout
{
    
    
    self.localUser.loggedIn = [NSNumber numberWithBool:NO];
    [self.localUser.managedObjectContext save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kV2UserLoggedOut object:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}



#pragma mark - Mail
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            // About altruus
            [self showAboutPage];
            
        }
            break;
        case 1:
        {
            // How it works
            [self showIntroScreens];
        }
            break;
        case 2:
        {
            // Terms of use
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *terms = [sb instantiateViewControllerWithIdentifier:kStoryboardTermsScreen];
            [self.navigationController pushViewController:terms animated:YES];
            
        }
            break;
        case 3:
        {
            // Contact
            [self sendEmail];
        }
            break;
        case 4:
        {
            // Share Altruus
            
            [self tappedShare];
        }
            break;
        case 5:
        {
            // Rate Altruus
            [self openAppStoreUrl];
        }
            break;
        case 6:
        {
            // Log out
            [self logout];
            
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
