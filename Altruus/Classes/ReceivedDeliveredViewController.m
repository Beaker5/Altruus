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
#import <MBProgressHUD.h>
#import "LoadingTableViewCell.h"
#import "GiftsReceivedTableViewCell.h"


@interface ReceivedDeliveredViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Autolayout constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentControlHeight;

@property (strong, nonatomic) NSMutableArray *updateData;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (assign) NSInteger batchSize;
@property (assign) NSInteger pageResults;
@property (assign) NSInteger actualResult;
@property (assign) NSInteger sizeResults;
@property (assign) NSInteger totalResultsFound;
@property (assign) NSInteger currentPage;
@property (assign) NSInteger sizePerPage;

@end

@implementation ReceivedDeliveredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}

-(void)setup{
    self.segmentControlHeight.constant = 0;
    
    if ([self.screenType isEqualToString:@"S"]) {
        self.navigationItem.title = NSLocalizedString(@"Sent", nil);
    }else if([self.screenType isEqualToString:@"R"]){
        self.navigationItem.title = NSLocalizedString(@"Received", nil);
    }
    
    self.tableView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableView.layer.cornerRadius = 5;
    
    _currentPage = 1;
    _sizePerPage = 8;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self fetchData];
    [self.tableView reloadData];
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
    
    self.data = [NSArray new];
    NSString *aux = @"";
    
    if([self.screenType isEqualToString:@"S"]){
        aux = [NSString stringWithFormat:@"sent"];
    }else{
        if([self.screenType isEqualToString:@"R"]){
            aux = [NSString stringWithFormat:@"received"];
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?session=%@&page=%ld&size=%ld&type=%@&sort=DATE_DESC", UPDATES_USER_V3, self.localUser.session, _currentPage, _sizePerPage, aux ];
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
            NSArray *array = [dictionary objectForKey:@"updates"];
            
            NSDictionary *dict;
            NSString *giftName, *merchantName, *userFrom, *userTo, *picture, *pictureType, *sentOrReceived, *senderPicture, *receiverPicture, *redeemDate, *date, *isRedeemed;
            
            
            _batchSize = [[dictionary objectForKey:@"batchSize"] integerValue];
            _pageResults = [[dictionary objectForKey:@"page"] integerValue];
            _sizeResults = [[dictionary objectForKey:@"size"] integerValue];
            _totalResultsFound = [[dictionary objectForKey:@"totalResultsFound"] integerValue];
            _actualResult = _actualResult + [array count];
            
            for (NSDictionary *dict2 in array) {
                
                giftName = [dict2 objectForKey:@"giftName"];
                merchantName = [dict2 objectForKey:@"merchantName"];
                userFrom = [dict2 objectForKey:@"senderName"]; //De quien es
                userTo = [dict2 objectForKey:@"receiverName"]; //A quien se lo envio
                picture = [dict2 objectForKey:@"receiverPicture"];
                //pictureType = [dict2 objectForKey:@"pictureType"];
                date = [dict2 objectForKey:@"createdAt"];
                redeemDate = [dict2 objectForKey:@"redeemAt"];
                pictureType = @"NAME";
                sentOrReceived = [dict2 objectForKey:@"sentOrReceived"];
                senderPicture = [dict2 objectForKey:@"senderPicture"];
                receiverPicture = [dict2 objectForKey:@"receiverPicture"];
                isRedeemed =  [NSString stringWithFormat:@"%@", [dict2 objectForKey:@"isRedeemed"]];
                
                
                //FEcha 1
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
                
                if([redeemDate isEqualToString:@""]){
                    fechaFinalRedeem = @"";
                }else{
                    //Fecha 2
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
                
                if([self.screenType isEqualToString:@"S"]){
                    dict = @{@"title": [NSString stringWithFormat:@"You sent %@ to %@ from %@", giftName, userTo, merchantName],
                             @"date": fechaFinal,
                             @"dateRedeem": fechaFinalRedeem,
                             @"type":pictureType,
                             @"isRedeemed": isRedeemed,
                             @"image":receiverPicture};
                }else if([self.screenType isEqualToString:@"R"]){
                    dict = @{@"title": [NSString stringWithFormat:@"%@ sent you %@ from %@", userFrom, giftName, merchantName],
                             @"date": fechaFinal,
                             @"dateRedeem": fechaFinalRedeem,
                             @"type":pictureType,
                             @"isRedeemed": isRedeemed,
                             @"image":senderPicture};
                }
                
                [arrayAux addObject:dict];
            }
            
        }
    }
    
    return  arrayAux;
}



-(void)fetchData2{
    //NSLog(@"Local User: %@", self.localUser);
    self.data = [NSArray new];
    NSString *urlString = [NSString stringWithFormat:@"%@?session=%@", UPDATES_USER_V3, self.localUser.session ];
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
            NSArray *array = [dictionary objectForKey:@"updates"];
            NSMutableArray *arrayAux = [NSMutableArray new];
            NSDictionary *dict;
            NSString *giftName, *merchantName, *userFrom, *userTo, *picture, *pictureType, *datetime, *sentOrReceived;
            for (NSDictionary *dict2 in array) {
                giftName = [dict2 objectForKey:@"giftName"];
                merchantName = [dict2 objectForKey:@"merchantName"];
                userFrom = [dict2 objectForKey:@"senderName"]; //De quien es
                userTo = [dict2 objectForKey:@"receiverName"]; //A quien se lo envio
                picture = [dict2 objectForKey:@"receiverPicture"];
                //pictureType = [dict2 objectForKey:@"pictureType"];
                datetime = [dict2 objectForKey:@"createdAt"];
                pictureType = @"NAME";
                sentOrReceived = [dict2 objectForKey:@"sentOrReceived"];
                if ([sentOrReceived isEqualToString:@"sent"]) {
                    //Regalos enviados
                    double getDate = [datetime doubleValue];
                    NSTimeInterval seconds = getDate / 1000;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mma"];
                    NSString *dateString = [dateFormat stringFromDate:date];
                    
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
    
}

#pragma -mark Tableview Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.updateData count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
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
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.masksToBounds = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSDictionary *update;
    NSString *title, *date, *url, *pictureType, *picture, *isRedeemed, *dateRedeem;
    
    update = [self.updateData objectAtIndex:indexPath.row];
    if (![update isKindOfClass:[NSNull class]]) {
        title = update[@"title"];
        date = update[@"date"];
        dateRedeem = update[@"dateRedeem"];
        picture = update[@"image"];
        pictureType = update[@"type"];
        isRedeemed = update[@"isRedeemed"];
    }
    
    if ([pictureType isEqualToString:@"NAME"]) {
        url = [NSString stringWithFormat:@"%@%@", PREFIJO_PHOTO, url];
    }
   
    if([isRedeemed isEqualToString:@"1"]){
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = NO;
    }else{
        ((GiftsReceivedTableViewCell*)cell).redeemImageview.hidden = YES;
    }
    
    ((GiftsReceivedTableViewCell*)cell).mainLabel.text = title;
    
    NSString *aux1 = NSLocalizedString(@"Date Received", nil);
    NSString *aux2 = NSLocalizedString(@"Date Redeemed", nil);
    
    aux1 = [NSString stringWithFormat:@"%@: %@", aux1, date];
    aux2 = [NSString stringWithFormat:@"%@: %@", aux2, dateRedeem];
    
    if([isRedeemed isEqualToString:@"0"]){
        aux2 = NSLocalizedString(@"Not Yet Redeemed", nil);
    }
    
    ((GiftsReceivedTableViewCell*)cell).subLabel.text =   aux1;
    ((GiftsReceivedTableViewCell*)cell).redeemLabel.text = aux2;
    
    NSString *urlImage = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", picture];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
