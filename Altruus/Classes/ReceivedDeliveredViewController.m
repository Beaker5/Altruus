//
//  ReceivedDeliveredViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 04/06/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "ReceivedDeliveredViewController.h"
#import "constants.h"
#import "Servicios.h"
#import "UpdatesTableViewCell.h"
#import "DataProvider.h"

@interface ReceivedDeliveredViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeight;


@end

@implementation ReceivedDeliveredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try {
        if ([DataProvider networkConnected]) {
            [self fetchData];
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
    
    
    
    [self setup];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}

-(void)setup{
    self.segmentControlHeight.constant = 0;
    
    if ([self.screenType isEqualToString:@"S"]) {
        self.navigationItem.title = NSLocalizedString(@"Sent", nil);
    }else if([self.screenType isEqualToString:@"R"]){
        self.navigationItem.title = NSLocalizedString(@"Received", nil);
    }
    
    self.tableview.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableview.layer.cornerRadius = 5;
}

-(void)fetchData{
    NSLog(@"Local User: %@", self.localUser);
    
    self.data = [NSArray new];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString;
    if (!jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPDATES_USER]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    
    NSInteger code = [httpResponse statusCode];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"-----------------------------------------------------------------------------------");
    NSLog(@"Codigo: %ld, Diccionario Updates: %@", (long)code, array);
    NSLog(@"-----------------------------------------------------------------------------------");
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
            
            /*
            double getDate = 14211;
            NSTimeInterval seconds = getDate / 1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
            NSLog(@"Date: %@", date);
            */
            
            if ([userTo isEqualToString:@"you"] && [self.screenType isEqualToString:@"R"]) {
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
            }else if ([userFrom isEqualToString:@"you"] && [self.screenType isEqualToString:@"S"]) {
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
        self.data = arrayAux;
    }
    
}

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.data count];
}

/*
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
*/
 
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSDictionary *update;
    NSString *title, *date, *url, *pictureType;
    
    update = [self.data objectAtIndex:indexPath.row];
    if (![update isKindOfClass:[NSNull class]]) {
        title = update[@"title"];
        date = update[@"date"];
        url = update[@"image"];
        pictureType = update[@"type"];
    }
    
    if ([pictureType isEqualToString:@"NAME"]) {
        url = [NSString stringWithFormat:@"%@%@", PREFIJO_PHOTO, url];
    }
    
    ((UpdatesTableViewCell*)cell).mainLabel.text = title;
    ((UpdatesTableViewCell*)cell).subLabel.text = date;
    
    NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData: data];
    
    //NSString *urlImage = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", update[@"senderPicture"]];
    //NSData *data = [NSData dataWithContentsOfURL : [NSURL URLWithString:urlImage]];
    //UIImage *image = [UIImage imageWithData: data];
    [((UpdatesTableViewCell*)cell).imageView setImage:image];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
