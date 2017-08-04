//
//  Friends.h
//  Altruus-Abundance
//
//  Created by CJ Ogbuehi on 10/25/16.
//  Copyright © 2016 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friends : NSObject

@property (strong,nonatomic) NSString *friendID;
@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;
@property (strong,nonatomic) NSString *email;
@property (strong,nonatomic) NSString *facebookID;
@property (strong,nonatomic) NSURL *imageUrl;
@property (strong,nonatomic) NSString *fullName;
@property (strong,nonatomic) NSString *phoneNumber;
@property (strong,nonatomic) NSString *photo;


+ (Friends *)friendFromData:(NSDictionary *)data;
+(Friends*)altruusFriendFromData:(NSDictionary*)data;


@end
