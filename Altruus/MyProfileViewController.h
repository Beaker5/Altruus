//
//  MyProfileViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/20/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@interface MyProfileViewController : UIViewController

@property (assign)BOOL showBackButton;

@property (strong,nonatomic) User *localUser;


@end
