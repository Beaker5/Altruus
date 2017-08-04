//
//  UpdatesViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 9/2/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "UpdatesViewController.h"
#import "constants.h"
#import "RoundedImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UpdatesTableViewCell.h"
#import "GiftInfoViewController.h"
#import "FriendsProfileViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "Servicios.h"
#import "AppDelegate.h"
#import "User+Utils.h"
#import <MBProgressHUD.h>
#import "GiftReceivedViewController.h"
#import "GiftsReceivedViewController.h"
#import "DataProvider.h"
#import "UpdatesGifts.h"
#import "GiftsReceived.h"

@interface UpdatesViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (assign)UpdateType updateType;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) User *localUser;

//@property (strong,nonatomic)NSArray *todayData;
//@property (strong,nonatomic)NSArray *previousData;

@property (strong,nonatomic) NSArray *data;
@property (strong,nonatomic) NSArray *dataUpdates;
@property (strong,nonatomic) NSArray *dataGiftsToUser;

@property (assign, nonatomic) BOOL esRegaloRecibido;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeight;

@end

@implementation UpdatesViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setup];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"Aparece Updates");
    [self tappedHeaderSegment:self.segmentedControl];
    @try {
        if ([DataProvider networkConnected]) {
            [self actualizaNumeroRegalosRecibidos];
            //[self grabaNotificacionesRegalosRecibidos];
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

-(void)actualizaNumeroRegalosRecibidos{
    UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *strAux;
    if ([self numeroRegalosUnredeemed] > 0) {
        strAux = [NSString stringWithFormat:@"You have new gifts"];
    }else{
        strAux = [NSString stringWithFormat:@"You don't have new gifts"];
    }
    ((UpdatesTableViewCell*)cell).mainLabel.text = NSLocalizedString(strAux, nil);
    
    NSString *str;
    if ([self numeroRegalosUnredeemed] > 0) {
        str = [NSString stringWithFormat:@"%lu items", (unsigned long)[DataProvider numberOfGiftsUnredeemed]];
    }else{
        str = [NSString stringWithFormat:@"0 items"];
    }
    ((UpdatesTableViewCell*)cell).subLabel.text = NSLocalizedString(str, nil);
}

/*
-(void)actualizaNumeroRegalosRecibidos{
    @try {
        if ([DataProvider networkConnected]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
            [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            NSString *jsonString;
            if (!jsonData) {
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:RETRIEVE_USER_GIFTS]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = jsonData;
            
            NSURLResponse *res = nil;
            NSError *err = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
            
            NSInteger code = [httpResponse statusCode];
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (code == 200) {
                UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                NSString *strAux;
                if ([array count] > 0) {
                    strAux = [NSString stringWithFormat:@"You have new gifts"];
                }else{
                    strAux = [NSString stringWithFormat:@"You don't have new gifts"];
                }
                ((UpdatesTableViewCell*)cell).mainLabel.text = NSLocalizedString(strAux, nil);
                
                NSString *str;
                if ([array count] > 0) {
                    str = [NSString stringWithFormat:@"%lu items", (unsigned long)[array count]];
                }else{
                    str = [NSString stringWithFormat:@"0 items"];
                }
                ((UpdatesTableViewCell*)cell).subLabel.text = NSLocalizedString(str, nil);
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
*/
-(void)setup{
    //self.segmentControlHeight.constant = 0;
    self.dataUpdates = [NSArray new];
    self.dataGiftsToUser = [NSArray new];
    
    self.segmentedControl.selectedSegmentIndex = 1;
    self.updateType = UpdateTypeYou;
    
    [self.segmentedControl addTarget:self action:@selector(tappedHeaderSegment:) forControlEvents:UIControlEventValueChanged];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"FRIENDS", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"YOU", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTitle:NSLocalizedString(@"BUSINESSES", nil) forSegmentAtIndex:2];
    
    if (self.screenType == ScreenTypeUpdates) {
        self.navigationItem.title = NSLocalizedString(@"Updates", nil);
    }else if(self.screenType == ScreenTypeGiftsSent){
        self.navigationItem.title = NSLocalizedString(@"Sent Gifts", nil);
    }else if(self.screenType == ScreenTypeGiftsReceived){
        self.navigationItem.title = NSLocalizedString(@"Received Gifts", nil);
    }
    
    if (self.showBackButton) {
        FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:30];
        [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorGreen]];
        UIImage *backImage = [backIcon imageWithSize:CGSizeMake(30, 30)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    }
    
    self.tableview.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableview.layer.cornerRadius = 5;
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    //self.localUser = [User getLocalUserInContext:context];
    self.localUser = [User getLocalUserSesion:context];
    
    @try {
        if ([DataProvider networkConnected]) {
            [self grabaNotificacionesCoreData];
            //[self grabaNotificacionesRegalosRecibidos];
            //[self notificacionesRegalosRecibidos];
            [self notificacionesRegalosEnviados];
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


-(NSInteger)numeroRegalosUnredeemed{
    NSInteger contador = 0;
    //NSLog(@"Se ejecuta el grabado");
    if ([DataProvider networkConnected]) {
        //AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        //NSManagedObjectContext *managedContext = delegate.managedObjectContext;
        //[DataProvider deleteGiftsReceived];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
        [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *jsonString;
        if (!jsonData) {
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:RETRIEVE_USER_GIFTS]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = jsonData;
        
        NSURLResponse *res = nil;
        NSError *err = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
        
        NSInteger code = [httpResponse statusCode];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (code == 200) {
            for (NSDictionary *dictionary in array) {
                //NSLog(@"%@",[dictionary objectForKey:@"status"]);
                if ([[dictionary objectForKey:@"status"] isEqualToString:@"UNREDEEMED"]) {
                    contador++;
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
    return contador;
}

-(void)grabaNotificacionesRegalosRecibidos{
    //NSLog(@"Se ejecuta el grabado");
    if ([DataProvider networkConnected]) {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *managedContext = delegate.managedObjectContext;
        
        [DataProvider deleteGiftsReceived];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
        [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *jsonString;
        if (!jsonData) {
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:RETRIEVE_USER_GIFTS]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = jsonData;
        
        NSURLResponse *res = nil;
        NSError *err = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
        
        NSInteger code = [httpResponse statusCode];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //NSLog(@"-----------------------------------------------------------------------------------");
        //NSLog(@"Codigo: %ld, Diccionario Usuario: %@, Contador: %lu", (long)code, array, (unsigned long)[array count]);
        //NSLog(@"-----------------------------------------------------------------------------------");
        if (code == 200) {
            for (NSDictionary *dictionary in array) {
                GiftsReceived * gift = [NSEntityDescription insertNewObjectForEntityForName:@"GiftsReceived" inManagedObjectContext:managedContext];
                gift.date =  [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"datetime"]];
                gift.giftCode = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"giftCode"]];
                gift.giftName = [dictionary objectForKey:@"giftName"];
                gift.idGift = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"id"]];
                gift.image = [dictionary objectForKey:@"picture"];
                gift.merchantName = [dictionary objectForKey:@"merchantName"];
                gift.senderName = [dictionary objectForKey:@"senderName"];
                gift.senderPicture = [dictionary objectForKey:@"senderPicture"];
                gift.status = [dictionary objectForKey:@"status"];
                
                NSError *error;
                if (![managedContext save:&error]) {
                    NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
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
}

-(void)notificacionesRegalosRecibidos{
    self.dataGiftsToUser = [NSArray new];
    
    NSArray *array = [DataProvider getGiftsReceived];
    NSMutableArray *arrayAux = [NSMutableArray new];
    NSDictionary *dict;
    NSString *datetime;
    for (GiftsReceived *gift in array) {
        datetime = gift.date;
        double getDate = [datetime doubleValue];
        NSTimeInterval seconds = getDate / 1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
        NSString *dateString = [dateFormat stringFromDate:date];
        
        dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", gift.senderName, gift.giftName, gift.merchantName],
                 @"date":dateString,
                 @"giftName":gift.giftName,
                 @"merchantName":gift.merchantName,
                 @"giftCode":gift.giftCode,
                 @"id":gift.idGift,
                 @"senderPicture":gift.senderPicture,
                 @"status":gift.status,
                 @"image":gift.image};
        [arrayAux addObject:dict];
    }
    self.dataGiftsToUser = arrayAux;
    /*
    self.dataGiftsToUser = [NSArray new];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString;
    if (!jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:RETRIEVE_USER_GIFTS]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    
    NSInteger code = [httpResponse statusCode];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //NSLog(@"-----------------------------------------------------------------------------------");
    //NSLog(@"Codigo: %ld, Diccionario Usuario: %@, Contador: %lu", (long)code, array, (unsigned long)[array count]);
    //NSLog(@"-----------------------------------------------------------------------------------");
    if (code == 200) {
        NSMutableArray *arrayAux = [NSMutableArray new];
        NSDictionary *dict;
        NSString *datetime;
        for (NSDictionary *dictionary in array) {
            datetime = [dictionary objectForKey:@"datetime"];
            double getDate = [datetime doubleValue];
            NSTimeInterval seconds = getDate / 1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
            NSString *dateString = [dateFormat stringFromDate:date];
            
            //NSLog(@"Image: %@", [dictionary objectForKey:@"picture"] );
            dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", [dictionary objectForKey:@"senderName"], [dictionary objectForKey:@"giftName"], [dictionary objectForKey:@"merchantName"]],
                     @"date":dateString,
                     @"giftName":[dictionary objectForKey:@"giftName"],
                     @"merchantName":[dictionary objectForKey:@"merchantName"],
                     @"giftCode":[dictionary objectForKey:@"giftCode"],
                     @"id":[dictionary objectForKey:@"id"],
                     @"senderPicture":[dictionary objectForKey:@"senderPicture"],
                     @"status":[dictionary objectForKey:@"status"],
                     @"image":[dictionary objectForKey:@"picture"]};
            [arrayAux addObject:dict];
            
        }
        self.dataGiftsToUser = arrayAux;
        //NSLog(@"GiftsToUser: %@", self.dataGiftsToUser);
    }
     */
}

-(void)grabaNotificacionesCoreData{
    if ([DataProvider networkConnected]) {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *managedContext = delegate.managedObjectContext;
        
        [DataProvider deleteUpdates];
        
        NSString *url = @"";
        switch (self.updateType) {
            case UpdateTypeFriends:
                url = UPDATES_FRIENDS;
                break;
            case UpdateTypeYou:
                url = UPDATES_USER;
                break;
            case UpdateTypeCompany:
                url = UPDATES_COMPANY;
                break;
            default:
                break;
        }
        
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
        [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
        
        
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
        //NSLog(@"-----------------------------------------------------------------------------------");
        //NSLog(@"Codigo: %ld, Diccionario Updates: %@, %@", (long)code, array, httpResponse);
        //NSLog(@"-----------------------------------------------------------------------------------");
        if (code == 200) {
            NSString *giftName, *merchantName, *userFrom, *userTo, *picture, *pictureType, *datetime;
            for (NSDictionary *dictionary in array) {
                giftName = [dictionary objectForKey:@"giftName"];
                merchantName = [dictionary objectForKey:@"merchantName"];
                userFrom = [dictionary objectForKey:@"userFrom"];
                userTo = [dictionary objectForKey:@"userTo"];
                picture = [dictionary objectForKey:@"picture"];
                pictureType = [dictionary objectForKey:@"pictureType"];
                datetime = [dictionary objectForKey:@"datetime"];
                switch (self.updateType) {
                    case UpdateTypeFriends:
                        break;
                    case UpdateTypeYou:{
                        UpdatesGifts *update = [NSEntityDescription insertNewObjectForEntityForName:@"UpdatesGifts" inManagedObjectContext:managedContext];
                        update.giftName = giftName;
                        update.merchantName = merchantName;
                        update.userFrom = userFrom;
                        update.userTo = userTo;
                        update.picture = picture;
                        update.pictureType = pictureType;
                        update.datetime = [NSString stringWithFormat:@"%@", datetime];
                        
                        NSError *error;
                        if (![managedContext save:&error]) {
                            NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                        }
                    }
                        break;
                    case UpdateTypeCompany:
                        break;
                    default:
                        break;
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
    
}

-(void)notificacionesRegalosEnviados{
    self.dataUpdates = [NSArray new];
    
    NSArray *array = [NSMutableArray new];
    switch (self.updateType) {
        case UpdateTypeFriends:
            
            break;
        case UpdateTypeYou:
            array = [DataProvider getUpdatesGifts];
            break;
        case UpdateTypeCompany:
            
            break;
        default:
            break;
    }
    
    NSMutableArray *arrayAux = [NSMutableArray new];
    NSDictionary *dict;
    NSString *giftName, *merchantName, *userFrom, *userTo, *picture, *pictureType, *datetime;
    for (UpdatesGifts *update in array) {
        giftName = update.giftName;
        merchantName = update.merchantName;
        userFrom = update.userFrom;
        userTo = update.userTo;
        picture = update.picture;
        pictureType = update.pictureType;
        datetime = update.datetime;
        
        switch (self.updateType) {
            case UpdateTypeFriends:
                dict = [NSDictionary new];
                break;
            case UpdateTypeYou:{
                
                if ([userTo isEqualToString:@"you"]) {
                    //Regalos recibidos
                    double getDate = [datetime doubleValue];
                    NSTimeInterval seconds = getDate / 1000;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
                    NSString *dateString = [dateFormat stringFromDate:date];
                    //NSLog(@"date: %@", dateString);
                    
                    
                    dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", userFrom, giftName, merchantName],
                             @"date":dateString,
                             @"type":pictureType,
                             @"image":picture};
                    [arrayAux addObject:dict];
                }else if ([userFrom isEqualToString:@"you"]) {
                    //Regalos enviados
                    double getDate = [datetime doubleValue];
                    NSTimeInterval seconds = getDate / 1000;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
                    NSString *dateString = [dateFormat stringFromDate:date];
                    //NSLog(@"date: %@", dateString);
                    
                    dict = @{@"title": [NSString stringWithFormat:@"You sent %@ to %@ from %@", giftName, userTo, merchantName],
                             @"date": dateString,
                             @"type":pictureType,
                             @"image":picture};
                    [arrayAux addObject:dict];
                }
            }
                break;
            case UpdateTypeCompany:
                dict = [NSDictionary new];
                break;
            default:
                break;
        }
    }
    self.dataUpdates = arrayAux;
}

/*
-(void)notificacionesRegalosEnviados{
    self.dataUpdates = [NSArray new];
    
    NSString *url = @"";
    switch (self.updateType) {
        case UpdateTypeFriends:
            url = UPDATES_FRIENDS;
            break;
        case UpdateTypeYou:
            url = UPDATES_USER;
            break;
        case UpdateTypeCompany:
            url = UPDATES_COMPANY;
            break;
        default:
            break;
    }
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    //[dict setObject:@"12hnnatlu3v3e3jbtm0unjdso9" forKey:@"token"];
    //[dict setObject:@"345" forKey:@"userId"];
    //ELIMINAR
    //[dict setObject:@"3r0lgu9g49jm4ivv14cd0jnreh" forKey:@"token"];
    //[dict setObject:@"1" forKey:@"userId"];
    
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
    //NSLog(@"-----------------------------------------------------------------------------------");
    NSLog(@"Codigo: %ld, Diccionario Updates: %@, %@", (long)code, array, httpResponse);
    //NSLog(@"-----------------------------------------------------------------------------------");
    if (code == 200) {
        NSMutableArray *arrayAux = [NSMutableArray new];
        NSDictionary *dict;
        NSString *giftName, *merchantName, *userFrom, *userTo, *picture, *pictureType, *datetime;
        for (NSDictionary *dictionary in array) {
            giftName = [dictionary objectForKey:@"giftName"];
            merchantName = [dictionary objectForKey:@"merchantName"];
            userFrom = [dictionary objectForKey:@"userFrom"];
            userTo = [dictionary objectForKey:@"userTo"];
            picture = [dictionary objectForKey:@"picture"];
            pictureType = [dictionary objectForKey:@"pictureType"];
            datetime = [dictionary objectForKey:@"datetime"];
            switch (self.updateType) {
                case UpdateTypeFriends:
                    dict = [NSDictionary new];
                    break;
                case UpdateTypeYou:{
                    
                    if ([userTo isEqualToString:@"you"]) {
                        //Regalos recibidos
                        double getDate = [datetime doubleValue];
                        NSTimeInterval seconds = getDate / 1000;
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
                        NSString *dateString = [dateFormat stringFromDate:date];
                        //NSLog(@"date: %@", dateString);
                        
                        
                        dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", userFrom, giftName, merchantName],
                                 @"date":dateString,
                                 @"type":pictureType,
                                 @"image":picture};
                        [arrayAux addObject:dict];
                    }else if ([userFrom isEqualToString:@"you"]) {
                        //Regalos enviados
                        double getDate = [datetime doubleValue];
                        NSTimeInterval seconds = getDate / 1000;
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
                        NSString *dateString = [dateFormat stringFromDate:date];
                        //NSLog(@"date: %@", dateString);
                        
                        dict = @{@"title": [NSString stringWithFormat:@"You sent %@ to %@ from %@", giftName, userTo, merchantName],
                                 @"date": dateString,
                                 @"type":pictureType,
                                 @"image":picture};
                        [arrayAux addObject:dict];
                    }
                }
                    break;
                case UpdateTypeCompany:
                    dict = [NSDictionary new];
                    break;
                default:
                    break;
            }
            
        }
        self.dataUpdates = arrayAux;
        //NSLog(@"dataUpdates: %@", self.dataUpdates);
    }
    
}
*/

-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tappedHeaderSegment:(UISegmentedControl*)segment{
    @try {
        if ([DataProvider networkConnected]) {
            //Mostrar ícono de descarga
            self.hud = [MBProgressHUD showHUDAddedTo:self.tableview animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = NSLocalizedString(@"Loading updates", nil);
            self.data = [NSArray new];
            switch (segment.selectedSegmentIndex) {
                case 0:
                    self.updateType = UpdateTypeFriends;
                    break;
                case 1:
                    self.updateType = UpdateTypeYou;
                    break;
                case 2:
                    self.updateType = UpdateTypeCompany;
                    break;
                default:
                    break;
            }
            //[self getUpdatesData];
            //[self obtenNotificacionesRegalosRecibidos];
            [self notificacionesRegalosEnviados];
            self.esRegaloRecibido = NO;
            [self.tableview reloadData];
            [self.hud hide:YES];
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

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //COMENTÈ
    /*
    if ([self.dataGiftsToUser count] > 0) {
        return 2;
    }else{
        return 1;
    }
     */
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //COMENTÉ
    /*
    if ([self.dataGiftsToUser count] > 0) {
        if (section == 0) {
            return 1;
        }else{
            return [self.data count];
        }
    }else{
        return [self.data count];
    }
     */
    if (section == 0) {
        return 1;
    }else{
        return [self.dataUpdates count];
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
    
    myLabel.frame = CGRectMake(0, 0, 200, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:12];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.center = CGPointMake(SCREEN_WIDTH / 2 - 10, 15);
    myLabel.textColor = [UIColor altruus_darkSkyBlueColor];
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    
    [headerView addSubview:myLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    //COMENTÉ
    /*
    if ([self.dataGiftsToUser count] > 0) {
        if (section == 0) {
            return NSLocalizedString(@"RECENT", nil);
        }else{
            return NSLocalizedString(@"PREVIOUS", nil);
        }
    }else{
        return NSLocalizedString(@"RECENT", nil);
    }
     */
    if (section == 0) {
        return NSLocalizedString(@"RECENT", nil);
    }else{
        return NSLocalizedString(@"PREVIOUS", nil);
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"UpdatesTableViewCell" bundle:nil] forCellReuseIdentifier:@"updateCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"updateCell"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.masksToBounds = YES;
    
    NSDictionary *update;
    NSString *title, *date, *url, *pictureType;
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
        
        NSString *strAux;
        //if ([self.dataGiftsToUser count] > 0) {
        if ([self numeroRegalosUnredeemed] > 0) {
            strAux = [NSString stringWithFormat:@"You have new gifts"];
        }else{
            strAux = [NSString stringWithFormat:@"You don't have new gifts"];
        }
        ((UpdatesTableViewCell*)cell).mainLabel.text = NSLocalizedString(strAux, nil);
        
        NSString *str;
        if ([self numeroRegalosUnredeemed] > 0) {
            str = [NSString stringWithFormat:@"%lu items", (unsigned long)[DataProvider numberOfGiftsUnredeemed]];
        }else{
            str = [NSString stringWithFormat:@"0 items"];
        }
        ((UpdatesTableViewCell*)cell).subLabel.text = NSLocalizedString(str, nil);
        
        UIImage *image = [UIImage imageNamed:@"yourItems-GiftBox"];
        [((UpdatesTableViewCell*)cell).imageView setImage:image];
    }else{
        update = [self.dataUpdates objectAtIndex:indexPath.row];
        if (![update isKindOfClass:[NSNull class]]) {
            title = update[@"title"];
            date = update[@"date"];
            url = update[@"image"];
            pictureType = update[@"type"];
        }
        
        if ([pictureType isEqualToString:@"NAME"]) {
            url = [NSString stringWithFormat:@"%@%@", PREFIJO_PHOTO, url];
        }
        
        //NSLog(@"Picture Type: %@", update[@"type"]);
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData: data];
        
        ((UpdatesTableViewCell*)cell).mainLabel.text = title;
        ((UpdatesTableViewCell*)cell).subLabel.text = date;
        /*
        if (self.updateType == UpdateTypeYou && indexPath.section == 0) {
            ((UpdatesTableViewCell*)cell).imageView.image = image;
        }else{
            ((UpdatesTableViewCell*)cell).imageView.image = image;
        }
        ((UpdatesTableViewCell*)cell).imageView.contentMode = UIViewContentModeScaleAspectFit;
        ((UpdatesTableViewCell*)cell).imageView.clipsToBounds = YES;
         */
        ((UpdatesTableViewCell*)cell).imageView.image = image;
        ((UpdatesTableViewCell*)cell).imageView.contentMode = UIViewContentModeScaleAspectFit;
        ((UpdatesTableViewCell*)cell).imageView.clipsToBounds = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"giftsReceived"];
    ((GiftsReceivedViewController*)controller).data = self.dataGiftsToUser;
    ((GiftsReceivedViewController*)controller).localUser = self.localUser;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
