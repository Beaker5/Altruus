//
//  NewCardViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 02/04/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>
#import "User+Utils.h"

@class NewCardViewController;

@protocol ExampleViewControllerDelegate;

@interface NewCardViewController : UIViewController

@property (nonatomic, weak) id<ExampleViewControllerDelegate> delegate;
@property (assign) User *localUser;

@end


