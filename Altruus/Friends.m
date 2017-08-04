//
//  Friends.m
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import "Friends.h"

@implementation Friends




- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    
    self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
    self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
    self.friendID = [aDecoder decodeObjectForKey:@"friendID"];
    self.email = [aDecoder decodeObjectForKey:@"email"];
    self.facebookID = [aDecoder decodeObjectForKey:@"facebookID"];
    self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
    self.fullName = [aDecoder decodeObjectForKey:@"fullName"];
    
    
    
    return self;
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.firstName forKey:@"firstName"];
    [aCoder encodeObject:self.lastName forKey:@"lastName"];
    [aCoder encodeObject:self.friendID forKey:@"friendID"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.facebookID forKey:@"facebookID"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:self.fullName forKey:@"fullName"];
    
    
    
}




+ (Friends *)friendFromData:(NSDictionary *)data;
{
    /*
    Friends *friend = [Friends new];
    friend.firstName = data[@"friend"][@"first_name"];
    friend.lastName = data[@"friend"][@"last_name"];
    friend.email = data[@"friend"][@"email"];
    friend.friendID = data[@"id"];
    friend.phoneNumber = data[@"phoneNumber"];
    
    NSArray *providers = data[@"friend"][@"providers"];
    for (NSDictionary *item in providers){
        if ([item[@"provider"]isEqualToString:@"facebook"]){
            friend.facebookID = item[@"uid"];
            break;
        }
    }
    */
    Friends *friend = [Friends new];
    friend.firstName = data[@"first_name"];
    friend.lastName = data[@"last_name"];
    //friend.email = data[@"email"];
    //friend.friendID = data[@"id"];
    friend.phoneNumber = data[@"phoneNumber"];
    friend.photo = data[@"photo"];
    
    return friend;
}

+(Friends*)altruusFriendFromData:(NSDictionary *)data{
    Friends *friend = [Friends new];
    
    
    friend.firstName = data[@"firstName"];
    friend.lastName = data[@"lastName"];
    friend.friendID = data[@"id"];
    friend.phoneNumber = data[@"phone"];
    NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",data[@"facebookId"]];
    
    NSLog(@"Data: %@, fbString: %@", data, fbString);
    
    friend.imageUrl = [NSURL URLWithString:fbString];
    
    return friend;
}


#pragma -mark Getter

/*
- (NSURL *)imageUrl
{
    NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.facebookID];
     _imageUrl = [NSURL URLWithString:fbString];
    
    return _imageUrl;
}*/
 


- (NSString *)fullName
{
    _fullName = [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
    
    return _fullName;
}

@end
