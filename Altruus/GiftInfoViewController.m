//
//  GiftInfoViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/6/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "GiftInfoViewController.h"
#import "RedeemGiftViewController.h"
#import "Friends2ViewController.h"
#import "ChooseCardViewController.h"
#import "constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MZFormSheetController.h>
#import "Servicios.h"
#import "DataProvider.h"
#import "AppDelegate.h"
#import <Branch.h>


@interface GiftInfoViewController ()<UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *backContainerView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *adressLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *giftButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *giftImageHeightConstant;


@end

@implementation GiftInfoViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setup];
    [self listenForNotifs];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setup{
    //self.userReceivingGift = @"Beto";
    //NSLog(@"-----------%@-----------", self.categoryString);
    
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftAIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    if (self.categoryString) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ Gifts", self.categoryString];
    }else{
        self.navigationItem.title = NSLocalizedString(@"Gifts", nil);
    }
    
    self.backContainerView.layer.cornerRadius = 10;
    self.backContainerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
    self.backContainerView.layer.shadowOpacity = 0.7;
    self.backContainerView.layer.shadowRadius = 20;
    self.backContainerView.layer.shadowOffset = CGSizeZero;
    
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.shadowColor = [[UIColor altruus_darkSkyBlue10Color] CGColor];
    self.containerView.layer.shadowOpacity = 0.7;
    self.containerView.layer.shadowRadius = 1;
    self.containerView.layer.shadowOffset = CGSizeMake(10, 10);
    
    self.backContainerView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    
    if (self.giftingAction == GiftingActionSendGift) {
        [self.giftButton setTitle:NSLocalizedString(@"Send Gift To Friends", nil) forState:UIControlStateNormal];
    }else if(self.giftingAction == GiftingActionRedeem){
        [self.giftButton setTitle:NSLocalizedString(@"Redeem Gift", nil) forState:UIControlStateNormal];
    }else if(self.giftingAction == GiftingActionSendGiftToOneUser){
        if(self.userReceivingGift) {
            
            //NSString *title = [NSString stringWithFormat:@"Send Gift to to %@", self.userReceivingGift];
            NSString *title = [NSString stringWithFormat:@"Send Gift To %@", self.friend.firstName];
            [self.giftButton setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
        }
    }
    NSLog(@"Viene de amigos: %@, Friend: %@", self.vieneDeAmigos ? @"YES" : @"NO", self.friend);
    if (self.vieneDeAmigos && self.friend) {
        NSString *title = [NSString stringWithFormat:@"Send Gift To %@", self.friend.firstName];
        [self.giftButton setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
    }
    
    self.giftButton.layer.cornerRadius = 10;
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        self.giftImageHeightConstant.constant = 150;
    }else{
        self.giftImageHeightConstant.constant = 200;
    }
    
    
    /*****************************************************************************/
    @try {
        if ([DataProvider networkConnected]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
            [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
            [dict setObject:[self.gift objectForKey:@"id"] forKey:@"giftId"];
            //[dict setObject:[self.gift objectForKey:@"id"] forKey:@"giftId"];
            //ELIMINAR
            //[dict setObject:@"3r0lgu9g49jm4ivv14cd0jnreh" forKey:@"token"];
            //[dict setObject:@"1" forKey:@"userId"];
            NSLog(@"UserID: %@", self.localUser.userIDAltruus);
            NSLog(@"Token: %@", self.localUser.tokenAltruus);
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GIFT_INFO]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = jsonData;
            
            NSURLResponse *res = nil;
            NSError *err = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
            
            NSInteger code = [httpResponse statusCode];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            //NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.gift objectForKey:@"image"]]];
            
            //self.imageView.image = [UIImage imageWithData:imageData];
            if (code == 200) {
                self.titleLabel.text = [dictionary objectForKey:@"giftName"];
                //self.descriptionLabel.text = [dictionary objectForKey:@"giftDescription"];
                self.descriptionLabel.text = [dictionary objectForKey:@"companyName"];
                NSString *price = [dictionary objectForKey:@"price"];
                if([price isEqualToString:@"0.00"]){
                    price = @"FREE";
                    self.categoryString = @"Free";
                }else{
                    self.categoryString = @"Paid";
                    price = [NSString stringWithFormat:@"$ %@", price];
                }
                self.adressLabel.text = price;
                
                //self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PREFIJO_PHOTO_DETALLE, [dictionary objectForKey:@"picture"]]]]];
                self.gift = dictionary;
            }else{
                self.titleLabel.text = @"";
                self.descriptionLabel.text = @"";
                self.adressLabel.text = @"";
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"No Network Connection!"
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
    } @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"App Error"
                              message:exception.reason
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
    }
    
    /*****************************************************************************/
}

-(void)listenForNotifs{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRedeemDone)
                                                 name:kV2NotificationRedeemDone
                                               object:nil];
}

-(void)handleRedeemDone{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(IBAction)tappedSendGiftButton:(UIButton*)sender{
    //Envía el regalo
    if (self.giftingAction == GiftingActionRedeem) {
        [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
        [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
        [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor altruus_duckEggBlueColor]];
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardRedeem];
        if ([controller isKindOfClass:[RedeemGiftViewController class]]) {
            ((RedeemGiftViewController*)controller).screenType = RedeemScreenTypeRedeemGift;
        }
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        formSheet.presentedFormSheetSize = CGSizeMake(300, 460);
        
        formSheet.formSheetWindow.transparentTouchEnabled = YES;
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            //
        }];
    }else if(self.giftingAction == GiftingActionSendGift && self.vieneDeAmigos == NO){
        //Enviar regalo desde la lista de regalos
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardFriendsList];
        if ([controller isKindOfClass:[Friends2ViewController class]]) {
            ((Friends2ViewController*)controller).friendListType = FriendListTypeChooseFriend;
            ((Friends2ViewController*)controller).showBackButton = YES;
            ((Friends2ViewController*)controller).comingFromNavPush = YES;
            ((Friends2ViewController*)controller).gift = self.gift;
            ((Friends2ViewController*)controller).localUser = self.localUser;
            ((Friends2ViewController*)controller).categoryString = self.categoryString;
            ((Friends2ViewController*)controller).giftingAction = self.giftingAction;
        }
        [self.navigationController pushViewController:controller animated:YES];
    }else if(self.giftingAction == GiftingActionSendGift && self.vieneDeAmigos == YES){
        //NSLog(@"CategoryString: %@", self.categoryString);
        
        if ([self.categoryString isEqualToString:@"Paid"]) {
            [self enviaRegaloPagado];
        }else{
            @try {
                if ([DataProvider networkConnected]) {
                    [self enviaRegaloGratis];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:@"No Network Connection!"
                                          delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
                    [alert show];
                }
            } @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"App Error"
                                      message:exception.reason
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
            
            
        }
        
    }else if(self.giftingAction == GiftingActionSendGiftToOneUser) {
        //Enviar regalo desde lista de amigos
        
        //NSLog(@"CategoryString: %@", self.categoryString);
        
        if ([self.categoryString isEqualToString:@"Paid"]) {
            [self enviaRegaloPagado];
        }else{
            @try {
                if ([DataProvider networkConnected]) {
                    [self enviaRegaloGratis];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:@"No Network Connection!"
                                          delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
                    [alert show];
                }
            } @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"App Error"
                                      message:exception.reason
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil];
                [alert show];
            }
            
        }
        /*
        [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
        [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
        [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor altruus_duckEggBlueColor]];
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardRedeem];
        if ([controller isKindOfClass:[RedeemGiftViewController class]]) {
            ((RedeemGiftViewController*)controller).screenType = RedeemScreenTypeSentGift;
        }
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        formSheet.presentedFormSheetSize = CGSizeMake(300, 460);
        
        formSheet.formSheetWindow.transparentTouchEnabled = YES;
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            //Código
        }];
         */
    }else{
        NSException *e = [NSException exceptionWithName:@"GiftingException" reason:@"Gifting action needs to be set on controller" userInfo:nil];
        @throw e;
    }
}

-(void)enviaRegaloGratis{
    NSLog(@"Phone Number: %@, Token: %@, userID: %@, giftID: %@", self.friend.phoneNumber, self.localUser.tokenAltruus, self.localUser.userIDAltruus, [self.gift objectForKey:@"id"] );
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    [dict setObject:self.friend.phoneNumber forKey:@"friendPhone"];
    [dict setObject:[self.gift objectForKey:@"id"] forKey:@"giftId"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SEND_FREE_GIFT]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSInteger code = [httpResponse statusCode];
    NSLog(@"-----------------------------------------------------------------------------------");
    NSLog(@"Codigo: %ld, Diccionario>>>>>>>>>>: %@", (long)code, dictionary);
    NSLog(@"-----------------------------------------------------------------------------------");
    
    
    if (code != 200) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"ERROR"
                              message:@"Can't Send Gift"
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
        [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
        [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor altruus_duckEggBlueColor]];
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardRedeem];
        if ([controller isKindOfClass:[RedeemGiftViewController class]]) {
            ((RedeemGiftViewController*) controller).screenType = RedeemScreenTypeSentGift;
        }
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        formSheet.presentedFormSheetSize = CGSizeMake(300, 460);
        
        formSheet.formSheetWindow.transparentTouchEnabled = YES;
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            //do something
        }];
        
        if (![self esUsuarioAltruus:self.friend.phoneNumber]) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not an Altrüus user!"
                                                           message:@"Your friend doesn't have Altrüus yet. Let them know so they can redeem their thoughtful gift!"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
            
            alert.tag=101;//add tag to alert
            [alert show];
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSString *inviteText = [NSString stringWithFormat:@"I just sent you a gift! Download Altrüus from the following link to redeem:"];
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
            [self presentViewController:activityVC animated:YES completion:nil];
        }
    }
}


-(void)enviaRegaloPagado{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"chooseCard"];
    ((ChooseCardViewController*)controller).gift = self.gift;
    ((ChooseCardViewController*)controller).localUser = self.localUser;
    ((ChooseCardViewController*)controller).giftingAction = self.giftingAction;
    ((ChooseCardViewController*)controller).friend = self.friend;
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(BOOL)esUsuarioAltruus:(NSString*)phoneNumber{
    NSArray* words = [phoneNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneAux = [words componentsJoinedByString:@""];
    
    if ([phoneAux length] > 10) {
        @try {
            phoneAux = [phoneAux substringFromIndex:[phoneAux length]-10];
        } @catch (NSException *exception) {
            NSLog(@"Error Al Recortar Teléfono: %@", exception);
        } @finally {
            
        }
    }
    
    @try {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        self.localUser = [User getLocalUserSesion:context];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
        [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
        [dict setObject:phoneAux forKey:@"phone"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *jsonString;
        if (!jsonData) {
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FIND_ALTRUUS_USER]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = jsonData;
        
        NSURLResponse *res = nil;
        NSError *err = nil;
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
        
        NSInteger code = [httpResponse statusCode];
        //NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        
        if (code == 200) {
            return YES;
        }else{
            return NO;
        }

    } @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
    
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
