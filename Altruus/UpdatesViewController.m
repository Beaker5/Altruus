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

@property (assign, nonatomic) NSInteger totalUnredeemed;

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
        NSLog(@"Mostraré");
        
        if ([DataProvider networkConnected]) {
            //[self grabaNotificacionesRegalosRecibidos]; //COMENTE 040118
            [self actualizaNumeroRegalosRecibidos];     //COMENTE 040118
            
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
    
    [self numeroRegalosUnredeemed];
    
    NSString *strAux;
    //if ([self numeroRegalosUnredeemed] > 0) {  //DESCOMENTE 040118
    //if ([DataProvider numberOfGiftsUnredeemed] > 0) {  //COMENTE 040118
    if (self.totalUnredeemed > 0) {  //DESCOMENTE 040118
        strAux = [NSString stringWithFormat:@"You have new gifts"];
    }else{
        strAux = [NSString stringWithFormat:@"You don't have new gifts"];
    }
    ((UpdatesTableViewCell*)cell).mainLabel.text = NSLocalizedString(strAux, nil);
    
    NSString *str;
    //if ([self numeroRegalosUnredeemed] > 0) {  //DESCOMENTE 040118
    //if ([DataProvider numberOfGiftsUnredeemed] > 0) {  //COMENTE 040118
    if (self.totalUnredeemed > 0) {  //DESCOMENTE 040118
        str = [NSString stringWithFormat:@"%lu items", (unsigned long)self.totalUnredeemed];
    }else{
        str = [NSString stringWithFormat:@"0 items"];
    }
    ((UpdatesTableViewCell*)cell).subLabel.text = NSLocalizedString(str, nil);
}


-(void)setup{
    //self.segmentControlHeight.constant = 0;
    self.dataUpdates = [NSArray new];
    self.dataGiftsToUser = [NSArray new];
    
    self.totalUnredeemed = 0;
    
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


-(void)numeroRegalosUnredeemed{
    //NSInteger contador = 0;
    //NSInteger total = 0;
    //NSLog(@"Se ejecuta el grabado");
    if ([DataProvider networkConnected]) {
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&status=unredeemed&size=1&page=1", RETRIEVE_USER_GIFTS_V3, self.localUser.session ];
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
            //NSDictionary *dictStatus = [dictionary objectForKey:@"status"];
            //NSInteger code = [[dictStatus objectForKey:@"code"] integerValue];
            self.totalUnredeemed = [[dictionary objectForKey:@"totalResultsFound"] integerValue];
            
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
    //return total;
}

-(void)grabaNotificacionesRegalosRecibidos{
    //NSLog(@"Se ejecuta el grabado");
    if ([DataProvider networkConnected]) {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *managedContext = delegate.managedObjectContext;
        
        [DataProvider deleteGiftsReceived];
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@", RETRIEVE_USER_GIFTS_V3, self.localUser.session ];
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
                NSLog(@"Array: %@", array);
                for(NSDictionary *dict in array){
                    GiftsReceived * gift = [NSEntityDescription insertNewObjectForEntityForName:@"GiftsReceived" inManagedObjectContext:managedContext];
                    gift.date =  [NSString stringWithFormat:@"%@",[dict objectForKey:@"createdAt"]];
                    gift.giftCode = [NSString stringWithFormat:@"%@",[dict objectForKey:@"giftCode"]];
                    gift.giftName = [dict objectForKey:@"giftName"];
                    gift.idGift = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                    gift.image = [dict objectForKey:@"giftPicture"];
                    gift.merchantName = [dict objectForKey:@"merchantName"];
                    gift.senderName = [dict objectForKey:@"senderName"];
                    gift.senderPicture = [dict objectForKey:@"senderPicture"];
                    gift.status = [dict objectForKey:@"status"];
                    gift.price =  [NSString stringWithFormat:@"%@",[dict objectForKey:@"price"]];
                    gift.redeemCode = [NSString stringWithFormat:@"%@",[dict objectForKey:@"redeemCode"]];
                    
                    NSError *error;
                    if (![managedContext save:&error]) {
                        NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
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
        
        
        NSArray *array = [dateString componentsSeparatedByString:@" "];
        NSString *dateOriginal, *hourOriginal;
        @try {
            dateOriginal = [array objectAtIndex:0];
            hourOriginal = [array objectAtIndex:1];
        } @catch (NSException *exception) {
            
        }
        
        NSArray *dateSeparate = [dateOriginal componentsSeparatedByString:@"/"];
        NSString *fechaFinal;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[NSLocale currentLocale]];
        NSArray *months = [df monthSymbols];
        NSInteger mes = [[dateSeparate objectAtIndex:1] integerValue];
        NSInteger dia = [[dateSeparate objectAtIndex:0] integerValue];
        
        fechaFinal = [NSString stringWithFormat:@"%@ %ld %@ %@m.", [[months objectAtIndex:mes-1] capitalizedString], (long)dia, [dateSeparate objectAtIndex:2], hourOriginal];
        
        
        dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", gift.senderName, gift.giftName, gift.merchantName],
                 //@"date":dateString,
                 @"date":fechaFinal,
                 @"dateO":dateString,
                 @"giftName":gift.giftName,
                 @"merchantName":gift.merchantName,
                 @"giftCode":gift.giftCode,
                 @"id":gift.idGift,
                 @"senderPicture":gift.senderPicture,
                 @"status":gift.status,
                 @"redeemCode":gift.redeemCode,
                 @"image":gift.image};
        [arrayAux addObject:dict];
    }
    self.dataGiftsToUser = arrayAux;

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
                    
                    NSArray *array = [dateString componentsSeparatedByString:@" "];
                    NSString *dateOriginal, *hourOriginal;
                    @try {
                        dateOriginal = [array objectAtIndex:0];
                        hourOriginal = [array objectAtIndex:1];
                    } @catch (NSException *exception) {
                        
                    }
                    
                    NSArray *dateSeparate = [dateOriginal componentsSeparatedByString:@"/"];
                    NSString *fechaFinal;
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setLocale:[NSLocale currentLocale]];
                    NSArray *months = [df monthSymbols];
                    NSInteger mes = [[dateSeparate objectAtIndex:1] integerValue];
                    NSInteger dia = [[dateSeparate objectAtIndex:0] integerValue];
                    
                    fechaFinal = [NSString stringWithFormat:@"%@ %ld %@ %@m.", [[months objectAtIndex:mes-1] capitalizedString], (long)dia, [dateSeparate objectAtIndex:2], hourOriginal];
                    
                    
                    dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", userFrom, giftName, merchantName],
                             @"date":fechaFinal,
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
                    
                    NSArray *array = [dateString componentsSeparatedByString:@" "];
                    NSString *dateOriginal, *hourOriginal;
                    @try {
                        dateOriginal = [array objectAtIndex:0];
                        hourOriginal = [array objectAtIndex:1];
                    } @catch (NSException *exception) {
                        
                    }
                    
                    NSArray *dateSeparate = [dateOriginal componentsSeparatedByString:@"/"];
                    NSString *fechaFinal;
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setLocale:[NSLocale currentLocale]];
                    NSArray *months = [df monthSymbols];
                    NSInteger mes = [[dateSeparate objectAtIndex:1] integerValue];
                    NSInteger dia = [[dateSeparate objectAtIndex:0] integerValue];
                    
                    fechaFinal = [NSString stringWithFormat:@"%@ %ld %@ %@m.", [[months objectAtIndex:mes-1] capitalizedString], (long)dia, [dateSeparate objectAtIndex:2], hourOriginal];
                    
                    dict = @{@"title": [NSString stringWithFormat:@"You sent %@ to %@ from %@", giftName, userTo, merchantName],
                             @"date": fechaFinal,
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
    
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
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
        //if ([DataProvider numberOfGiftsUnredeemed] > 0) {  //COMENTE 040118
        //if ([self numeroRegalosUnredeemed] > 0) {  //DESCOMENTE
        if (self.totalUnredeemed > 0) {  //DESCOMENTE
            strAux = [NSString stringWithFormat:@"You have new gifts"];
        }else{
            strAux = [NSString stringWithFormat:@"You don't have new gifts"];
        }
        ((UpdatesTableViewCell*)cell).mainLabel.text = NSLocalizedString(strAux, nil);
        
        NSString *str;
      
        if (self.totalUnredeemed > 0) {  //DESCOMENTE 040118
            //str = [NSString stringWithFormat:@"%lu items", (unsigned long)[DataProvider numberOfGiftsUnredeemed]]; //COMENTE 040118
            str = [NSString stringWithFormat:@"%lu items", (unsigned long)self.totalUnredeemed]; //AGREGUE 040118
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
