//
//  Promo.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/19/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Promo : NSManagedObject

@property (nonatomic, retain) NSNumber * donated;
@property (nonatomic, retain) NSDate * expires;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSNumber * redeemed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * shareText;
@property (nonatomic, retain) User *user;

@end
