//
//  OrganizationsViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/11/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "OrganizationsViewController.h"
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

@interface OrganizationsViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) User *localUser;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *segmentedControlHeight;
@property (strong, nonatomic) CLLocationManager *locationManager;



@end

@implementation OrganizationsViewController
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
    
    //COMENTADO
    // add search icon
    //FAKIonIcons *searchIcon = [FAKIonIcons iosSearchStrongIconWithSize:30];
    //[searchIcon addAttribute:NSForegroundColorAttributeName value:[UIColor altruus_darkSkyBlueColor]];
    //UIImage *searchImage = [searchIcon imageWithSize:CGSizeMake(30, 30)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedSearch)];
    
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
            
            [self getBusinessOrganizations];
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
        dict = @{@"id": org.idO,
                 @"distance": org.distance,
                 @"image": org.photo,
                 @"name": org.name};
        [organizations addObject:dict];
    }
    
    return organizations;
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
        NSLog(@"Org: %@", array);
        //NSMutableArray *arrayAux = [NSMutableArray new];
        //NSDictionary *dict;
        NSString *idO, *picture, *name;
        float distance;
        NSString *strAux;
        for (NSDictionary *dictionary in array) {
            idO = [dictionary objectForKey:@"id"];
            distance = [[dictionary objectForKey:@"distance"] floatValue];
            picture = [dictionary objectForKey:@"pictue"];
            name = [dictionary objectForKey:@"name"];
            /*
            dict = @{@"id": idO,
                     @"distance": distance,
                     @"image": picture,
                     @"name": name};
            [arrayAux addObject:dict];
             */
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


/*
-(NSArray*)data{
    if (!_data) {
        
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
        
        if(code == 200){
            NSLog(@"Organizations: %@", array);
            NSMutableArray *arrayAux = [NSMutableArray new];
            NSDictionary *dict;
            NSString *idO, *distance, *picture, *name;
            
            for (NSDictionary *dictionary in array) {
                idO = [dictionary objectForKey:@"id"];
                distance = [dictionary objectForKey:@"distance"];
                picture = [dictionary objectForKey:@"pictue"];
                name = [dictionary objectForKey:@"name"];
                
                dict = @{@"id": idO,
                         @"distance": distance,
                         @"image": picture,
                         @"name": name};
                [arrayAux addObject:dict];
            }
            _data = arrayAux;
        }
    }
    return _data;
}

*/

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
    [((OrgTableViewCell*)cell).orgImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kV2StoryboardOrganizationProfile];
    if ([controller isKindOfClass:[OrganizationProfileViewController class]]) {
        //((OrganizationProfileViewController*)controller).organizationName = @"Pepsico";
        ((OrganizationProfileViewController*)controller).friend = self.friend;
        ((OrganizationProfileViewController*)controller).vieneDeAmigos = self.vieneDeAmigos;
        ((OrganizationProfileViewController*)controller).organization = [self.data objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:controller animated:YES];
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
