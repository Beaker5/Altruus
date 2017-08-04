//
//  CODefaultsHelper.h
//  Altruus
//
//  Created by CJ Ogbuehi on 4/7/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserDefaultStore)
{
    UserDefaultStoreValue,
    UserDefaultStoreObject
};

typedef NS_ENUM(NSInteger, LinkedSocialIcon)
{
    LinkedSocialIconFacebook,
    LinkedSocialIconTwitter,
    LinkedSocialIconInstagram
};


@interface CODefaultsHelper : NSObject

-(NSUserDefaults *)defaults;
-(BOOL)isLoggedIn;
-(void)toggleLoggedIn;
-(void)removeFirstLogin;
-(BOOL)isFirstLogin;
-(BOOL)isFBUser;

-(BOOL)checkLinkedSocial:(LinkedSocialIcon)icon;

- (void)addValue:(id)value forKey:(NSString *)key withStoreType:(UserDefaultStore)type;
- (void)addBool:(BOOL)value forKey:(NSString *)key;

- (id)getValueforKey:(NSString *)key;
- (BOOL)getBoolforKey:(NSString *)key;

@end
