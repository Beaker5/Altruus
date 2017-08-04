//
//  GiftReceivedViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 08/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GiftReceivedViewController;

@protocol  RedeemControllerDelegate;

@interface GiftReceivedViewController : UIViewController

@property (nonatomic, strong) NSDictionary *gift;
@property (nonatomic, weak) id<RedeemControllerDelegate> delegate;

@end
