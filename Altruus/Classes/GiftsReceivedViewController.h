//
//  GiftsReceivedViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 30/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@interface GiftsReceivedViewController : UIViewController

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) User *localUser;

@end
