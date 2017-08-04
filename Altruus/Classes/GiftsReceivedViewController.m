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


@interface GiftsReceivedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeight;

@end

@implementation GiftsReceivedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self grabaNotificacionesRegalosRecibidos];
    [self notificacionesRegalosRecibidos];
    [self.tableview reloadData];
}

-(void)setup{
    self.segmentControlHeight.constant = 0;
    self.navigationItem.title = NSLocalizedString(@"Received Gifts", nil);
    
    self.tableview.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableview.layer.cornerRadius = 5;
}

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.data count];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell"];
    if (!cell) {
        //[tableView registerNib:[UINib nibWithNibName:@"UpdatesTableViewCell" bundle:nil] forCellReuseIdentifier:@"updateCell"];
        [tableView registerNib:[UINib nibWithNibName:@"GiftsReceivedTableViewCell" bundle:nil] forCellReuseIdentifier:@"giftCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *update;
    NSString *title, *date, *url, *status, *price;
    
    update = [self.data objectAtIndex:indexPath.row];
    if (![update isKindOfClass:[NSNull class]]) {
        title = update[@"title"];
        date = update[@"date"];
        url = update[@"image"];
        status = update[@"status"];
        price = update[@"price"];
    }
    
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.masksToBounds = YES;
    
    /*
    if ([status isEqualToString:@"UNREDEEMED"] && [price isEqualToString:@"0.00"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = YES;
    }else if([status isEqualToString:@"REDEEMED"]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = NO;
    }if ([status isEqualToString:@"UNREDEEMED"] && ![price isEqualToString:@"0.00"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = YES;
    }*/
    if([status isEqualToString:@"REDEEMED"]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = NO;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.userInteractionEnabled = YES;
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = YES;
    }
    
    
    //((UpdatesTableViewCell*)cell).mainLabel.text = title;
    //((UpdatesTableViewCell*)cell).subLabel.text = date;
    ((GiftsReceivedTableViewCell*)cell).mainLabel.text = title;
    ((GiftsReceivedTableViewCell*)cell).subLabel.text = date;
    
    NSString *urlImage = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", update[@"senderPicture"]];
    NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:urlImage]];
    UIImage *image = [UIImage imageWithData: data];
    //[((UpdatesTableViewCell*)cell).imageView setImage:image];
    [((GiftsReceivedTableViewCell*)cell).imageView setImage:image];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"Data: %@", [self.data objectAtIndex:indexPath.row]);
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"gifts" bundle:nil];
    UIViewController *controller = [sb instantiateViewControllerWithIdentifier:@"giftReceivedDetail"];
    //((GiftsReceivedViewController*)controller).data = self.dataGiftsToUser;
    ((GiftReceivedDetailViewController*)controller).localUser = self.localUser;
    ((GiftReceivedDetailViewController*)controller).giftReceived = [self.data objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    
}

/*
-(void)notificacionesRegalosRecibidos{
    self.data = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.localUser = [User getLocalUserSesion:context];
    
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
    NSLog(@"Codigo: %ld, Diccionario Usuario: %@, Contador: %lu", (long)code, array, (unsigned long)[array count]);
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
            
            
            dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", [dictionary objectForKey:@"senderName"], [dictionary objectForKey:@"giftName"], [dictionary objectForKey:@"merchantName"]],
                     @"date":dateString,
                     @"giftName":[dictionary objectForKey:@"giftName"],
                     @"merchantName":[dictionary objectForKey:@"merchantName"],
                     @"giftCode":[dictionary objectForKey:@"giftCode"],
                     @"id":[dictionary objectForKey:@"id"],
                     @"senderPicture":[dictionary objectForKey:@"senderPicture"],
                     @"status":[dictionary objectForKey:@"status"],
                     @"price":[dictionary objectForKey:@"price"],
                     @"image":[dictionary objectForKey:@"picture"]};
            [arrayAux addObject:dict];
            
        }
        self.data = arrayAux;
        NSLog(@"GiftsToUser: %@", self.data);
    }
}
*/

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
                gift.price = [dictionary objectForKey:@"price"];
                
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
        
        dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", gift.senderName, gift.giftName, gift.merchantName],
                 @"date":dateString,
                 @"giftName":gift.giftName,
                 @"merchantName":gift.merchantName,
                 @"giftCode":gift.giftCode,
                 @"id":gift.idGift,
                 @"senderPicture":gift.senderPicture,
                 @"status":gift.status,
                 @"price":gift.price,
                 @"image":gift.image};
        [arrayAux addObject:dict];
    }
    self.data = arrayAux;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
