//
//  RegisterViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 07/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "DownPicker.h"

@interface RegisterViewController : UIViewController

@property (strong,nonatomic) User *localUser;
@property (nonatomic) DownPicker *pickerCountry;

@end
