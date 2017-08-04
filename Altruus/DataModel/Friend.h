//
//  Friend+CoreDataProperties.h
//  
//
//  Created by Alberto Rivera on 30/04/17.
//
//

#import "Friend.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface Friend : NSManagedObject

+ (NSFetchRequest<Friend *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *fullName;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *phoneNumber;
@property (nullable, nonatomic, copy) NSString *photo;
@property (nullable, nonatomic, copy) NSString *origin;
@property (nullable, nonatomic, copy) NSString *phoneWithoutLada;

@end

NS_ASSUME_NONNULL_END
