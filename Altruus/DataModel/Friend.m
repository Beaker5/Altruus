//
//  Friend+CoreDataProperties.m
//  
//
//  Created by Alberto Rivera on 30/04/17.
//
//

#import "Friend.h"

@implementation Friend

+ (NSFetchRequest<Friend *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
}

@dynamic fullName;
@dynamic firstName;
@dynamic lastName;
@dynamic origin;
@dynamic phoneNumber;
@dynamic photo;
@dynamic phoneWithoutLada;



@end
