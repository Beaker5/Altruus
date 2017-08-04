//
//  ReceivedDeliveredViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 04/06/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@interface ReceivedDeliveredViewController : UIViewController

@property (strong, nonatomic) NSString *screenType;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) User *localUser;

@end
