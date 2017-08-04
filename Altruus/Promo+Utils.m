//
//  Promo+Utils.m
//  Altruus
//
//  Created by CJ Ogbuehi on 5/19/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "Promo+Utils.h"
#import <NSDate+BFKit.h>

@implementation Promo (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.redeemed = [NSNumber numberWithBool:YES];
    NSDate *today = [NSDate date];
    self.expires = [today dateByAddingDays:1];
    
    
    
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
    
}

+ (NSString *)name
{
    return @"Promo";
}

@end
