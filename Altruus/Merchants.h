//
//  Merchants.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchants : NSObject

@property (strong,nonatomic) NSString *merchantID;
@property (strong,nonatomic) NSString *merchantName;
@property (strong,nonatomic) NSString *merchantDescription;
@property (strong,nonatomic) NSString *merchantLogoString;
@property (strong,nonatomic) NSString *merchantDistance;

@property (strong,nonatomic) NSString *gift1Name;
@property (strong,nonatomic) NSString *gift2Name;
@property (strong,nonatomic) NSString *gift3Name;


@end
