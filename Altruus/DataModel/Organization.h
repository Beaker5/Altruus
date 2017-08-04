//
//  Organization+CoreDataProperties.h
//  
//
//  Created by Alberto Rivera on 30/04/17.
//
//

#import "Organization.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface Organization : NSManagedObject

+ (NSFetchRequest<Organization *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *distance;
@property (nullable, nonatomic, copy) NSString *photo;
@property (nullable, nonatomic, copy) NSString *idO;
@property (nullable, nonatomic, copy) NSString *origin;

@end

NS_ASSUME_NONNULL_END
