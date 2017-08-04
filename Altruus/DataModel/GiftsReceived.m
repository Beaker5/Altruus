//
//  GiftsReceived+CoreDataProperties.m
//  
//
//  Created by Alberto Rivera on 24/07/17.
//
//

#import "GiftsReceived.h"

@implementation GiftsReceived 

+ (NSFetchRequest<GiftsReceived *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GiftsReceived"];
}

@dynamic senderName;
@dynamic giftName;
@dynamic merchantName;
@dynamic date;
@dynamic giftCode;
@dynamic idGift;
@dynamic senderPicture;
@dynamic status;
@dynamic image;
@dynamic price;

@end
