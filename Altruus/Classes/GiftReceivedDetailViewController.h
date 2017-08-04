//
//  GiftReceivedDetailViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 30/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@protocol RedeemControllerDelegate <NSObject>

-(void)cierraPantallaRedeem;

@end


@interface GiftReceivedDetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary *giftReceived;
@property (strong, nonatomic) User *localUser;

@end
