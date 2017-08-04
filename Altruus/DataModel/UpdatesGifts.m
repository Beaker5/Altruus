//
//  Updates+CoreDataProperties.m
//  
//
//  Created by Alberto Rivera on 24/07/17.
//
//

#import "UpdatesGifts.h"

@implementation UpdatesGifts

+ (NSFetchRequest<UpdatesGifts *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"UpdatesGifts"];
}

@dynamic giftName;
@dynamic merchantName;
@dynamic userFrom;
@dynamic userTo;
@dynamic picture;
@dynamic pictureType;
@dynamic datetime;

@end
