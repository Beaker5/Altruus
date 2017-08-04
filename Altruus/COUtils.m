//
//  COUtils.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/8/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "COUtils.h"
#import "constants.h"
#import <Tweaks/FBTweakInline.h>

@implementation COUtils

+ (void)convertButton:(UIButton *)button withText:(NSString *)text textColor:(UIColor *)textColor buttonColor:(UIColor *)buttonColor
{
    // helper method to remove images used in storyboard used for display to build buttons on the fly
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    button.layer.cornerRadius = FBTweakValue(@"UI", @"Buttons", @"Corner Radius",5.0);
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    [button setBackgroundColor:buttonColor];
    [button.titleLabel setFont:[UIFont fontWithName:kAltruusFontBold size:17]];


}

@end
