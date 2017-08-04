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

/*
@protocol NewCardViewControllerDelegate <NSObject>
-(void)newCardViewController:(NewCardViewController*)controller didFinish:(NSError*)error;
@end
*/

@interface NewCardViewController : UIViewController

//@property (nonatomic, weak) id<NewCardViewControllerDelegate> delegate;

@property (nonatomic, weak) id<ExampleViewControllerDelegate> delegate;
@property (assign) User *localUser;

@end


