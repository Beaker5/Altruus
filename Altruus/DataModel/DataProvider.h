//
//  DataProvider.h
//  Altruus
//
//  Created by Alberto Rivera on 30/04/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"



@interface DataProvider : NSObject

+(void)deleteFriendsRecords;
+(void)deleteOrganizationsRecords;
+(NSArray*)getFriendsRecords:(NSString*)origin andPredicate:(NSString*)subString;
+(NSArray*)getOrganizationsRecords:(NSString*)origin andPredicate:(NSString*)subString;
+(NSInteger)getNumberOfFriends;

+(BOOL)networkConnected;

+(BOOL)findFriendByTelephone:(NSString*)telephone;

+(void)deleteUpdates;
+(NSArray*)getUpdatesGifts;

+(void)deleteGiftsReceived;
+(NSArray*)getGiftsReceived;
+(NSInteger)numberOfGiftsUnredeemed;

@end
