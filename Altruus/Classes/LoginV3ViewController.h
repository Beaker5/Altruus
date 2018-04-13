//
//  LoginV3ViewController.h
//  Altruus
//
//  Created by Alberto Rivera on 17/05/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DownPicker.h"

@protocol LoginDelegateV3 <NSObject>

-(void)controller:(UIViewController *)controller;

@end


@interface LoginV3ViewController : UIViewController

@property (nonatomic, weak)id<LoginDelegateV3>delegate;
@property (nonatomic) DownPicker *pickerCountry;

@end
