//
//  Friends2ViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "User+Utils.h"
#import "Friends2ViewController.h"
#import "Friends.h"
#import "RedeemGiftViewController.h"
#import "UISegmentedControl+Utils.h"
#import "constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "OrgTableViewCell.h"
#import "FriendsProfileViewController.h"
#import <MZFormSheetController.h>
#import "Servicios.h"
#import "ChooseCardViewController.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppDelegate.h"
#import "DataProvider.h"
#import "Friend.h"
#import <Branch.h>

@interface Friends2ViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) NSArray *data;
@property (strong, nonatomic) NSNumber *friendCount;

@property (strong,nonatomic) NSMutableArray *numbersSelected;
@property (strong,nonatomic) NSMutableArray *selectedList0;
@property (strong,nonatomic) NSMutableArray *selectedList1;
@property (strong,nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSMutableDictionary *friendList;
@property (strong, nonatomic) NSMutableArray *friendsKeys;

@property (strong,nonatomic) UIImageView *addFriendImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendToFriendsButton;

// Autolayout constants
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendGiftButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendGiftButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeight;



@end

@implementation Friends2ViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    [self setup];
    self.friendCount = @(0);
    
    self.numbersSelected = [@[] mutableCopy];
    //Lista de ids de usuarios
    self.selectedList0 = [@[] mutableCopy];
    self.selectedList1 = [@[] mutableCopy];
    
    self.sendGiftButtonHeightConstraint.constant = 0;
    
    [self listenForNotifs];
    [self fetchData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[self fetchData];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
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

-(void)setup{
    if(self.friendListType == FriendListTypeChooseFriend){
        self.navigationItem.title = NSLocalizedString(@"Choose Friends", nil);
        if (self.showBackButton) {
            FAKIonIcons *backIcon;
            if (self.comingFromNavPush) {
                backIcon = [FAKIonIcons arrowLeftCIconWithSize:30];
            }else{
                backIcon = [FAKIonIcons closeRoundIconWithSize:30];
            }
            [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
            UIImage *backImage = [backIcon imageWithSize:CGSizeMake(30, 30)];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        }
    }else{
        self.navigationItem.title = NSLocalizedString(@"All Friends", nil);
    }
    
    if (self.showBackButton) {
        FAKIonIcons *backIcon;
        if (self.comingFromNavPush) {
            backIcon = [FAKIonIcons arrowLeftCIconWithSize:30];
        }else{
            backIcon = [FAKIonIcons closeRoundIconWithSize:30];
        }
        [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        UIImage *backImage = [backIcon imageWithSize:CGSizeMake(30, 30)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    }
    
    //self.segmentControlHeight.constant = 0;
    
    [self.segmentedControl addTarget:self action:@selector(tappedHeaderSegment:) forControlEvents:UIControlEventValueChanged];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"ALTRÜUS USERS", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"PHONE CONTACTS", nil) forSegmentAtIndex:1];
    
    self.segmentedControl.selectedSegmentIndex = 1;
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    
    
   
    self.tableview.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableview.layer.cornerRadius = 5;
}

-(void)fetchData{
    [DataProvider deleteFriendsRecords];
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableview animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Getting Friends", nil);
    
  
    [DataProvider deleteFriendsRecords];
    [self getAltruusFriends];
    [self getPhoneFriends];
}

-(NSArray*)getFriendsFromAltruus:(NSString*)substring{
    NSMutableArray *friends = [NSMutableArray new];
    @try {
        if ([DataProvider networkConnected]) {
            if ([substring length] >= 1) {
                AppDelegate *delegate = [AppDelegate sharedAppDelegate];
                NSManagedObjectContext *context = delegate.managedObjectContext;
                self.localUser = [User getLocalUserSesion:context];
                
                substring = [substring stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                
                NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&name=%@", SEARCH_USER_BY_NAME_V3, self.localUser.session, substring];
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
                        NSArray *array = [dictionary objectForKey:@"results"];
                        NSLog(@"Array: %@",array);
                        for (NSDictionary *dict in array) {
                            Friends *f = [Friends altruusFriendFromData:dict];
                            if (f) {
                                [friends addObject:f];
                            }
                        }
                    }
                }
                
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
    
    return friends;
}

-(NSArray*)getFriendsFromTelephone:(NSString*)substring{
    NSMutableArray *friends = [NSMutableArray new];
    
    NSArray *arrayAux = [DataProvider getFriendsRecords:@"T" andPredicate:substring];
    
    for (Friend *friend in arrayAux) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:friend.fullName forKey:@"fullName"];
        [dict setObject:friend.firstName forKey:@"first_name"];
        [dict setObject:friend.lastName forKey:@"last_name"];
        [dict setObject:friend.phoneNumber forKey:@"phoneNumber"];
        [dict setObject:friend.photo forKey:@"photo"];
       
        
        Friends *f = [Friends friendFromData:dict];
        if (f) {
            [friends addObject:f];
        }
    }
    
    return friends;
}

-(void)getAltruusFriends{
    
}

//-(NSMutableDictionary*)getPhoneFriends{
-(void)getPhoneFriends{
    NSMutableDictionary *contactList = [NSMutableDictionary new];
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    __block NSMutableString *cadenaTelefonos = [NSMutableString new];
    
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
            NSString *iPhoneNumber, *mobileNumber, *celNumber= @"";
            for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++){
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                //NSLog(@"%@", mobileLabel);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel] || [mobileLabel isEqualToString:@"Móvil"] || [mobileLabel isEqualToString:@"Celular"]){
                    mobileNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    hasMobile = YES;
                    
                }else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]){
                    iPhoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    hasIphone = YES;
                    break ;
                }
            }
            if(hasIphone){
                celNumber = iPhoneNumber;
                celNumber = [[[[celNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
                celNumber = [celNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                celNumber = [celNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                celNumber = [celNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
                [dOfPerson setObject:celNumber forKey:@"phoneNumber"];
                [cList addObject:dOfPerson];
                [contactList setObject:dOfPerson forKey:contactName];
                guarda = YES;
            }else if(hasMobile){
                celNumber = mobileNumber;
                celNumber = [[[[celNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
                celNumber = [celNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                celNumber = [celNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                celNumber = [celNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
                [dOfPerson setObject:celNumber forKey:@"phoneNumber"];
                [cList addObject:dOfPerson];
                [contactList setObject:dOfPerson forKey:contactName];
                guarda = YES;
            }
            
            if (guarda && [contactName length] > 1) {
                NSArray* words = [celNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *phoneAux = [words componentsJoinedByString:@""];
                
                if ([phoneAux length] > 10) {
                    @try {
                        phoneAux = [phoneAux substringFromIndex:[phoneAux length]-10];
                    } @catch (NSException *exception) {
                        NSLog(@"Error Al Recortar Teléfono: %@", exception);
                    }
                }
                
                if (![DataProvider findFriendByTelephone:phoneAux]) {
                    
                    NSArray* words = [celNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    celNumber = [words componentsJoinedByString:@""];
                    
                    Friend *friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:managedContext];
                    friend.fullName = (__bridge NSString * _Nullable)(fullName);
                    friend.firstName = (__bridge NSString * _Nullable)(firstName);
                    friend.lastName = (__bridge NSString * _Nullable)(lastName);
                    friend.origin = @"T";
                    friend.phoneNumber = celNumber;
                    
                
                    cadenaTelefonos = [NSMutableString stringWithFormat:@"%@%@,", cadenaTelefonos, celNumber];
                    
                    //friend.photo = [self devuelveDatosUsuarioAltruus:celNumber]; //comente 080717
                    friend.photo = @"";
                    friend.phoneWithoutLada = phoneAux;
                    
                    NSError *error;
                    if (![managedContext save:&error]) {
                        NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                    }
                }else{
                    NSLog(@"No grabo");
                    NSLog(@"Nombre: %@, Teléfono: %@", fullName, celNumber);
                    NSLog(@"-------------------------------------------");
                }
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self actualizaContactosAltruus:cadenaTelefonos];
            self.data = [self getFriendsFromTelephone:nil];
            self.friendCount = [NSNumber numberWithInteger:self.data.count];
            [self.tableview reloadData];
            [self.hud hide:YES];
        });
        
    });
    //return contactList;
    
}


-(void)actualizaContactosAltruus:(NSMutableString*)phones{
    @try {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        self.localUser = [User getLocalUserSesion:context];
        
        NSArray* words = [phones componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        //NSLog(@"Phones: %@", nospacestring);
        
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&phones=%@", VERIFY_CONTACT_PHONES_V3, self.localUser.session, nospacestring ];
        NSURL *url = [NSURL URLWithString:urlString];
        NSLog(@"URL: %@", url);
        //NSLog(@"URL: %@", urlString);
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
                NSArray *array = [dictionary objectForKey:@"users"];
                NSInteger isUser = 0;
                NSString *facebookId = @"";
                for (NSDictionary *dict in array) {
                    isUser = [[dict objectForKey:@"isUser"] integerValue];
                    if ( isUser == 0 ) {
                        //NSLog(@"No es usuario");
                        //break;
                    }else{
                        //NSLog(@"Es usuariooooooooooooooooo;");
                        facebookId = [dict objectForKey:@"facebookId"];
                        facebookId = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",facebookId];
                        NSLog(@"Usuario: %@", dict);
                        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
                        NSManagedObjectContext *managedContext = delegate.managedObjectContext;
                        
                        NSString *predicateFormat = [[NSPredicate predicateWithFormat:@"origin = %@", @"T"] predicateFormat];
                        predicateFormat = [predicateFormat stringByAppendingFormat:@" AND phoneNumber = %@ ", [dict objectForKey:@"phone"]];
                        
                        NSFetchRequest *request = [[NSFetchRequest alloc] init];
                        request.entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedContext];
                        request.predicate = [NSPredicate predicateWithFormat:predicateFormat];
                        
                        NSArray *records = [managedContext executeFetchRequest:request error:NULL];
                        
                        if ([records count] > 0) {
                            Friend *friend = [records objectAtIndex:0];
                            friend.photo = facebookId;
                            NSError *error;
                            if (![managedContext save:&error]) {
                                NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                            }
                        }
                    }
                    //NSLog(@"Paso");
                }
            }
        }
                
       
    } @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
}

-(NSString*)devuelveDatosUsuarioAltruus:(NSString*)phoneNumber{
   
    
    NSArray* words = [phoneNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneAux = [words componentsJoinedByString:@""];
    
    if ([phoneAux length] > 10) {
    
        @try {
            phoneAux = [phoneAux substringFromIndex:[phoneAux length]-10];
            //NSLog(@"Quedó PhoneAux: %@, Longitud: %lu", phoneAux, (unsigned long)phoneAux.length);
        } @catch (NSException *exception) {
            NSLog(@"Error Al Recortar Teléfono: %@", exception);
        } @finally {
            
        }
    }
    
    @try {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        self.localUser = [User getLocalUserSesion:context];
        
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&phone=%@", FIND_ALTRUUS_USER_V3, self.localUser.session, phoneAux ];
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
                dictionary = [dictionary objectForKey:@"entity"];
                NSLog(@"Encontré %@ %@, %@", [dictionary objectForKey:@"firstName"], [dictionary objectForKey:@"lastName"], [dictionary objectForKey:@"facebookId"]);
                NSLog(@"%@",[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",[dictionary objectForKey:@"facebookId"]]);
                
                return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",[dictionary objectForKey:@"facebookId"]];
                
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
    
    return @"";
}
    
    
-(NSString*)devuelveDatosUsuarioAltruus2:(NSString*)phoneNumber{
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
        
       
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&phone=%@", FIND_ALTRUUS_USER_V3, self.localUser.session, phoneAux ];
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
                dictionary = [dictionary objectForKey:@"entity"];
                return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",[dictionary objectForKey:@"facebookId"]];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
    
    return @"";
}
    
    


-(void)goBack{
    if (self.comingFromNavPush) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)tappedHeaderSegment:(UISegmentedControl*)sender{
    self.searchBar.text = @"";
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.data = [self getFriendsFromAltruus:nil];
        //self.friendCount = [NSNumber numberWithInteger:self.data.count];
        self.friendCount = [NSNumber numberWithInteger:[self returnAltruusFriends]];
        [self.tableview reloadData];
    }else{
        self.data = [self getFriendsFromTelephone:nil];
        self.friendCount = [NSNumber numberWithInteger:self.data.count];
        [self.tableview reloadData];
        
    }
    [self.searchBar resignFirstResponder];
    
    //Lista de ids de usuarios
    self.selectedList0 = [@[] mutableCopy];
    self.selectedList1 = [@[] mutableCopy];
    [self contractSendGiftButton];
}

-(void)tappedSearch{
    DLog(@"show search");
}

-(IBAction)tappedSendGiftsToFriends:(UIButton*)sender{
    NSLog(@"CategoryString: %@", self.categoryString);
    //Recuperar los ids de los usuarios
    if ([self.categoryString isEqualToString:@"Paid"]) {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"chooseCard"];
        ((ChooseCardViewController*)controller).gift = self.gift;
        ((ChooseCardViewController*)controller).localUser = self.localUser;
        ((ChooseCardViewController*)controller).selectedFriends = self.selectedList0;
        ((ChooseCardViewController*)controller).giftingAction = self.giftingAction;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        if (self.friendListType == FriendListTypeChooseFriend) {
            @try {
                if ([DataProvider networkConnected]) {
                    BOOL error = NO;
                    BOOL altruusUser = YES;
                    for (Friends *fr in self.selectedList0) {
                        NSLog(@"Phone Number: %@, Token: %@, userID: %@, giftID: %@", fr.phoneNumber, self.localUser.tokenAltruus, self.localUser.userIDAltruus, [self.gift objectForKey:@"id"] );
                        
                        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&giftId=%@&phone=%@", SEND_FREE_GIFT_V3, self.localUser.session, [self.gift objectForKey:@"id"],fr.phoneNumber];
                        NSURL *url = [NSURL URLWithString:urlString];
                        NSLog(@"URL: %@", url);
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
                            NSInteger code = [[dictionary objectForKey:@"code"] integerValue];
                            if (code != 200) {
                                error = YES;
                            }
                            
                            if (![self esUsuarioAltruus:fr.phoneNumber]) {
                                altruusUser = NO;
                            }
                        }
                        
                        
                        
                    }//Fin for
                    
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:@"ERROR"
                                              message:@"Can't Send Gift"
                                              delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
                        [alert show];
                    }else{
                        if(altruusUser){
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
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not an Altrüus user!"
                                                                           message:@"Your friend doesn't have Altrüus yet. Let them know so they can redeem their thoughtful gift!"
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Cancel"
                                                                 otherButtonTitles:@"OK", nil];
                            
                            alert.tag=101;//add tag to alert
                            [alert show];
                        }
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
            
        
        }
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            //NSString *inviteText = [NSString stringWithFormat:@"I just sent you a gift! Download Altrüus from the following link to redeem:"];
            NSString *inviteText = NSLocalizedString(@"I just sent you a gift! Download Altrüus from the following link to redeem:", nil);
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
            [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
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
            }];
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
    }
}

-(BOOL)esUsuarioAltruus:(NSString*)phoneNumber{
    NSArray* words = [phoneNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneAux = [words componentsJoinedByString:@""];
    phoneAux = [phoneAux stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
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
        
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&phone=%@", FIND_ALTRUUS_USER_V3, self.localUser.session, phoneAux ];
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
                return YES;
            }else{
                return NO;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
    
    
}

-(NSInteger)returnAltruusFriends{
    @try {
        if ([DataProvider networkConnected]) {
            AppDelegate *delegate = [AppDelegate sharedAppDelegate];
            NSManagedObjectContext *context = delegate.managedObjectContext;
            self.localUser = [User getLocalUserSesion:context];
            
            NSString *urlString = [NSString stringWithFormat:@"%@?session=%@", RETRIEVE_TOTAL_USERS_V3, self.localUser.session ];
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
                    return [[dictionary objectForKey:@"count"] integerValue];
                }
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
    
    return 0;
}

-(void)expandSendGiftButton{
    if (self.sendGiftButtonHeightConstraint.constant == 0) {
        [self.view layoutIfNeeded];
        if (self.tabBarController) {
            self.sendGiftButtonBottomConstraint.constant = 30;
        }
        self.sendGiftButtonHeightConstraint.constant = 40;
        [UIView animateWithDuration:1
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

-(void)contractSendGiftButton{
    if (self.sendGiftButtonHeightConstraint.constant == 40) {
        [self.view layoutIfNeeded];
        self.sendGiftButtonHeightConstraint.constant = 0;
        self.sendGiftButtonBottomConstraint.constant = 0;
        [UIView animateWithDuration:1
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

-(NSNumber*)totalSelectedFriendsCount{
    NSUInteger count1 = [self.selectedList0 count];
    NSUInteger count2 = [self.selectedList1 count];
    
    return @(count1 + count2);
}

-(NSArray*)data{
    if (!_data) {
        _data = @[];
    }
    return _data;
}

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.data count];
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
        NSString *string = [NSString stringWithFormat:@"Total: %@", self.friendCount];
        return NSLocalizedString(string, nil);
    }else{
        return @"No Title";
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orgCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OrgCustomCell" bundle:nil] forCellReuseIdentifier:@"orgCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"orgCell"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.masksToBounds= YES;
    
    if(indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1){
        //ùltima celda, agregar sombra
        cell.layer.shadowOffset = CGSizeMake(0, 15);
        cell.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.layer.shadowRadius = 6;
        cell.layer.shadowOpacity = .75f;
        CGRect shadowFrame = cell.layer.bounds;
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        cell.layer.shadowPath = shadowPath;
    }
    Friends *friend = [self.data objectAtIndex:indexPath.row];
    NSString *name, *bday, *photo;
    NSURL *url;
    
    if (indexPath.section == 0) {
        if (![friend isKindOfClass:[NSNull class]]) {
            name = friend.fullName;
            bday = @"00/00/0000";
            url = friend.imageUrl;
            photo = friend.photo;
            //NSLog(@"Photo: %@", photo);
            
        }
    }
    
    if (self.friendListType == FriendListTypeChooseFriend) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusAddFriendButton]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.frame = CGRectMake(0, 0, 40, 40);
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([self.numbersSelected containsObject:friend.phoneNumber]) {
            cell.accessoryView = nil;
        }else{
            cell.accessoryView = imgView;
        }
        
    }else{
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    }
    
    ((OrgTableViewCell*)cell).screenType = ScreenTypeFriends;
    ((OrgTableViewCell*)cell).nameLabel.text = name;
    ((OrgTableViewCell*)cell).distanceLabel.text = bday;
    ((OrgTableViewCell*)cell).distanceTitleLabel.hidden = YES;
    ((OrgTableViewCell*)cell).distanceLabel.hidden = YES;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        //Facebook
        //NSLog(@"URL: %@", url);
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        ((OrgTableViewCell*)cell).orgImageView.image = [UIImage imageWithData:imageData];
        ((OrgTableViewCell*)cell).orgImageView.hidden = NO;
        self.estaFacebook = YES;
    }else{
        //Telephone
        if (photo.length > 0) {
            //NSLog(@"Photo: %@", photo);
            ((OrgTableViewCell*)cell).altruusName.hidden = NO;
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo]];
            ((OrgTableViewCell*)cell).orgImageView.image = [UIImage imageWithData:imageData];
            ((OrgTableViewCell*)cell).orgImageView.hidden = NO;
        }else{
            ((OrgTableViewCell*)cell).altruusName.hidden = YES;
            ((OrgTableViewCell*)cell).orgImageView.hidden = YES;
            //[((OrgTableViewCell*)cell).orgImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Logo_New"]];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self.searchBar resignFirstResponder];
    
    Friends *friend = [self.data objectAtIndex:indexPath.row];
    
    if (self.friendListType == FriendListTypeChooseFriend) {
        /*
        //primero agregamos celda (user_id) a lista seleccionada
        if ([self.selectedList0 containsObject:friend]){
            [self.selectedList0 removeObject:friend];
            cell.accessoryView = self.addFriendImageView;
        }
        else{
            [self.selectedList0 addObject:friend];
            cell.accessoryView = nil;
        }*/
        if ([self.numbersSelected containsObject:friend.phoneNumber]) {
            for (Friends *fAux in self.selectedList0) {
                if ([fAux.phoneNumber isEqualToString:friend.phoneNumber]) {
                    [self.selectedList0 removeObject:fAux];
                    break;
                }
            }
            
            [self.numbersSelected removeObject:friend.phoneNumber];
            cell.accessoryView = self.addFriendImageView;
            
            
        }else{
            [self.selectedList0 addObject:friend];
            [self.numbersSelected addObject:friend.phoneNumber];
            cell.accessoryView = nil;
            
            
        }
        
        //COMENTÉ 300717
        /*
        if (indexPath.section == 0){
            // first three
            //NSNumber *row = @(indexPath.row);
            if ([self.selectedList0 containsObject:friend]){
                [self.selectedList0 removeObject:friend];
                cell.accessoryView = self.addFriendImageView;
            }
            else{
                [self.selectedList0 addObject:friend];
                cell.accessoryView = nil;
                
            }
            
            DLog(@"%@",self.selectedList0);
        }else if (indexPath.section == 1){
            // the rest
            if ([self.selectedList1 containsObject:friend]){
                [self.selectedList1 removeObject:friend];
                cell.accessoryView = self.addFriendImageView;
            }
            else{
                [self.selectedList1 addObject:friend];
                cell.accessoryView = nil;
            }
            DLog(@"%@",self.selectedList1);
        }
         */
        //En cada tap decidimos si el botòn de enviar serìa visible
        if([[self totalSelectedFriendsCount] isEqual:@(0)]){
            //Esconde botón
            [self contractSendGiftButton];
        }else{
            //Muestra botón
            [self.sendToFriendsButton setTitle:[NSString stringWithFormat:@"Send gift to %@ friends", [self totalSelectedFriendsCount]] forState:UIControlStateNormal];
            [self expandSendGiftButton];
        }
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kV2StoryboardFriendProfile];
        if ([vc isKindOfClass:[FriendsProfileViewController class]]) {
            ((FriendsProfileViewController*)vc).showBackButton = YES;
            ((FriendsProfileViewController*)vc).dontShowMenu = YES;
            ((FriendsProfileViewController*)vc).vieneDeAmigos = YES;
            ((FriendsProfileViewController*)vc).friend = friend;
            if (self.segmentedControl.selectedSegmentIndex == 0) {
                ((FriendsProfileViewController*)vc).estaFacebook = YES;
                ((FriendsProfileViewController*)vc).urlPhoto = friend.imageUrl;
                
            }else{
                ((FriendsProfileViewController*)vc).estaFacebook = NO;
            }
        }
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

-(UIImageView*)addFriendImageView{
    _addFriendImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusAddFriendButton]];
    _addFriendImageView.contentMode = UIViewContentModeScaleAspectFit;
    _addFriendImageView.frame = CGRectMake(0, 0, 40, 40);
    
    return _addFriendImageView;
}

#pragma -mark Search bar delegate methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.text = @"";
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.data = [self getFriendsFromAltruus:nil];
        //self.friendCount = [NSNumber numberWithInteger:self.data.count];
        [self.tableview reloadData];
    }else{
        self.data = [self getFriendsFromTelephone:nil];
        self.friendCount = [NSNumber numberWithInteger:self.data.count];
        [self.tableview reloadData];
        
    }
    [searchBar resignFirstResponder];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.data = [self getFriendsFromAltruus:searchText];
        //self.friendCount = [NSNumber numberWithInteger:self.data.count];
        [self.tableview reloadData];
    }else{
        self.data = [self getFriendsFromTelephone:searchText];
        self.friendCount = [NSNumber numberWithInteger:self.data.count];
        [self.tableview reloadData];
    }
 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

@end
