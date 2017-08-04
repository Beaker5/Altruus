//
//  GiftsReceived+CoreDataProperties.h
//  
//
//  Created by Alberto Rivera on 24/07/17.
//
//

#import "GiftsReceived.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GiftsReceived : NSManagedObject

+ (NSFetchRequest<GiftsReceived *> *_Nullable)fetchRequest;


@property (nullable, nonatomic, copy) NSString *senderName;
@property (nullable, nonatomic, copy) NSString *giftName;
@property (nullable, nonatomic, copy) NSString *merchantName;
@property (nullable, nonatomic, copy) NSString *date;
@property (nullable, nonatomic, copy) NSString *giftCode;
@property (nullable, nonatomic, copy) NSString *idGift;
@property (nullable, nonatomic, copy) NSString *senderPicture;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *image;
@property (nullable, nonatomic, copy) NSString *price;

@end


