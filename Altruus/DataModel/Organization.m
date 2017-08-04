//
//  Organization+CoreDataProperties.m
//  
//
//  Created by Alberto Rivera on 30/04/17.
//
//

#import "Organization.h"

@implementation Organization 

+ (NSFetchRequest<Organization *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Organization"];
}

@dynamic name;
@dynamic distance;
@dynamic photo;
@dynamic idO;
@dynamic origin;

@end
