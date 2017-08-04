//
//  User.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/12/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Promo;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fbID;
@property (nonatomic, retain) NSNumber * fbUser;
@property (nonatomic, retain) NSNumber * firstLogin;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSNumber * linkedFB;
@property (nonatomic, retain) NSNumber * linkedIG;
@property (nonatomic, retain) NSNumber * linkedTW;
@property (nonatomic, retain) NSNumber * loggedIn;
@property (nonatomic, retain) NSData * picData;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * twUsername;
@property (nonatomic, retain) NSString * twID;
@property (nonatomic, retain) NSString * twToken;
@property (nonatomic, retain) NSString * fbToken;
@property (nonatomic, retain) NSNumber * fbPostPermission;
@property (nonatomic, retain) NSNumber * fbProviderID;
@property (nonatomic, retain) NSNumber * twProviderID;
@property (nonatomic, retain) NSOrderedSet *promos;
@property (nonatomic, retain) NSString *pushID;
@property (nonatomic, retain) NSString *userIDAltruus;
@property (nonatomic, retain) NSString *fbIDAltruus;
@property (nonatomic, retain) NSString *tokenAltruus;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)insertObject:(Promo *)value inPromosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPromosAtIndex:(NSUInteger)idx;
- (void)insertPromos:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePromosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPromosAtIndex:(NSUInteger)idx withObject:(Promo *)value;
- (void)replacePromosAtIndexes:(NSIndexSet *)indexes withPromos:(NSArray *)values;
- (void)addPromosObject:(Promo *)value;
- (void)removePromosObject:(Promo *)value;
- (void)addPromos:(NSOrderedSet *)values;
- (void)removePromos:(NSOrderedSet *)values;
@end
