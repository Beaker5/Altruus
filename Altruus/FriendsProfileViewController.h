//
//  FriendsProfileViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 7/12/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friends.h"


@interface FriendsProfileViewController : UIViewController

@property (assign) BOOL viewingMenu;
@property (assign)BOOL dontShowMenu;
@property (assign)BOOL showBackButton;


@property (strong,nonatomic) NSURL *urlPhoto;
@property (assign, nonatomic) BOOL estaFacebook;
@property (strong,nonatomic) Friends *friend;
@property (assign, nonatomic) BOOL vieneDeAmigos;

@end
