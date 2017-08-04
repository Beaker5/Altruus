//
//  MyProfileViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/20/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "MyProfileViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Friends2ViewController.h"
#import "RSKImageCropViewController.h"
#import "UpdatesViewController.h"
#import "AppDelegate.h"
#import "User+Utils.h"
#import "Servicios.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DataProvider.h"
#import "ReceivedDeliveredViewController.h"


@interface MyProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backContainerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *recievedGiftsLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveredGiftsLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFriendsLabel;

@property (assign) BOOL setLocalPicture;
@property (assign) BOOL setFBPicture;

// Autolayout constants

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileHeightConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleStatsWidthConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleStatsHeightConstant;

@end

@implementation MyProfileViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    //Obtener el usuario local
    if (!self.localUser) {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        //self.localUser = [User getLocalUserInContext:context];
        self.localUser = [User getLocalUserSesion:context];
    }
    
    [self setupSlideMenu];
    [self setup];
    //[self handleProfilePic];
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer{
    NSLog(@"Tap");
    UIView *view = recognizer.view;
    CGPoint loc = [recognizer locationInView:view];
    UIView *subView = [view hitTest:loc withEvent:nil];
    NSInteger tagSelected = subView.tag;
    [self muestraPantalla:tagSelected];
}

-(void)muestraPantalla:(NSInteger)tagSelected{
    NSLog(@"LocalUser: %@", self.localUser);
    switch (tagSelected) {
        case 23:{
            NSLog(@"Received");
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"receivedSent"];
            if ([controller isKindOfClass:[ReceivedDeliveredViewController class]]) {
                ((ReceivedDeliveredViewController*)controller).localUser = self.localUser;
                ((ReceivedDeliveredViewController*)controller).screenType = @"R";
            }
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 24:{
            NSLog(@"Sent");
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"receivedSent"];
            if ([controller isKindOfClass:[ReceivedDeliveredViewController class]]) {
                ((ReceivedDeliveredViewController*)controller).localUser = self.localUser;
                ((ReceivedDeliveredViewController*)controller).screenType = @"S";
            }
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 25:{
            NSLog(@"Friends");
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardFriendsList];
            if ([controller isKindOfClass:[Friends2ViewController class]]) {
                ((Friends2ViewController*)controller).friendListType = FriendListTypeChooseFriend;
                ((Friends2ViewController*)controller).showBackButton = YES;
                ((Friends2ViewController*)controller).comingFromNavPush = YES;
                ((Friends2ViewController*)controller).localUser = self.localUser;
            }
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[self fetchFriendCount];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)setupSlideMenu{
    FAKIonIcons *backIcon = [FAKIonIcons naviconIconWithSize:35];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    
    if (self.showBackButton) {
        FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:35];
        [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    }
}

-(void)setup{
    NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.localUser.fbID];
    NSURL *fbURL = [NSURL URLWithString:fbString];
    NSData *dataImg = [NSData dataWithContentsOfURL:fbURL];
    
    self.profileImageView.image = [UIImage imageWithData:dataImg];
    
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
    
    self.profileNameLabel.text = self.localUser.username;
    self.deliveredGiftsLabel.text = @"0";
    self.recievedGiftsLabel.text = @"0";
    self.totalFriendsLabel.text = @"0";
    
    self.deliveredGiftsLabel.userInteractionEnabled = YES;
    self.recievedGiftsLabel.userInteractionEnabled = YES;
    self.totalFriendsLabel.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTap:)];
    //[self.deliveredGiftsLabel addGestureRecognizer:singleFingerTap];
    //[self.recievedGiftsLabel addGestureRecognizer:singleFingerTap];
    //[self.totalFriendsLabel addGestureRecognizer:singleFingerTap];
    [self.view addGestureRecognizer:singleFingerTap];
    /****************************************************************************************************/
    @try {
        if ([DataProvider networkConnected]) {
            AppDelegate *delegate = [AppDelegate sharedAppDelegate];
            NSManagedObjectContext *context = delegate.managedObjectContext;
            //self.localUser = [User getLocalUserInContext:context];
            self.localUser = [User getLocalUserSesion:context];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
            [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
            //ELIMINAR
            //[dict setObject:@"3r0lgu9g49jm4ivv14cd0jnreh" forKey:@"token"];
            //[dict setObject:@"1" forKey:@"userId"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            NSString *jsonString;
            if (!jsonData) {
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:USER_PROFILE]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = jsonData;
            
            NSURLResponse *res = nil;
            NSError *err = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
            
            NSInteger code = [httpResponse statusCode];
            dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"-----------------------------------------------------------------------------------");
            //NSLog(@"Codigo: %ld, Diccionario: %@", (long)code, array);
            //NSLog(@"-----------------------------------------------------------------------------------");
            if (code == 200) {
                NSString *country, *firstName, *friendsCount, *lastName, *receivedGifts, *sendGifts;
                country = [dict objectForKey:@"country"];
                firstName = [dict objectForKey:@"firstName"];
                friendsCount = [dict objectForKey:@"friendsCount"];
                lastName = [dict objectForKey:@"lastName"];
                receivedGifts = [dict objectForKey:@"receivedGifts"];
                sendGifts = [dict objectForKey:@"sentGifts"];
                
                NSLog(@"Diccionario %@", dict);
                
                self.deliveredGiftsLabel.text = [NSString stringWithFormat:@"%@", sendGifts];
                self.recievedGiftsLabel.text = [NSString stringWithFormat:@"%@", receivedGifts];;
                self.profileLocationLabel.text = country;
            }else{
                self.profileLocationLabel.text = @"";
            }
            self.totalFriendsLabel.text = [NSString stringWithFormat:@"%ld", [DataProvider getNumberOfFriends]];
            //self.totalFriendsLabel.text = [NSString stringWithFormat:@"%ld", contador];
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             //if (delegate.accessGranted) {
             ABAddressBookRef addressBook = ABAddressBookCreate();
             ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
             //NSMutableArray *contactList = [[NSMutableArray alloc] init];
             CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
             CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
             NSInteger contador = 0;
             for (int i=0;i < nPeople;i++) {
             BOOL guarda = NO;
             ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
             //Phone number
             NSString* mobileLabel;
             ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
             BOOL hasIphone = NO;
             BOOL hasMobile = NO;
             for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++){
             mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
             if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){
             hasMobile = YES;
             }else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]){
             hasIphone = YES;
             break ;
             }
             }
             if(hasIphone){
             guarda = YES;
             }else if(hasMobile){
             guarda = YES;
             }
             if (guarda) {
             contador++;
             }
             }
             //self.totalFriendsLabel.text = [NSString stringWithFormat:@"%ld", contador];
             
             //dispatch_semaphore_signal(semaphore);
             });
             // }
             });
             */
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
    
    /****************************************************************************************************/

    for (UIView *view in self.containerView.subviews){
        if (view.tag == 22 || view.tag == 23 || view.tag == 24 || view.tag == 25){
            view.backgroundColor = [UIColor altruus_duckEggBlueColor];
        }
    }
    
    for (UIView *view in [self.containerView subviews]){
        if (view.tag == 22){
            for (UIView *view2 in view.subviews){
                if (view2.tag == 1 || view2.tag == 3 || view2.tag == 2){
                    break;
                }
                if ([view2 isKindOfClass:[UIImageView class]]){
                    [((UIImageView *)view2) sd_setImageWithURL:[self.localUser imageUrl] placeholderImage:nil];
                }
            }
        }
    }
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5){
        self.bottomContainerHeightConstant.constant = 40;
        self.profileTopSpaceConstraint.constant = 5;
        self.profileHeightConstant.constant = 85;
        self.profileWidthConstant.constant = 85;
        self.middleStatsHeightConstant.constant = 60;
    }else{
        self.bottomContainerHeightConstant.constant = 80;
        self.profileTopSpaceConstraint.constant = 25;
        self.profileHeightConstant.constant = 100;
        self.profileWidthConstant.constant = 100;
        self.middleStatsHeightConstant.constant = 85;
    }
}

-(void)handleProfilePic{
    NSData *profilePicData = [[NSUserDefaults standardUserDefaults] valueForKey:kAltruusProfilePicPath];
    
    UIImage *personImage = nil;
    if (profilePicData) {
        if (!self.setLocalPicture) {
            personImage = [UIImage imageWithData:profilePicData];
            self.profileImageView.image = personImage;
            self.setLocalPicture = YES;
        }
    }else if([self.localUser.fbUser boolValue]){
        if (!self.setFBPicture) {
            //generar el ícono para la imagen
            FAKIonIcons *personIcon = [FAKIonIcons androidPersonIconWithSize:30];
            [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
            personImage = [personIcon imageWithSize:CGSizeMake(30, 30)];
            
            //Obtener la imagen de perfil de Facebook
            NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.localUser.fbID];
            NSURL *fbURL = [NSURL URLWithString:fbString];
            [self.profileImageView sd_setImageWithURL:fbURL placeholderImage:personImage options:SDWebImageRefreshCached];
            self.setFBPicture = YES;
        }
    }else{
        //Sino, mostrar ícono
        FAKIonIcons *personIcon = [FAKIonIcons androidPersonAddIconWithSize:30];
        [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        personImage = [personIcon imageWithSize:CGSizeMake(30, 30)];
        self.profileImageView.backgroundColor = [UIColor altruus_darkSkyBlueColor];
        self.profileImageView.image = personImage;
    }
}

-(void)fetchFriendCount{
    [User fetchFriendsOrFollowersOnScreen:FriendScreenFriends
                                withBlock:^(BOOL success, NSArray *friends) {
                                    if (success) {
                                        NSNumber *count = [NSNumber numberWithInteger:[friends count]];
                                        self.totalFriendsLabel.text = [NSString stringWithFormat:@"%@", count];
                                    }
                                }];
}

-(void)showMenu{
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"menu2"] animated:NO];
}

-(IBAction)tappedEditButton:(id)sender{}

-(IBAction)tappedRecieveView:(UITapGestureRecognizer*)sender{}

-(IBAction)tappedDeliveredView:(UITapGestureRecognizer*)sender{}

-(IBAction)tappedFriends:(UITapGestureRecognizer*)sender{}

/*
- (IBAction)tappedEditButton:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else{
        NSLog(@"no camarea");
    }
    
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)tappedRecieveView:(UITapGestureRecognizer *)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardUpdates];
    if ([controller isKindOfClass:[UpdatesViewController class]]){
        ((UpdatesViewController *)controller).screenType = ScreenTypeGiftsReceived;
        ((UpdatesViewController *)controller).showBackButton = YES;
    }
    
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:base animated:YES completion:nil];
}


- (IBAction)tappedDeliveredView:(UITapGestureRecognizer *)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardUpdates];
    if ([controller isKindOfClass:[UpdatesViewController class]]){
        ((UpdatesViewController *)controller).screenType = ScreenTypeGiftsSent;
        ((UpdatesViewController *)controller).showBackButton = YES;
    }
    
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:base animated:YES completion:nil];

}




- (IBAction)tappedFriends:(UITapGestureRecognizer *)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardFriendsList];
    if ([controller isKindOfClass:[Friends2ViewController class]]){
        ((Friends2ViewController *)controller).showBackButton = YES;
    }
    
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:base animated:YES completion:nil];
}


#pragma -mark Image cropper
-(void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage
{
    
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
        self.profileImageView.image = croppedImage;
        
        NSData *imageData = UIImagePNGRepresentation(croppedImage);
        [[NSUserDefaults standardUserDefaults] setValue:imageData forKey:kAltruusProfilePicPath];
        
        
    }];
    
}

-(void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
        self.profileImageView.image = croppedImage;
        
        NSData *imageData = UIImagePNGRepresentation(croppedImage);
        [[NSUserDefaults standardUserDefaults] setValue:imageData forKey:kAltruusProfilePicPath];


    }];
    
}


#pragma -mark Image picker stuff
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //NSLog(@"cancled");
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   UIImage *originalImage = nil;
                                   originalImage = info[UIImagePickerControllerOriginalImage];
                                   
                                   RSKImageCropViewController *crop = [[RSKImageCropViewController alloc] initWithImage:originalImage];
                                   
                                   crop.delegate = self;
                                   [self presentViewController:crop animated:YES completion:nil];
                               }];
}



*/
@end
