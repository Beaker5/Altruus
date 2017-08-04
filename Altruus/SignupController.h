//
//  SignupController.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/1/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@protocol SignUpDelegate <NSObject>

-(void)signupcontroller:(UIViewController *)controller loggedInUser:(User *)user;

@end

@interface SignupController : UIViewController
@property(nonatomic,weak)id<SignUpDelegate>delegate;
@property (strong,nonatomic) User *localUser;
@property (strong,nonatomic) NSString *userCountry;

@end
