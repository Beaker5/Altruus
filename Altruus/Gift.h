//
//  Gift.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gift : NSObject

@property (strong,nonatomic) NSString *giftID;
@property (strong,nonatomic) NSString *giftTitle;
@property (strong,nonatomic) NSString *giftDescription;
@property (strong,nonatomic) NSString *giftPrice;
@property (strong,nonatomic) NSString *giftLocation;
@property (strong,nonatomic) NSString *giftImageString;
@property (strong,nonatomic) NSNumber *likeCount;

@end
