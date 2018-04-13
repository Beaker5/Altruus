//
//  GiftsViewController.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 6/21/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friends.h"

typedef NS_ENUM(NSInteger, GiftsType)
{
    GiftsTypePaid = 0,
    GiftsTypeFree,
    GiftsTypePopular,
};

@interface GiftsViewController : UIViewController

@property (assign) BOOL removeSplashScreenIntro; // Use so the intro doesnt go more then once
@property (assign) BOOL showBackButton;
@property (assign) BOOL comingFromNavPush;
@property (assign) BOOL dontShowSearch;

@property (strong, nonatomic) NSString *organizationID;

@property (strong,nonatomic) NSString *gifterName;
@property (strong,nonatomic) NSString *userReceivingGift;
@property (strong,nonatomic) NSString *userIDReceivingGift;
@property (strong,nonatomic) Friends *friend;

@property (assign, nonatomic) BOOL vieneDeAmigos;

@property (assign, nonatomic) NSInteger vieneDeRegalosGratis;
//0 Es la pantalla inicial, debe de cargar popup
//1 Viene de la pantalla de regalos gratis
//2 Viene del perfil del Negocio


@end
