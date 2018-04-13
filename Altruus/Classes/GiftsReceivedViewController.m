//
//  GiftsReceivedViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 30/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//
//LISTA DE REGALOS RECIBIDOS

#import "GiftsReceivedViewController.h"
#import "constants.h"
#import "UpdatesTableViewCell.h"
#import "GiftReceivedDetailViewController.h"
#import "GiftsReceivedTableViewCell.h"
#import "Servicios.h"
#import "AppDelegate.h"
#import "DataProvider.h"
#import "GiftsReceived.h"
#import <MBProgressHUD.h>
#import "LoadingTableViewCell.h"


@interface GiftsReceivedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *updateData;
@property (strong, nonatomic) MBProgressHUD *hud;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeight;

@property (assign) NSInteger batchSize;
@property (assign) NSInteger pageResults;
@property (assign) NSInteger actualResult;
@property (assign) NSInteger sizeResults;
@property (assign) NSInteger totalResultsFound;
@property (assign) NSInteger currentPage;
@property (assign) NSInteger sizePerPage;

@end

@implementation GiftsReceivedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self fetchData];
    [self.tableView reloadData];
}

-(void)setup{
    self.segmentControlHeight.constant = 0;
    self.navigationItem.title = NSLocalizedString(@"Received Gifts", nil);
    
    self.tableView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableView.layer.cornerRadius = 5;
    
    _currentPage = 1;
    _sizePerPage = 8;
}

-(void)fetchData{
    self.updateData = nil;
    [self.tableView reloadData];
    
    //Mostrar ícono de descarga
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Grabbing Gifts", nil);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.updateData = [self returnUpdatesData];
        [self.hud hide:YES];
        [self.tableView reloadData];
    });
}


-(void)fetchMoreData{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSArray *data =  [self returnUpdatesData];
    
    for (NSObject *object in data) {
        [self.updateData addObject:object];
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.updateData.count - 1 inSection:0]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    });
    //[self.hud hide:YES];
    
}

-(NSMutableArray*)returnUpdatesData{
    NSMutableArray *arrayAux = [NSMutableArray new];
    
    if ([DataProvider networkConnected]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&sort=UNREDEEMED_DATE_DESC&page=%ld&size=%ld&status=unredeemed", RETRIEVE_USER_GIFTS_V3, self.localUser.session, _currentPage, _sizePerPage ];
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
                NSDictionary *dictAux;
                NSString *date, *giftCode, *giftName, *idGift, *image, *merchantName, *senderName, *senderPicture, *status, *price, *redeemCode, *redeemDate;
                NSArray *array = [dictionary objectForKey:@"results"];
                
                _batchSize = [[dictionary objectForKey:@"batchSize"] integerValue];
                _pageResults = [[dictionary objectForKey:@"page"] integerValue];
                _sizeResults = [[dictionary objectForKey:@"size"] integerValue];
                _totalResultsFound = [[dictionary objectForKey:@"totalResultsFound"] integerValue];
                _actualResult = _actualResult + [array count];
                
                for(NSDictionary *dict in array){
                    date =  [NSString stringWithFormat:@"%@",[dict objectForKey:@"createdAt"]];
                    giftCode = [NSString stringWithFormat:@"%@",[dict objectForKey:@"giftCode"]];
                    giftName = [dict objectForKey:@"giftName"];
                    idGift = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                    image = [dict objectForKey:@"giftPicture"];
                    merchantName = [dict objectForKey:@"merchantName"];
                    senderName = [dict objectForKey:@"senderName"];
                    senderPicture = [dict objectForKey:@"senderPicture"];
                    status = [dict objectForKey:@"status"];
                    price = [NSString stringWithFormat:@"%@",[dict objectForKey:@"price"]];
                    redeemCode = [NSString stringWithFormat:@"%@",[dict objectForKey:@"redeemCode"]];
                    redeemDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"redeemedAt"]];
                    
                    
                    //Fecha 1
                    NSString *datetime = date;
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
                    NSString *fechaFinal, *fechaFinalRedeem;
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setLocale:[NSLocale currentLocale]];
                    NSArray *months = [df monthSymbols];
                    NSInteger mes = [[dateSeparate objectAtIndex:1] integerValue];
                    NSInteger dia = [[dateSeparate objectAtIndex:0] integerValue];
                    
                    fechaFinal = [NSString stringWithFormat:@"%@ %ld %@ %@m.", [[months objectAtIndex:mes-1] capitalizedString], (long)dia, [dateSeparate objectAtIndex:2], hourOriginal];
                    
                    //Fecha 2
                    if([redeemDate isEqualToString:@""]){
                        fechaFinalRedeem = @"";
                    }else{
                        datetime = redeemDate;
                        getDate = [datetime doubleValue];
                        seconds = getDate / 1000;
                        date = [NSDate dateWithTimeIntervalSince1970:seconds];
                        dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
                        dateString = [dateFormat stringFromDate:date];
                        
                        array = [dateString componentsSeparatedByString:@" "];
                        @try {
                            dateOriginal = [array objectAtIndex:0];
                            hourOriginal = [array objectAtIndex:1];
                        } @catch (NSException *exception) {
                            
                        }
                        
                        dateSeparate = [dateOriginal componentsSeparatedByString:@"/"];
                        
                        months = [df monthSymbols];
                        mes = [[dateSeparate objectAtIndex:1] integerValue];
                        dia = [[dateSeparate objectAtIndex:0] integerValue];
                        
                        fechaFinalRedeem = [NSString stringWithFormat:@"%@ %ld %@ %@m.", [[months objectAtIndex:mes-1] capitalizedString], (long)dia, [dateSeparate objectAtIndex:2], hourOriginal];
                    }
                    
                    
                    dictAux = @{@"date": fechaFinal,
                                @"dateRedeem": fechaFinalRedeem,
                             @"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", senderName, giftName, merchantName],
                             @"giftCode": giftCode,
                             @"giftName": giftName,
                             @"idGift": idGift,
                             @"image": image,
                             @"merchantName": merchantName,
                             @"senderName": senderName,
                             @"senderPicture": senderPicture,
                             @"status": status,
                             @"price": price,
                             @"redeemCode": redeemCode};
                    [arrayAux addObject:dictAux];
                    
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
    
    
    return arrayAux;
}

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.updateData count];
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
    static NSString *cellLoadingIdentifier = @"Loading";

    if (indexPath.row < [self.updateData count]-1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell"];
        [tableView registerNib:[UINib nibWithNibName:@"GiftsReceivedTableViewCell" bundle:nil] forCellReuseIdentifier:@"giftCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell"];
        return cell;
    }else{
        if(_actualResult < _totalResultsFound){
            LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellLoadingIdentifier forIndexPath:indexPath];
            [cell.activityIndicatorView startAnimating];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell"];
    [tableView registerNib:[UINib nibWithNibName:@"GiftsReceivedTableViewCell" bundle:nil] forCellReuseIdentifier:@"giftCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell"];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *update;
    NSString *title, *date, *url, *status, *price, *dateRedeem;
    
    update = [self.updateData objectAtIndex:indexPath.row];
    NSLog(@"Update: %@", update);
    if (![update isKindOfClass:[NSNull class]]) {
        title = update[@"title"];
        date = update[@"date"];
        dateRedeem = update[@"dateRedeem"];
        url = update[@"image"];
        status = update[@"status"];
        price = update[@"price"];
    }
    
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.masksToBounds = YES;
    
    if([status isEqualToString:@"redeemed"]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = NO;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = YES;
    }
    
    ((GiftsReceivedTableViewCell*)cell).mainLabel.text = title;
    
    NSString *aux1 = NSLocalizedString(@"Date Received", nil);
    NSString *aux2 = NSLocalizedString(@"Date Redeemed", nil);
    
    aux1 = [NSString stringWithFormat:@"%@: %@", aux1, date];
    aux2 = [NSString stringWithFormat:@"%@: %@", aux2, dateRedeem];
    
    if([status isEqualToString:@"unredeemed"]){
        aux2 = NSLocalizedString(@"Not Yet Redeemed", nil);
    }
    
    ((GiftsReceivedTableViewCell*)cell).subLabel.text =   aux1;
    ((GiftsReceivedTableViewCell*)cell).redeemLabel.text = aux2;
    
    NSString *urlImage = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", update[@"senderPicture"]];
    NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:urlImage]];
    UIImage *image = [UIImage imageWithData: data];
    //[((UpdatesTableViewCell*)cell).imageView setImage:image];
    [((GiftsReceivedTableViewCell*)cell).imageView setImage:image];
    
    
    
    if(indexPath.row+2 < _totalResultsFound && indexPath.row+2 == _actualResult){
        _currentPage++;
        [self fetchMoreData];
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"Data: %@", [self.data objectAtIndex:indexPath.row]);
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"giftReceivedDetail"];
    //((GiftsReceivedViewController*)controller).data = self.dataGiftsToUser;
    ((GiftReceivedDetailViewController*)controller).localUser = self.localUser;
    ((GiftReceivedDetailViewController*)controller).giftReceived = [self.updateData objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    
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
                    gift.price = [NSString stringWithFormat:@"%@",[dict objectForKey:@"price"]];
                    gift.redeemCode = [NSString stringWithFormat:@"%@",[dict objectForKey:@"redeemCode"]];
                    
                    NSError *error;
                    if (![managedContext save:&error]) {
                        NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                    }
                    
                }
            }
        }
        
        /*
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
                gift.price = [dictionary objectForKey:@"price"];
                
                NSError *error;
                if (![managedContext save:&error]) {
                    NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                }
                
            }
            
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
}

-(void)notificacionesRegalosRecibidos{
    self.data = [NSArray new];
    
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
                 @"date":fechaFinal,
                 @"dateO":dateString,
                 @"giftName":gift.giftName,
                 @"merchantName":gift.merchantName,
                 @"giftCode":gift.giftCode,
                 @"id":gift.idGift,
                 @"senderPicture":gift.senderPicture,
                 @"status":gift.status,
                 @"price":gift.price,
                 @"redeemCode":gift.redeemCode,
                 @"image":gift.image};
        [arrayAux addObject:dict];
    }
    self.data = arrayAux;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
