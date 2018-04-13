//
//  GiftsViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 6/21/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "User+Utils.h"
#import "GiftsViewController.h"
#import "LoginViewController.h"
#import "GiftsTableViewCell.h"
#import "GiftInfoViewController.h"
#import "UISegmentedControl+Utils.h"
#import "constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PageItemViewController.h"
#import "IntroViewController.h"
#import "EasyFacebook.h"
#import <CoreLocation/CoreLocation.h>
#import "Servicios.h"
#import "LoginV3ViewController.h"
#import "DataProvider.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Friend.h"

#import <MZFormSheetController.h>
#import "RedeemGiftViewController.h"
#import "OrganizationsFreeViewController.h"

#import "LoadingTableViewCell.h"

@interface GiftsViewController ()<UITableViewDataSource, UITableViewDelegate, LoginDelegate, LoginDelegateV3, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *giftData;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic) AVPlayer *avPlayer;
@property (nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) UIView *splashContainer;
@property (strong, nonatomic) User *localUser;
@property (strong, nonatomic) NSDictionary *categoryMapping;
@property (assign) BOOL loginScreenShowing;

@property (assign) NSInteger batchSize;
@property (assign) NSInteger pageResults;
@property (assign) NSInteger actualResult;
@property (assign) NSInteger sizeResults;
@property (assign) NSInteger totalResultsFound;
@property (assign) NSInteger currentPage;
//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlHeight;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GiftsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    //COMENTADO code for sound
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //Obtener el usuario
    /*
    if (!self.localUser) {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        self.localUser = [User getLocalUserSesion:context];
        NSLog(@"Usuario: %@", self.localUser);
        //self.localUser = [User getLocalUserInContext:context];
        //[User getLocalUserSesion:context];
    }
    */
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.localUser = [User getLocalUserSesion:context];
    NSLog(@"Local User: %@ %@", self.localUser, self.localUser.email);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];

    
    [self setup];
    //[self addAndAnimateSplashScreen]; //COMENTE 190517
    [self listenForNotifs];
    [self checkEsPrimerLogueo];
    //self.vieneDeRegalosGratis = YES;
    
    //NSLog(@"Coordenadas: %@",[self deviceLocation]);
    //[self prueba];
}

-(void)prueba{
    /********************************/
    NSString *pushId = @"dcbac29e-6b14-4e06-9d1c-6ea432c1551a";
    NSString *email = @"beto.ven5@hotmail.com";
    NSString *idFB = @"10212570747730290";
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:pushId forKey:@"pushId"];
    [dict setObject:email forKey:@"email"];
    [dict setObject:@"2" forKey:@"deviceTypeId"];
    [dict setObject:idFB forKey:@"facebookId"];
    [dict setObject:idFB forKey:@"imei"];
    
    NSURL *url = [NSURL URLWithString:@"http://ec2-52-14-220-114.us-east-2.compute.amazonaws.com:8080/altruus-v3-ws-auth/v3/facebookLogin"];
    NSString *urlString = [NSString stringWithFormat:@"http://ec2-52-14-220-114.us-east-2.compute.amazonaws.com:8080/auth/v3/facebookLogin?email=%@&facebookId=%@&deviceType=2&imei=%@&pushId=%@", email, idFB, idFB, pushId ];
    url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:30.0];
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSLog(@"Dictionary: %@. Respuesta: %@, HttpResponse: %@", dictionary, response, httpResponse);
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"viewWillAppear");
    NSLog(@"vieneDeFree: %ld", (long)self.vieneDeRegalosGratis);
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.localUser = [User getLocalUserSesion:context];
    //Carga pantalla Login si es necesario
    //[self loginScreenCheck];
    //NSLog(@"Coordenadas: %@",[self deviceLocation]);
    //[self.tableView reloadData];
    
    [self fetchData]; //Comenté
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)checkEsPrimerLogueo{
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    //[User eliminaUsuario:context];
    NSInteger resultado = (long)[User esPrimerLogueo:context];
    if (resultado == 1) {
        //Muestra ventana de loguin
        [self.tabBarController setSelectedIndex:2];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
        UIViewController *login = [sb instantiateViewControllerWithIdentifier:@"login-v3"];
        ((LoginV3ViewController*)login).delegate = self;
        [self.navigationController presentViewController:login animated:NO completion:nil];
        //[self firstTimeLogInCheck];
        //Muestra instructivo
    }else{
        //No hace nada
    }
    self.localUser = [User getLocalUserSesion:context];
    
    
        //self.localUser = [User getLocalUserInContext:context];
        //[User getLocalUserSesion:context];
    
    //[User getLocalUserSesion:context];
}

-(void)controller:(UIViewController *)controller{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:kV2StoryboardIntroConroller];
    [self presentViewController:viewController animated:YES completion:nil];

}

-(void)setup{
    
    NSLog(@"Viene de amigos: %@, Friend: %@", self.vieneDeAmigos ? @"YES" : @"NO", self.friend);
    self.segmentedControl.selectedSegmentIndex = 2;
    
    [self.segmentedControl addTarget:self action:@selector(tappedHeaderSegment:) forControlEvents:UIControlEventValueChanged];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"PAID", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"FREE", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTitle:NSLocalizedString(@"POPULAR", nil) forSegmentAtIndex:2];
    
    self.categoryMapping = @{@(0):@"Paid",
                             @(1):@"Free",
                             @(2):@"Popular"};
    
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    
    // add search icon
    //COMENTADO
    //FAKIonIcons *searchIcon = [FAKIonIcons iosSearchStrongIconWithSize:30];
    //[searchIcon addAttribute:NSForegroundColorAttributeName value:[UIColor altruus_darkSkyBlueColor]];
    //UIImage *searchImage = [searchIcon imageWithSize:CGSizeMake(30, 30)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
    //                                                                          style:UIBarButtonItemStylePlain
    //                                                                         target:self
    //                                                                         action:@selector(tappedSearch)];
    if(self.dontShowSearch) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if(self.showBackButton){
        FAKIonIcons *backIcon;
        if (self.comingFromNavPush) {
            backIcon = [FAKIonIcons arrowLeftAIconWithSize:30];
        }else{
            backIcon = [FAKIonIcons closeRoundIconWithSize:30];
        }
        [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        UIImage *backImage = [backIcon imageWithSize:CGSizeMake(30, 30)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    }
    if(self.gifterName) {
        NSString *giftString = NSLocalizedString(@"Popular Gifts", nil);
        self.navigationItem.title = [NSString stringWithFormat:@"%@'s %@", self.gifterName, giftString];
    }else{
        self.navigationItem.title = NSLocalizedString(@"Popular Gifts", nil);
    }
    
    self.tableView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableView.layer.cornerRadius = 5;
}

-(void)listenForNotifs{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSplashVideo:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoginScreen)
                                                 name:kV2UserLoggedOut object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(muestraGratuitos:) name:@"NotifGratuitos" object:nil];
    
    _actualResult = 0;
    _currentPage = 1;
}

-(void)muestraGratuitos:(NSNotification*)notification{
    NSLog(@"HASTA ADENTRO");
    NSLog(@"%@", notification.userInfo);
    //self.organizationID = [notification.userInfo objectForKey:@"id"];
    self.vieneDeRegalosGratis = 1;
    [self fetchData];
}

-(void)addAndAnimateSplashScreen{
    if(!self.removeSplashScreenIntro) {
        //Se reproduce el video de Altruus
        self.splashContainer = [[UIView alloc] initWithFrame:self.view.frame];
        self.splashContainer.backgroundColor = [UIColor colorWithHexString:kColorBlue];
        
        NSString *pathVideo = [[NSBundle mainBundle] pathForResource:@"logo-altruus2" ofType:@"mov"];
        NSURL *movieURL = [NSURL fileURLWithPath:pathVideo];
        
        self.avPlayer = [AVPlayer playerWithURL:movieURL];
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        videoLayer.frame = self.splashContainer.bounds;
        
        videoLayer.videoGravity = AVLayerVideoGravityResize;
        videoLayer.backgroundColor = [[UIColor colorWithHexString:kColorBlue] CGColor];
        
        [self.splashContainer.layer addSublayer:videoLayer];
        [self.avPlayer play];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.splashContainer];
    }
}
//Rvisa que el usuario esté logueado
/*
-(void)loginScreenCheck{
    
    //NSLog(@"ESTO Logged In %@, User: %@", self.localUser.loggedIn, self.localUser );
    
    if ([self.localUser.loggedIn boolValue]) {
        if (![self.localUser.userID boolValue]) {
            self.localUser.loggedIn = [NSNumber numberWithBool:NO];
            [self.localUser.managedObjectContext save:nil];
            [self showLoginScreen];
        }
    }
    if ([self.localUser.fbUser boolValue]) {
        //Usuario Facebook
        FBSDKAccessToken *fbToken = [FBSDKAccessToken currentAccessToken];
        if([self.localUser.loggedIn boolValue] && fbToken) {
            //Entra a la página principal
            //Verifica si el token ha expirado, cierra sesión si es así
            NSDate *nowDate = [NSDate date];
            NSDate *tokenExpires = fbToken.expirationDate;
            if ([tokenExpires compare:nowDate] != NSOrderedDescending) {
                DLog(@"%@ token expired", fbToken);
                [self showLoginScreen];
            }
        }else{
            //Muestra la pantalla de logueo porque no se está logueado y no hay token
            [self showLoginScreen];
        }
    }else{
        //Logueado de otra forma que no es Facebook
        if (![self.localUser.loggedIn boolValue]) {
            [self showLoginScreen];
        }
    }
}
*/

-(void)showLoginScreen{
    [self.tabBarController setSelectedIndex:2];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
    UIViewController *login = [sb instantiateViewControllerWithIdentifier:kV2StoryboardLogin];
    
    if ([login isKindOfClass:[LoginViewController class]]) {
        ((LoginViewController *) login).delegate = self;
        ((LoginViewController *) login).localUser = self.localUser;
        self.loginScreenShowing = YES;
    }
    
    [self.navigationController presentViewController:login animated:NO completion:nil];
    
}

-(void)handleSplashVideo:(NSNotification*)notif{
    //Esta notificación es cuando termina de reproducirse el video
    if (notif.object == self.avPlayer.currentItem) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.splashContainer.alpha = 0;
                         } completion:^(BOOL finished) {
                             [self.splashContainer removeFromSuperview];
                         }];
    }
}

//COMENTÉ
-(void)firstTimeLogInCheck{
    //NSLog(@"Primer Login");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"intro" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:kV2StoryboardIntroConroller];
    [self presentViewController:controller animated:YES completion:nil];
    //[self.navigationController presentViewController:controller animated:YES completion:nil];
     
}

-(void)goBack{
    if(self.comingFromNavPush) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(GiftsType)screenType{
    return self.segmentedControl.selectedSegmentIndex;
}

-(void)tappedHeaderSegment:(UISegmentedControl*)control{
    _actualResult = 0;
    _currentPage = 1;
    [self fetchData];
    /*
    GiftsType type = [self screenType];
    if (type == GiftsTypePaid || type == GiftsTypePopular) {
        [self fetchData];
    }else{
        if(self.vieneDeRegalosGratis == 0){
            [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
            [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
            [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor altruus_duckEggBlueColor]];
            
            OrganizationsFreeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"organizationsFree"];
            //self.vieneDeRegalosGratis = YES;
            
            CGRect screenBound = [[UIScreen mainScreen] bounds];
            CGSize screenSize = screenBound.size;
            
            MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
            formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
            
            formSheet.presentedFormSheetSize = CGSizeMake(screenSize.width*0.80, screenSize.height*0.80);
            
            formSheet.formSheetWindow.transparentTouchEnabled = YES;
            [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                
            }];
        }else if(self.vieneDeRegalosGratis == 2){
            [self fetchData];
        }
    }
    */
}

-(void)fetchMoreData{
    //Mostrar ícono de descarga
    //self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    //self.hud.mode = MBProgressHUDModeIndeterminate;
    //self.hud.labelText = NSLocalizedString(@"Grabbing Gifts", nil);
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSArray *data =  [self returnGiftData];
    
    for (NSObject *object in data) {
        [self.giftData addObject:object];
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.giftData.count - 1 inSection:0]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    });
    //[self.hud hide:YES];
    
}

-(void)fetchData{
    self.giftData = nil;
    [self.tableView reloadData];
    
    GiftsType type = [self screenType];
    NSMutableDictionary *params = [@{} mutableCopy];
    switch (type) {
        case GiftsTypePaid:
            params[@"type"] = @"paid";
            break;
        case GiftsTypeFree:
            params[@"type"] = @"free";
            break;
        case GiftsTypePopular:
            params[@"type"] = @"popular";
            break;
        default:
            break;
    }
    //Mostrar ícono de descarga
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Grabbing Gifts", nil);
    
    if ([DataProvider getNumberOfFriends] == 0) {
        //[self getPhoneFriends];
    }
    
    /*
    //Llamar al servidor
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hud hide:YES];
        //self.giftData = self.giftData;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        self.giftData = [self returnGiftData];
        [self.hud hide:YES];
        [self.tableView reloadData];
        //self.giftData = self.giftData;
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

-(NSMutableArray*)returnGiftData{
    
        NSString *url = @"";
        NSString *urlAux = @"";
        NSMutableArray *arrayAux = [NSMutableArray new];
    
        GiftsType type = [self screenType];
        switch (type) {
            case GiftsTypePaid:{
                
                if (self.organizationID.length > 0) {
                    url = PAID_GIFTS_MERCHANT_V3;
                    urlAux = [NSString stringWithFormat:@"&merchantId=%@&giftType=paid&page=%ld", self.organizationID, (long)_currentPage];
                    NSLog(@"%@", urlAux);
                }else{
                    url = PAID_GIFTS_V3;
                    urlAux = [NSString stringWithFormat:@"&page=%ld&longitude=%f&latitude=%f", (long)_currentPage, self.locationManager.location.coordinate.longitude, self.locationManager.location.coordinate.latitude];
                    NSLog(@"%@", urlAux);
                }
                
                break;
            }
            case GiftsTypeFree:{
                NSLog(@"Self: %@", self.organizationID);
                if (self.organizationID.length > 0) {
                    url = FREE_GIFTS_MERCHANT_V3;
                    urlAux = [NSString stringWithFormat:@"&merchantId=%@&giftType=free&page=%ld", self.organizationID, (long)_currentPage];
                    NSLog(@"%@", urlAux);
                }else{
                    //url = FREE_GIFTS_V3;
                    url = FREE_GIFTS_V3;
                    urlAux = [NSString stringWithFormat:@"&page=%ld&longitude=%f&latitude=%f", (long)_currentPage, self.locationManager.location.coordinate.longitude, self.locationManager.location.coordinate.latitude];
                    NSLog(@"%@", urlAux);
                }
                
                /*
                if (self.vieneDeRegalosGratis == 1) {
                    self.organizationID = @"";
                    self.vieneDeRegalosGratis = 0;
                }
                */
                break;
            }
            case GiftsTypePopular:{
                if (self.organizationID.length > 0) {
                    url = POPULAR_GIFTS_MERCHANT_V3;
                    urlAux = [NSString stringWithFormat:@"&merchantId=%@&page=%ld", self.organizationID, (long)_currentPage];
                    NSLog(@"%@", urlAux);
                }else{
                    url = POPULAR_GIFTS_V3;
                    urlAux = [NSString stringWithFormat:@"&page=%ld&longitude=%f&latitude=%f", (long)_currentPage, self.locationManager.location.coordinate.longitude, self.locationManager.location.coordinate.latitude];
                    NSLog(@"%@", urlAux);
                }
                
                break;
            }
            default:
                break;
        }
        //NSLog(@"Local user: %@", self.localUser);
        if (self.localUser.userIDAltruus) {
            @try {
                if ([DataProvider networkConnected]) {
                    //NSLog(@"Coordenadas: %f, %f",self.locationManager.location.coordinate.longitude,self.locationManager.location.coordinate.latitude);
                    switch (type) {
                        case GiftsTypePaid:
                        case GiftsTypePopular:{
                            NSString *urlString = [NSString stringWithFormat:@"%@?session=%@%@", url, self.localUser.session, urlAux ];
                            NSURL *url = [NSURL URLWithString:urlString];
                            NSLog(@"URL: %@", urlString);
                            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                               timeoutInterval:0.0];
                            NSURLResponse *response;
                            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
                            
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                            NSInteger codeService = [httpResponse statusCode];
                            if (codeService == 200) {
                                NSLog(@"Dictionary : %@", dictionary);
                                NSDictionary *dictStatus = [dictionary objectForKey:@"status"];
                                NSInteger code = [[dictStatus objectForKey:@"code"] integerValue];
                                if(code == 200){
                                    _batchSize = [[dictionary objectForKey:@"batchSize"] integerValue];
                                    _pageResults = [[dictionary objectForKey:@"page"] integerValue];
                                    _sizeResults = [[dictionary objectForKey:@"size"] integerValue];
                                    _totalResultsFound = [[dictionary objectForKey:@"totalResultsFound"] integerValue];
                                    NSArray *array = [dictionary objectForKey:@"results"];
                                    NSDictionary *dict;
                                    NSString *title, *distance, *idGift, *likes, *merchantName, *picture, *price;
                                    _actualResult = _actualResult + [array count];
                                    for (NSDictionary *dictResult in array) {
                                        title = [dictResult objectForKey:@"name"];
                                        distance = [dictResult objectForKey:@"distance"];
                                        float distAux = [distance floatValue];
                                        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                        [fmt setPositiveFormat:@"0.##"];
                                        //NSLog(@"%@", [fmt stringFromNumber:[NSNumber numberWithFloat:25.342]]);
                                        //distance = [NSString stringWithFormat:@"%@ kms", distance];
                                        distance = [NSString stringWithFormat:@"%@ kms", [fmt stringFromNumber:[NSNumber numberWithFloat:distAux]]];
                                        idGift = [dictResult objectForKey:@"id"];
                                        likes = [NSString stringWithFormat:@"%@",[dictResult objectForKey:@"likes"]];
                                        merchantName = [dictResult objectForKey:@"merchantName"];
                                        picture = [dictResult objectForKey:@"picture"];
                                        price = [NSString stringWithFormat:@"%@",[dictResult objectForKey:@"price"]];
                                        if (!price) {
                                            price = @"FREE";
                                        }else if([price isEqualToString:@"0.00"]){
                                            price = @"FREE";
                                        }else{
                                            price = [NSString stringWithFormat:@"$ %@", price];
                                        }
                                        dict = @{@"title": title,
                                                 @"distance": distance,
                                                 @"id": idGift,
                                                 @"likes": likes,
                                                 @"merchantName": merchantName,
                                                 @"image": picture,
                                                 @"price": price};
                                        [arrayAux addObject:dict];
                                    }
                                }
                                //NSDictionary *dict;
                                //NSString *title, *distance, *idGift, *likes, *merchantName, *picture, *price;
                            }
                            
                            /*
                            
                            if(code == 200){
                                NSDictionary *dict;
                                NSString *title, *distance, *idGift, *likes, *merchantName, *picture, *price;
                                for (NSDictionary *dictionary in array) {
                                    title = [dictionary objectForKey:@"giftName"];
                                    distance = [dictionary objectForKey:@"distance"];
                                    distance = [NSString stringWithFormat:@"%@ kms", distance];
                                    idGift = [dictionary objectForKey:@"id"];
                                    likes = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"likes"]];
                                    merchantName = [dictionary objectForKey:@"merchantName"];
                                    picture = [dictionary objectForKey:@"picture"];
                                    price = [dictionary objectForKey:@"price"];
                                    if (!price) {
                                        price = @"FREE";
                                    }else if([price isEqualToString:@"0.00"]){
                                        price = @"FREE";
                                    }else{
                                        price = [NSString stringWithFormat:@"$ %@", price];
                                    }
                                    dict = @{@"title": title,
                                             @"distance": distance,
                                             @"id": idGift,
                                             @"likes": likes,
                                             @"merchantName": merchantName,
                                             @"image": picture,
                                             @"price": price};
                                    [arrayAux addObject:dict];
                                }
                            }
                            
                            */
                            break;
                        }
                        case GiftsTypeFree:{
                            //if(self.organizationID.length > 0){
                                NSString *urlString = [NSString stringWithFormat:@"%@?session=%@%@", url, self.localUser.session, urlAux ];
                                NSURL *url = [NSURL URLWithString:urlString];
                                NSLog(@"URL: %@", urlString);
                                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                                   timeoutInterval:0.0];
                                NSURLResponse *response;
                                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
                                
                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                NSInteger codeService = [httpResponse statusCode];
                                if (codeService == 200) {
                                    NSLog(@"Dictionary : %@", dictionary);
                                    NSDictionary *dictStatus = [dictionary objectForKey:@"status"];
                                    NSInteger code = [[dictStatus objectForKey:@"code"] integerValue];
                                    if(code == 200){
                                        _batchSize = [[dictionary objectForKey:@"batchSize"] integerValue];
                                        _pageResults = [[dictionary objectForKey:@"page"] integerValue];
                                        _sizeResults = [[dictionary objectForKey:@"size"] integerValue];
                                        _totalResultsFound = [[dictionary objectForKey:@"totalResultsFound"] integerValue];
                                        NSArray *array = [dictionary objectForKey:@"results"];
                                        NSDictionary *dict;
                                        NSString *title, *distance, *idGift, *likes, *merchantName, *picture, *price;
                                        _actualResult = _actualResult + [array count];
                                        for (NSDictionary *dictResult in array) {
                                            title = [dictResult objectForKey:@"name"];
                                            distance = [dictResult objectForKey:@"distance"];
                                            float distAux = [distance floatValue];
                                            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                            [fmt setPositiveFormat:@"0.##"];
                                            distance = [NSString stringWithFormat:@"%@ kms", [fmt stringFromNumber:[NSNumber numberWithFloat:distAux]]];
                                            idGift = [dictResult objectForKey:@"id"];
                                            likes = [NSString stringWithFormat:@"%@",[dictResult objectForKey:@"likes"]];
                                            merchantName = [dictResult objectForKey:@"merchantName"];
                                            picture = [dictResult objectForKey:@"picture"];
                                            price = [NSString stringWithFormat:@"%@",[dictResult objectForKey:@"price"]];
                                            if (!price) {
                                                price = @"FREE";
                                            }else if([price isEqualToString:@"0.00"]){
                                                price = @"FREE";
                                            }else{
                                                price = [NSString stringWithFormat:@"$ %@", price];
                                            }
                                            dict = @{@"title": title,
                                                     @"distance": distance,
                                                     @"id": idGift,
                                                     @"likes": likes,
                                                     @"merchantName": merchantName,
                                                     @"image": picture,
                                                     @"price": price};
                                            [arrayAux addObject:dict];
                                        }
                                    }
                                    //NSDictionary *dict;
                                    //NSString *title, *distance, *idGift, *likes, *merchantName, *picture, *price;
                                }
                                
                            //}
                            break;
                        }
                    }
                    
                    /*
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
                    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
                    [dict setObject:[NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude] forKey:@"longitude"];
                    [dict setObject:[NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude] forKey:@"latitude"];
                    if (self.organizationID > 0) {
                        [dict setObject:[NSNumber numberWithInteger:self.organizationID] forKey:@"merchantId"];
                    }
                    NSLog(@"Dict: %@", dict);
                    
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                    NSString *jsonString;
                    if (!jsonData) {
                    } else {
                        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    }
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                    request.HTTPMethod = @"POST";
                    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    request.HTTPBody = jsonData;
                    
                    NSURLResponse *res = nil;
                    NSError *err = nil;
                    
                    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                    
                    NSInteger code = [httpResponse statusCode];
                    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"Code: %ld, Gifts: %@", (long)code, array);
                    //NSLog(@"Contador: %lu", (unsigned long)[array count]);
                    
                    //FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                    //[loginManager logOut];
                    //[FBSDKAccessToken setCurrentAccessToken:nil];
                    // [FBSDKAccessToken setCurrentAccessToken:nil];
                    //[FBSDKProfile setCurrentProfile:nil];
                    
                    if(code == 200){
                        NSDictionary *dict;
                        NSString *title, *distance, *idGift, *likes, *merchantName, *picture, *price;
                        for (NSDictionary *dictionary in array) {
                            title = [dictionary objectForKey:@"giftName"];
                            distance = [dictionary objectForKey:@"distance"];
                            distance = [NSString stringWithFormat:@"%@ kms", distance];
                            idGift = [dictionary objectForKey:@"id"];
                            likes = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"likes"]];
                            merchantName = [dictionary objectForKey:@"merchantName"];
                            picture = [dictionary objectForKey:@"picture"];
                            price = [dictionary objectForKey:@"price"];
                            if (!price) {
                                price = @"FREE";
                            }else if([price isEqualToString:@"0.00"]){
                                price = @"FREE";
                            }else{
                                price = [NSString stringWithFormat:@"$ %@", price];
                            }
                            dict = @{@"title": title,
                                     @"distance": distance,
                                     @"id": idGift,
                                     @"likes": likes,
                                     @"merchantName": merchantName,
                                     @"image": picture,
                                     @"price": price};
                            [arrayAux addObject:dict];
                        }
                        //NSLog(@"Arreglo: %@",arrayAux);
                        //_giftData = arrayAux;
                    }
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
            
            
        }
    //return _giftData;
    return arrayAux;
}



#pragma -mark Login and signup delegates
-(void)controller:(UIViewController *)controller loggedInUser:(User *)user
{
    self.localUser = user;
    
    // This is used to let splash screen code know if it can be presented
    self.loginScreenShowing = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self firstTimeLogInCheck];
    });
}

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.giftData count];
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor altruus_duckEggBlueColor];
    view.backgroundColor = [UIColor altruus_duckEggBlueColor];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(50, 8, 200, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:12];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.center = CGPointMake(SCREEN_WIDTH / 2 - 10, 15);
    
    if (section == 0) {
        myLabel.textColor = [UIColor altruus_darkSkyBlueColor];
    }else{
        myLabel.textColor = [UIColor altruus_bluegreyColor];
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    [headerView addSubview:myLabel];
    
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"FEATURED", nil);
    }else{
        return @"No title";
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //static NSString *cellStandardIdentifier = @"giftsCell";
    static NSString *cellLoadingIdentifier = @"Loading";
    //NSLog(@"row: %ld, count: %lu", (long)indexPath.row, (unsigned long)[self.giftData count]);
    if (indexPath.row < [self.giftData count]-1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftsCell"];
        [tableView registerNib:[UINib nibWithNibName:@"GiftsCustomCell" bundle:nil] forCellReuseIdentifier:@"giftsCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"giftsCell"];
        return cell;
    }else{
        //NSLog(@"Resultados: %ld, Actual: %ld", (long)_totalResultsFound, (long)_actualResult);
        if(_actualResult < _totalResultsFound){
            LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellLoadingIdentifier forIndexPath:indexPath];
            [cell.activityIndicatorView startAnimating];
            //[self fetchMoreData];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftsCell"];
    [tableView registerNib:[UINib nibWithNibName:@"GiftsCustomCell" bundle:nil] forCellReuseIdentifier:@"giftsCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:@"giftsCell"];
    return cell;
    /*
    if (!cell) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftsCell"];
        [tableView registerNib:[UINib nibWithNibName:@"GiftsCustomCell" bundle:nil] forCellReuseIdentifier:@"giftsCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"giftsCell"];
        return cell;
    }else{
        LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellLoadingIdentifier forIndexPath:indexPath];
        [cell.activityIndicatorView startAnimating];
        
        //[self fetchMoreData];
        
        return cell;
    }
     */
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell isKindOfClass:[GiftsTableViewCell class]]) {
        
    
    
        cell.layer.cornerRadius = 10;
        cell.contentView.layer.masksToBounds = YES;
        
        if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
            //Ùltima celda, agregar sombra
            cell.layer.shadowOffset = CGSizeMake(0, 15);
            cell.layer.shadowColor = [[UIColor blackColor] CGColor];
            cell.layer.shadowRadius = 6;
            cell.layer.shadowOpacity = .75f;
            CGRect shadowFrame = cell.layer.bounds;
            CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
            cell.layer.shadowPath = shadowPath;
        }
        
        NSDictionary *gift;
        NSString *title, *distance, *url, *likes, *price;
        
        
        if (indexPath.section == 0) {
            //Featured
            gift = [self.giftData objectAtIndex:indexPath.row];
            if (![gift isKindOfClass:[NSNull class]]) {
                title = gift[@"title"] ? gift[@"title"]:@"No Name Provided";
                distance = gift[@"distance"] ? gift[@"distance"]:@"";
                url = gift[@"image"] ? gift[@"image"]:@"";
                likes = gift[@"likes"] ? gift[@"likes"]:@"";
                price = gift[@"price"] ? gift[@"price"]:@"";
            }
        }
        ((GiftsTableViewCell*)cell).heartLikesLabel.text = likes;
        
        //COMENTADO
        //GiftsType type = [self screenType];
        //NSString *category = nil;
        //if (type == GiftsTypeFree){
        //    category = @"FREE";
        //}
        //else{
        //    category = gift[@"price"];
        //}
        
        //((GiftsTableViewCell*)cell).categroyLabel.text = NSLocalizedString(@"FREE", nil);
        ((GiftsTableViewCell*)cell).categroyLabel.text = price;
        ((GiftsTableViewCell*)cell).titleLabel.text = title;
        ((GiftsTableViewCell*)cell).distanceLabel.text = distance;
        if ([likes isEqualToString:@"0"]) {
            ((GiftsTableViewCell*)cell).heartImageView.image = [UIImage imageNamed:@"gifts-heart-grey"];
        }else{
            ((GiftsTableViewCell*)cell).heartImageView.image = [UIImage imageNamed:@"gifts-heart"];
        }
        
        NSString *cadena = [NSString stringWithFormat:@"%@%@", PREFIJO_PHOTO, url];
        [((GiftsTableViewCell*)cell).merchantImageView sd_setImageWithURL:[NSURL URLWithString:cadena] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        //NSLog(@"Indexpath.row: %ld", (long)indexPath.row);
        //NSLog(@"row: %ld, totalResults: %ld, actualResult: %ld", indexPath.row+1, (long)_totalResultsFound, (long)_actualResult);
        if(indexPath.row+2 < _totalResultsFound && indexPath.row+2 == _actualResult){
            //NSLog(@"Descargaré");
            _currentPage++;
            [self fetchMoreData];
            
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    //NSLog(@"Offset: %f",maximumOffset - currentOffset);
    if (maximumOffset - currentOffset <= 10.0){
        //NSLog(@"Terminé");
        //_currentPage++;
        //[self fetchMoreData];
    }
    /*
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    
    // Change 10.0 to adjust the distance from bottom
    if maximumOffset - currentOffset <= 10.0 {
        self.loadMore()
    }
     */
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardGiftInfo];
    if ([controller isKindOfClass:[GiftInfoViewController class]]) {
        
        NSLog(@"%@",self.categoryMapping[@(self.segmentedControl.selectedSegmentIndex)]);
        
        ((GiftInfoViewController*)controller).giftingAction = GiftingActionSendGift;
        ((GiftInfoViewController*)controller).categoryString = self.categoryMapping[@(self.segmentedControl.selectedSegmentIndex)];
        ((GiftInfoViewController*)controller).gift = [self.giftData objectAtIndex:indexPath.row];
        ((GiftInfoViewController*)controller).localUser = self.localUser;
        ((GiftInfoViewController*)controller).friend = self.friend;
        ((GiftInfoViewController*)controller).vieneDeAmigos = self.vieneDeAmigos;
        if (self.userReceivingGift) {
            ((GiftInfoViewController*)controller).userIDReceivingGift = self.userIDReceivingGift;
            ((GiftInfoViewController*)controller).userReceivingGift = self.userReceivingGift;
            ((GiftInfoViewController*)controller).giftingAction = GiftingActionSendGiftToOneUser;
            
        }
    }
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)getPhoneFriends{
    [DataProvider deleteFriendsRecords];
    NSMutableDictionary *contactList = [NSMutableDictionary new];
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        NSMutableArray *cList = [[NSMutableArray alloc] init];
        
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSString *contactName;
        for (int i=0;i < nPeople;i++) {
            BOOL guarda = NO;
            NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
            
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
            
            //For username and surname
            //
            //Username
            CFStringRef firstName, lastName, fullName;
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            
            if (firstName == nil) {
                firstName = (__bridge CFStringRef)([NSString stringWithFormat:@""]);
            }
            if (lastName == nil) {
                lastName = (__bridge CFStringRef)([NSString stringWithFormat:@""]);
            }
            
            fullName = (__bridge CFStringRef)([NSString stringWithFormat:@"%@ %@", firstName, lastName]);
            //NSLog(@"Fullname : %@", fullName);
            
            [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"first_name"];
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", lastName] forKey:@"last_name"];
            
            contactName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            contactName = [contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            //User Image
            UIImage *contactImage;
            NSData *dataImage = nil;
            if(ABPersonHasImageData(ref)){
                contactImage = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(ref)];
                dataImage = (__bridge NSData *)(ABPersonCopyImageData(ref));
                //[dOfPerson setObject:contactImage forKey:@"photo"];
            }
            
            //Phone number
            NSString* mobileLabel;
            ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
            BOOL hasIphone = NO;
            BOOL hasMobile = NO;
            NSString *iPhoneNumber, *mobileNumber, *cellNumber= @"";
            for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++){
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                //NSLog(@"%@", mobileLabel);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel] || [mobileLabel isEqualToString:@"Móvil"] || [mobileLabel isEqualToString:@"Celular"]){
                    //[dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
                    mobileNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    hasMobile = YES;
                    
                }else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]){
                    //[dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
                    iPhoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    hasIphone = YES;
                    break ;
                }
            }
            if(hasIphone){
                cellNumber = iPhoneNumber;
                cellNumber = [[[[cellNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
                cellNumber = [cellNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                cellNumber = [cellNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                cellNumber = [cellNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
                [dOfPerson setObject:cellNumber forKey:@"phoneNumber"];
                [cList addObject:dOfPerson];
                [contactList setObject:dOfPerson forKey:contactName];
                guarda = YES;
            }else if(hasMobile){
                cellNumber = mobileNumber;
                cellNumber = [[[[cellNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
                
                cellNumber = [cellNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                cellNumber = [cellNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                cellNumber = [cellNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
                [dOfPerson setObject:cellNumber forKey:@"phoneNumber"];
                [cList addObject:dOfPerson];
                [contactList setObject:dOfPerson forKey:contactName];
                guarda = YES;
            }
            
            if (guarda && [contactName length] > 1) {
                Friend *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:managedContext];
                friend.fullName = (__bridge NSString * _Nullable)(fullName);
                friend.firstName = (__bridge NSString * _Nullable)(firstName);
                friend.lastName = (__bridge NSString * _Nullable)(lastName);
                friend.phoneNumber = cellNumber;
                /*
                if (dataImage) {
                    friend.photo = dataImage;
                }*/
                friend.origin = @"T";
                
                //NSLog(@"Fullname: %@, Firstname: %@, Lastname: %@, Phonenumber: %@, Photo: %@, Origin: %@", friend.fullName, friend.firstName, friend.lastName, friend.phoneNumber, friend.photo, friend.origin);
                
                //NSLog(@"%@, %@, %@, %@, %@", friend.fullName, friend.firstName, friend.lastName, friend.phoneNumber, friend.photo, friend.photo);
                
                NSError *error;
                if (![managedContext save:&error]) {
                    NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                }
                 
                
                /*
                if (![DataProvider findFriendByTelephone:cellNumber]) {
                    NSError *error;
                    if (![managedContext save:&error]) {
                        NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                    }
                }else{
                    NSLog(@"************REPETIDO*************** %@", cellNumber);
                }
                 */
            }
        }
    });
    //return contactList;
}

@end
