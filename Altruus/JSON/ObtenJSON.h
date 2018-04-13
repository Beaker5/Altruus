//
//  ObtenJSON.h
//  Altruus
//
//  Created by Alberto Rivera on 16/10/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObtenJSON : NSObject

+(NSArray*)downloadJSONfromString:(NSString*)url;
+(NSDictionary*)downloadJSONDictionaryfromString:(NSString*)url;
+(void)getJSONfromURL:(NSURL*)url;

@end
