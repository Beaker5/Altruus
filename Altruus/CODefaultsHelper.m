//
//  CODefaultsHelper.m
//  Altruus
//
//  Created by CJ Ogbuehi on 4/7/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "CODefaultsHelper.h"
#import "constants.h"

@implementation CODefaultsHelper

- (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

-(BOOL)isLoggedIn
{
    return [[self defaults] boolForKey:kUserLoggedIn];
}

-(void)toggleLoggedIn
{
    if ([self isLoggedIn]){
        [[self defaults] setBool:NO forKey:kUserLoggedIn];
    }
    else{
        [[self defaults] setBool:YES forKey:kUserLoggedIn];
    }
}

-(BOOL)isFirstLogin
{
    BOOL first = [[self defaults] boolForKey:kUserFirstLogin];
    if (!first){
        return YES;
    }
    else{
        return NO;
    }
}

-(void)removeFirstLogin
{
    // So when we check for first log in it returns NO
    [[self defaults] setBool:YES forKey:kUserFirstLogin];
}

-(BOOL)isFBUser
{
    return [[self defaults] boolForKey:kUserIsFacebook];
}

-(BOOL)checkLinkedSocial:(LinkedSocialIcon)icon
{
    switch (icon) {
        case LinkedSocialIconFacebook:
        {
            return [self getBoolforKey:kIconFacebook];
        }
            break;
        case LinkedSocialIconTwitter:
        {
             return [self getBoolforKey:kIconTwitter];
        }
            break;
        case LinkedSocialIconInstagram:
        {
            return [self getBoolforKey:kIconInstagram];
        }
            break;
        default:
        {
            return NO;
        }
            break;
    }
}

- (void)addValue:(id)value forKey:(NSString *)key withStoreType:(UserDefaultStore)type
{
    switch (type) {
        case UserDefaultStoreObject:
        {
            [[self defaults] setObject:value forKey:key];
        }
            break;
        case UserDefaultStoreValue:
        {
            [[self defaults] setValue:value forKey:key];
        }
            break;
            
        default:
            break;
    }
   
}

- (void)addBool:(BOOL)value forKey:(NSString *)key
{
    [[self defaults] setBool:value forKey:key];
}

- (id)getValueforKey:(NSString *)key
{
    id value = [[self defaults] valueForKey:key];
    if (!value){
        value = [[self defaults] objectForKey:key];
    }
    
    return value;
}
- (BOOL)getBoolforKey:(NSString *)key
{
    return [[self defaults] boolForKey:key];
}
@end
