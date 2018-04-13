//
//  DataProvider.m
//  Altruus
//
//  Created by Alberto Rivera on 30/04/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "DataProvider.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "Organization.h"

@implementation DataProvider

+(void)deleteFriendsRecords{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedContext];
    
    request.includesPropertyValues = NO;
    NSError *error = nil;
    NSArray *toRemove = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *rec in toRemove) {
        [managedContext deleteObject:rec];
    }
}

+(void)deleteOrganizationsRecords{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Organization" inManagedObjectContext:managedContext];
    
    request.includesPropertyValues = NO;
    NSError *error = nil;
    NSArray *toRemove = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *rec in toRemove) {
        [managedContext deleteObject:rec];
    }
}

+(NSArray*)getFriendsRecords:(NSString*)origin andPredicate:(NSString*)subString{
    NSArray *records = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSString *predicateFormat = [[NSPredicate predicateWithFormat:@"origin == %@", origin] predicateFormat];
    if ([subString length] > 0) {
        predicateFormat = [predicateFormat stringByAppendingFormat:@" AND fullName contains [c] \"%@\" ", subString];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedContext];
    request.predicate = [NSPredicate predicateWithFormat:predicateFormat];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    records = [managedContext executeFetchRequest:request error:NULL];
    
    return records;
}

+(NSArray*)getOrganizationsRecords:(NSString*)origin andPredicate:(NSString*)subString{
    NSArray *records = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSString *predicateFormat = [[NSPredicate predicateWithFormat:@"origin == %@", origin] predicateFormat];
    if ([subString length] > 0) {
        predicateFormat = [predicateFormat stringByAppendingFormat:@" AND name contains [c] \"%@\" ", subString];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Organization" inManagedObjectContext:managedContext];
    request.predicate = [NSPredicate predicateWithFormat:predicateFormat];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    records = [managedContext executeFetchRequest:request error:NULL];
    
    return records;
}

+(BOOL)findFriendByTelephone:(NSString*)telephone{
    @try {
        AppDelegate *delegate = [AppDelegate sharedAppDelegate];
        NSManagedObjectContext *managedContext = delegate.managedObjectContext;
        
        NSString *predicateFormat = [[NSPredicate predicateWithFormat:@"origin = %@", @"T"] predicateFormat];
        predicateFormat = [predicateFormat stringByAppendingFormat:@" AND phoneWithoutLada = %@ ", telephone];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedContext];
        request.predicate = [NSPredicate predicateWithFormat:predicateFormat];
        //request.predicate = predicate;
        
        NSArray *records = [managedContext executeFetchRequest:request error:NULL];
        
        if ([records count] > 0) {
            return true;
        }else{
            return false;
        }
    } @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    } 
    return false;
    
}

+(NSInteger)getNumberOfFriends{
    NSArray *records = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSString *predicateFormat = [[NSPredicate predicateWithFormat:@"origin == %@", @"T"] predicateFormat];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedContext];
    request.predicate = [NSPredicate predicateWithFormat:predicateFormat];
    
    records = [managedContext executeFetchRequest:request error:NULL];
    
    return [records count];
}

+(BOOL)networkConnected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

+(void)deleteUpdates{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"UpdatesGifts" inManagedObjectContext:managedContext];
    
    request.includesPropertyValues = NO;
    NSError *error = nil;
    NSArray *toRemove = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *rec in toRemove) {
        [managedContext deleteObject:rec];
    }
}

+(NSArray*)getUpdatesGifts{
    NSArray *records = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"UpdatesGifts" inManagedObjectContext:managedContext];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    records = [managedContext executeFetchRequest:request error:NULL];
    
    return records;
    
}


+(void)deleteGiftsReceived{
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"GiftsReceived" inManagedObjectContext:managedContext];
    
    request.includesPropertyValues = NO;
    NSError *error = nil;
    NSArray *toRemove = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *rec in toRemove) {
        [managedContext deleteObject:rec];
    }
    
}

+(NSArray*)getGiftsReceived{
    NSArray *records = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"GiftsReceived" inManagedObjectContext:managedContext];
    
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:NO];
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObjects:sort1, sort2, nil];
    
    records = [managedContext executeFetchRequest:request error:NULL];
    
    return records;
    
}

+(NSInteger)numberOfGiftsUnredeemed{
    NSArray *records = [NSArray new];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSString *predicateFormat = [[NSPredicate predicateWithFormat:@"status = %@", @"unredeemed"] predicateFormat];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"GiftsReceived" inManagedObjectContext:managedContext];
    request.predicate = [NSPredicate predicateWithFormat:predicateFormat];
    
    records = [managedContext executeFetchRequest:request error:NULL];
    
    return [records count];
}


@end
