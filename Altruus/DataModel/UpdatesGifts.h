//
//  Updates+CoreDataProperties.h
//  
//
//  Created by Alberto Rivera on 24/07/17.
//
//

#import "UpdatesGifts.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UpdatesGifts : NSManagedObject

+ (NSFetchRequest<UpdatesGifts *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *giftName;
@property (nullable, nonatomic, copy) NSString *merchantName;
@property (nullable, nonatomic, copy) NSString *userFrom;
@property (nullable, nonatomic, copy) NSString *userTo;
@property (nullable, nonatomic, copy) NSString *picture;
@property (nullable, nonatomic, copy) NSString *pictureType;
@property (nullable, nonatomic, copy) NSString *datetime;

@end

