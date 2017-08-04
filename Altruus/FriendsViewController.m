//
//  FriendsViewController.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/7/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "FriendsViewController.h"
#import "constants.h"
#import "COFriendsCell.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface FriendsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong,nonatomic) NSArray *friendsData;
@property (assign) FriendScreen screen;
@property (strong,nonatomic) MBProgressHUD *hud;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self fetchData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setup
{
    FAKIonIcons *backIcon = [FAKIonIcons arrowLeftCIconWithSize:50];
    [backIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(50, 50)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    logoView.image = [UIImage imageNamed:kAltruusBannerLogo];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAltruusBannerLogo]];
    
    
    self.screen = FriendScreenFriends;
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(switchScreen:) forControlEvents:UIControlEventValueChanged];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.allowsSelection = NO;
    self.tableview.backgroundColor = [UIColor colorWithHexString:kColorGreen];
    self.view.backgroundColor = [UIColor colorWithHexString:kColorGreen];
    
}

- (void)switchScreen:(UISegmentedControl *)control
{
    self.friendsData = nil;
    [self.tableview reloadData];
    
    if (control.selectedSegmentIndex == 0){
        // Friends
        self.screen = FriendScreenFriends;
        DLog(@"Show friends screen");
    }
    
    else if (control.selectedSegmentIndex == 1){
        // Followers
        self.screen = FriendScreenFollowers;
        DLog(@"Show followers screen");
    }
    
    else{
        return;
    }
    
    [self fetchData];
}

- (void)fetchData
{
    //NSDictionary *testDict = @{@"first_name":@"CJ",@"last_name":@"Ogbuehi"};
    //NSDictionary *testDict1 = @{@"first_name":@"Cedric",@"last_name":@"Ogbuehi"};
    //self.friendsData = @[testDict,testDict1];
    //[self.tableview reloadData];
    //return;
    
    NSString *hudText = nil;
    if (self.screen == FriendScreenFriends){
        hudText = NSLocalizedString(@"Loading friends...", nil);
    }
    else if (self.screen == FriendScreenFollowers){
        hudText = NSLocalizedString(@"Loading followers...", nil);
    }
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = hudText;
    
    [User fetchFriendsOrFollowersOnScreen:self.screen
                                withBlock:^(BOOL success, NSArray *friends) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.hud hide:YES];
                                        
                                        if (success){
                                            self.friendsData = friends;
                                            [self.tableview reloadData];
                                            if ([friends count] == 0){
                                                NSString *error = NSLocalizedString(@"Oops", nil);
                                                NSString *message = NSLocalizedString(@"You have no friends/followers yet", nil);
                                                [self showMessageWithTitle:error andMessage:message];
                                            }
                                        }
                                        else{
                                            NSString *error = NSLocalizedString(@"Error", nil);
                                            NSString *message = NSLocalizedString(@"There was an error grabbing your friends/followers", nil);
                                            [self showMessageWithTitle:error andMessage:message];
                                        }

                                    });
                                }];
}

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma -mark Tableview Datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.friendsData count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
    if (!cell){
        [tableView registerNib:[UINib nibWithNibName:@"friendsCustomCell" bundle:nil] forCellReuseIdentifier:@"friendsCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *friend = [self.friendsData objectAtIndex:indexPath.section];
    NSString *friendName;
    NSString *fbID;
    NSArray *providers;
    if (self.screen == FriendScreenFriends){
        friendName = [NSString stringWithFormat:@"%@ %@",friend[@"friend"][@"first_name"],friend[@"friend"][@"last_name"]];
        providers = friend[@"friend"][@"providers"];
    }
    else{
        friendName = [NSString stringWithFormat:@"%@ %@",friend[@"user"][@"first_name"],friend[@"user"][@"last_name"]];
        providers = friend[@"user"][@"providers"];
    }

    
    for (NSDictionary *dict in providers){
        if ([dict[@"provider"] isEqualToString:@"facebook"]){
            fbID = dict[@"uid"];
            break;
        }
    }
    
    FAKIonIcons *personIcon = [FAKIonIcons personIconWithSize:50];
    [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *personImage = [personIcon imageWithSize:CGSizeMake(50, 50)];
    
    COFriendsCell *cell2 = (COFriendsCell *)cell;
    if (fbID){
        // build facebook profile image
        NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",fbID];
        NSURL * fbUrl = [NSURL URLWithString:fbString];
        [cell2.profilePicImageView sd_setImageWithURL:fbUrl placeholderImage:personImage options:SDWebImageRefreshCached];
        //UIImage *fbPic = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:fbUrl]];
        
    }
    else{
        cell2.profilePicImageView.image = personImage;
    }
    
    
    cell2.profileNameLabel.text = friendName;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma -mark Getter
- (NSArray *)friendsData
{
    if (!_friendsData){
        _friendsData = [NSArray array];
    }
    
    return _friendsData;
}

#pragma mark Helpers

-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
}


@end
