//
//  LoginViewController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 3/30/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "ProfileController.h"
#import "DownPicker.h"

@protocol LoginDelegate <NSObject>

-(void)controller:(UIViewController *)controller loggedInUser:(User *)user;

@end

@interface LoginViewController : UIViewController

@property(nonatomic,weak)id<LoginDelegate>delegate;
@property (strong,nonatomic) User *localUser;
@property (nonatomic) DownPicker *pickerCountry;

@end
