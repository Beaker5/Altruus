//
//  OrganizationsFreeViewController.m
//  Altruus
//
//  Created by Alberto Rivera on 07/11/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "OrganizationsFreeViewController.h"
#import "OrganizationProfileViewController.h"
#import "UISegmentedControl+Utils.h"
#import "constants.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "OrgTableViewCell.h"
#import <MBProgressHUD.h>
#import "User+Utils.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "Servicios.h"
#import "DataProvider.h"
#import "Organization.h"
#import <MZFormSheetController.h>

@interface OrganizationsFreeViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) User *localUser;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *segmentedControlHeight;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign) NSInteger batchSize;
@property (assign) NSInteger pageResults;
@property (assign) NSInteger actualResult;
@property (assign) NSInteger sizeResults;
@property (assign) NSInteger totalResultsFound;

@end

@implementation OrganizationsFreeViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    
    if (!self.localUser) {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        //self.localUser = [User getLocalUserInContext:context];
        self.localUser = [User getLocalUserSesion:context];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
    
    [self setup];
    [self fetchData];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


-(void)setup{
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControlHeight.constant = 0;
    
    NSLog(@"Viene de amigos: %@, Friend: %@", self.vieneDeAmigos ? @"YES" : @"NO", self.friend);
    
    [self.segmentedControl addTarget:self action:@selector(tappedHeaderSegment:) forControlEvents:UIControlEventValueChanged];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"BUSINESS", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"CHARITY", nil) forSegmentAtIndex:1];
    [self.segmentedControl setEnabled:NO forSegmentAtIndex:1];
    
    self.view.backgroundColor = [UIColor altruus_duckEggBlueColor];
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    
    
    self.tableView.backgroundColor = [UIColor altruus_duckEggBlueColor];
    self.tableView.layer.cornerRadius = 5;
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
}

-(void)fetchData{
    self.data = [NSArray new];
    [DataProvider deleteOrganizationsRecords];
    
    @try {
        if ([DataProvider networkConnected]) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = NSLocalizedString(@"Getting Businesses", nil);
            
            [self getBusinessOrganizationsv3];
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

-(NSArray*)getBusinessFromOrganizations:(NSString*)substring{
    NSMutableArray *organizations = [NSMutableArray new];
    
    NSArray *arrayAux = [DataProvider getOrganizationsRecords:@"B" andPredicate:substring];
    
    for (Organization *org in arrayAux) {
        NSDictionary *dict;
        NSLog(@"%@, %@, %@, %@", org.idString,org.distance, org.photo, org.name);
        
        
        dict = @{@"id": org.idString,
                 @"distance": org.distance,
                 @"image": org.photo,
                 @"name": org.name};
        [organizations addObject:dict];
    }
    
    return organizations;
}

-(void)getBusinessOrganizationsv3{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    [DataProvider deleteOrganizationsRecords];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?merchantType=business&session=%@", BUSINESS_ORGANIZATIONS_V3, self.localUser.session ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:0.0];
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger codeService = [httpResponse statusCode];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [formatter setGroupingSeparator:groupingSeparator];
    [formatter setGroupingSize:3];
    [formatter setAlwaysShowsDecimalSeparator:NO];
    [formatter setUsesGroupingSeparator:YES];
    
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
            
            NSString *idO, *picture, *name;
            float distance;
            NSString *strAux;
            
            for (NSDictionary *dictResult in array) {
                idO = [dictResult objectForKey:@"id"];
                distance = [[dictResult objectForKey:@"distance"] floatValue];
                picture = [dictResult objectForKey:@"picture"];
                name = [dictResult objectForKey:@"name"];
                
                Organization *org = [NSEntityDescription insertNewObjectForEntityForName:@"Organization" inManagedObjectContext:managedContext];
                org.name = name;
                //org.distance = [NSString stringWithFormat:@"%.02f", distance];
                strAux = [formatter stringFromNumber:[NSNumber numberWithFloat:distance]];
                strAux = [strAux stringByReplacingOccurrencesOfString:@"$" withString:@""];
                strAux = [NSString stringWithFormat:@"%@ km", strAux];
                org.distance = strAux;
                org.photo = picture;
                //org.idO = idO;
                org.idString = idO;
                org.origin = @"B";
                
                NSError *error;
                if (![managedContext save:&error]) {
                    NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.data = [self getBusinessFromOrganizations:nil];
            [self.tableView reloadData];
            [self.hud hide:YES];
        });
        
    }
}

-(void)getBusinessOrganizations{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    [DataProvider deleteOrganizationsRecords];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.localUser.tokenAltruus forKey:@"token"];
    [dict setObject:self.localUser.userIDAltruus forKey:@"userId"];
    [dict setObject:[NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude] forKey:@"longitude"];
    [dict setObject:[NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude] forKey:@"latitude"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString;
    if (!jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BUSINESS_ORGANIZATIONS]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSURLResponse *res = nil;
    NSError *err = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
    
    NSInteger code = [httpResponse statusCode];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [formatter setGroupingSeparator:groupingSeparator];
    [formatter setGroupingSize:3];
    [formatter setAlwaysShowsDecimalSeparator:NO];
    [formatter setUsesGroupingSeparator:YES];
    
    
    if(code == 200){
        NSString *idO, *picture, *name;
        float distance;
        NSString *strAux;
        for (NSDictionary *dictionary in array) {
            idO = [dictionary objectForKey:@"id"];
            distance = [[dictionary objectForKey:@"distance"] floatValue];
            picture = [dictionary objectForKey:@"pictue"];
            name = [dictionary objectForKey:@"name"];
            
            Organization *org = [NSEntityDescription insertNewObjectForEntityForName:@"Organization" inManagedObjectContext:managedContext];
            org.name = name;
            //org.distance = [NSString stringWithFormat:@"%.02f", distance];
            strAux = [formatter stringFromNumber:[NSNumber numberWithFloat:distance]];
            strAux = [strAux stringByReplacingOccurrencesOfString:@"$" withString:@""];
            strAux = [NSString stringWithFormat:@"%@ km", strAux];
            org.distance = strAux;
            org.photo = picture;
            org.idO = idO;
            org.origin = @"B";
            
            NSError *error;
            if (![managedContext save:&error]) {
                NSLog(@"Error Para Guardar: %@", [error localizedDescription]);
            }
        }
        //_data = arrayAux;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.data = [self getBusinessFromOrganizations:nil];
        [self.tableView reloadData];
        [self.hud hide:YES];
    });
}

-(void)getCharityOrganizations{
    
}



-(void)tappedHeaderSegment:(UISegmentedControl*)segment{
    DLog(@"Choose something");
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Loading Businesses", nil);
    switch (segment.selectedSegmentIndex) {
        case 0:
            self.organizationType = OrganizationTypeBusiness;
            break;
        case 1:
            self.organizationType = OrganizationTypeCharity;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    [self.hud hide:YES];
}

-(void)tappedSearch{
    DLog(@"Search");
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
    //myLabel.center = CGPointMake(SCREEN_WIDTH / 2 - 10, 15);
    
    if (section == 0) {
        myLabel.textColor = [UIColor altruus_darkSkyBlueColor];
    }else{
        myLabel.textColor = [UIColor altruus_bluegreyColor];
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor =[UIColor altruus_duckEggBlueColor];
    [headerView addSubview:myLabel];
    
    return headerView;
}
 

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return NSLocalizedString(@"NEAR IN LOCATION", nil);
    }else if (section == 1){
        return NSLocalizedString(@"ALL BUSINESS", nil);
    }else{
        return @"No Title";
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orgCell"];
    if(!cell){
        [tableView registerNib:[UINib nibWithNibName:@"OrgCustomCell" bundle:nil] forCellReuseIdentifier:@"orgCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"orgCell"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.masksToBounds = YES;
    
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
    NSDictionary *org;
    NSString *name, *distance, *url;
    
    if (indexPath.section == 0) {
        org = [self.data objectAtIndex:indexPath.row];
        if(![org isKindOfClass:[NSNull class]]){
            name = org[@"name"] ? org[@"name"]:@"No Name Provided";
            distance = org[@"distance"] ? org[@"distance"]:@"";
            url = org[@"image"] ? org[@"image"]:@"";
        }
    }
    ((OrgTableViewCell*)cell).screenType = ScreenTypeOrganization;
    ((OrgTableViewCell*)cell).nameLabel.text = name;
    ((OrgTableViewCell*)cell).distanceLabel.text = distance;
    [((OrgTableViewCell*)cell).orgImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PREFIJO_PHOTO_V3,url]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifGratuitos" object:nil userInfo:[self.data objectAtIndex:indexPath.row]];
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        // do something 
    }];
    
}



#pragma -mark Search bar delegate methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.text = @"";
    [searchBar resignFirstResponder];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.data = [self getBusinessFromOrganizations:searchText];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
@end

