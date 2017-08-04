//
//  Merchants.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "Merchants.h"

@implementation Merchants


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    
    self.merchantID = [aDecoder decodeObjectForKey:@"merchantID"];
    self.merchantName = [aDecoder decodeObjectForKey:@"merchantName"];
    self.merchantDescription = [aDecoder decodeObjectForKey:@"merchantDescription"];
    self.merchantLogoString = [aDecoder decodeObjectForKey:@"merchantLogoString"];
    self.merchantDistance = [aDecoder decodeObjectForKey:@"merchantDistance"];
    self.gift1Name = [aDecoder decodeObjectForKey:@"gift1Name"];
    self.gift2Name = [aDecoder decodeObjectForKey:@"gift2Name"];
    self.gift3Name = [aDecoder decodeObjectForKey:@"gift3Name"];
    
    
    return self;
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.merchantID forKey:@"merchantID"];
    [aCoder encodeObject:self.merchantName forKey:@"merchantName"];
    [aCoder encodeObject:self.merchantDescription forKey:@"merchantDescription"];
    [aCoder encodeObject:self.merchantLogoString forKey:@"merchantLogoString"];
    [aCoder encodeObject:self.merchantDistance forKey:@"merchantDistance"];
    [aCoder encodeObject:self.gift1Name forKey:@"gift1Name"];
    [aCoder encodeObject:self.gift2Name forKey:@"gift2Name"];
    [aCoder encodeObject:self.gift3Name forKey:@"gift3Name"];
    
}

@end
