//
//  Gift.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "Gift.h"

@implementation Gift

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    
    self.giftID = [aDecoder decodeObjectForKey:@"giftID"];
    self.giftTitle = [aDecoder decodeObjectForKey:@"giftTitle"];
    self.giftDescription = [aDecoder decodeObjectForKey:@"giftDescription"];
    self.giftPrice = [aDecoder decodeObjectForKey:@"giftPrice"];
    self.giftLocation = [aDecoder decodeObjectForKey:@"giftLocation"];
    self.giftImageString = [aDecoder decodeObjectForKey:@"giftImageString"];
    self.likeCount = [aDecoder decodeObjectForKey:@"likeCOunt"];
   
    
    return self;
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.giftID forKey:@"giftID"];
    [aCoder encodeObject:self.giftTitle forKey:@"giftTitle"];
    [aCoder encodeObject:self.giftDescription forKey:@"giftDescription"];
    [aCoder encodeObject:self.giftPrice forKey:@"giftPrice"];
    [aCoder encodeObject:self.giftLocation forKey:@"giftLocation"];
    [aCoder encodeObject:self.giftImageString forKey:@"giftImageString"];
    [aCoder encodeObject:self.likeCount forKey:@"likeCount"];

}

@end
