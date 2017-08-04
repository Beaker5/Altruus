//
//  ChooseCardViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 01/04/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownPicker.h"
#import "User+Utils.h"
#import "GiftInfoViewController.h"
#import <Stripe/Stripe.h>
#import "Friends.h"

@protocol ExampleViewControllerDelegate <NSObject>

-(void)exampleViewController:(UIViewController *)controller didFinishWithMessage:(NSString *)message andLast4:(NSString*)last4;
-(void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error;

@end

@interface ChooseCardViewController : UIViewController

@property (nonatomic, strong) NSString *categoryString;

@property (nonatomic) DownPicker *pickerCard;

@property (assign) NSDictionary *gift;
@property (assign) Friends *friend;
@property (assign) User *localUser;
@property (assign) GiftingAction giftingAction;
@property (assign) NSArray *selectedFriends;

@property (assign) NSInteger indexSelected;
@property (assign, nonatomic) NSString *last4;


@end
