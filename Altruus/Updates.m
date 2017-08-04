//
//  Updates.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "Updates.h"

@implementation Updates


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    
    self.updateDescription = [aDecoder decodeObjectForKey:@"updateDescription"];
    self.updateDate = [aDecoder decodeObjectForKey:@"updateDate"];
 
    
    
    return self;
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.updateDescription forKey:@"updateDescription"];
    [aCoder encodeObject:self.updateDate forKey:@"updateDate"];

    
}
@end
