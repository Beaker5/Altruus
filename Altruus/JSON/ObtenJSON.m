//
//  ObtenJSON.m
//  Altruus
//
//  Created by Alberto Rivera on 16/10/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#import "ObtenJSON.h"
#import "SBJson4.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation ObtenJSON


+(NSArray*)downloadJSONfromString:(NSString*)url{
    //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //NSManagedObjectContext *managedContext = [DataProvider managedContext];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *ip_servidor = [defaults stringForKey:@"ip_servidor"];
    NSString *user = [defaults stringForKey:@"user_server"];
    NSString *pass = [defaults stringForKey:@"pass_user"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ip_servidor,url]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:30.0];
    
    //Autentificacion
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user, pass]; //usuario y password
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [self base64Encoded:basicAuthCredentials]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
    
    return array;
}

+(NSDictionary*)downloadJSONDictionaryfromString:(NSString*)url{
    //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //NSManagedObjectContext *managedContext = [DataProvider managedContext];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *ip_servidor = [defaults stringForKey:@"ip_servidor"];
    NSString *user = [defaults stringForKey:@"user_server"];
    NSString *pass = [defaults stringForKey:@"pass_user"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ip_servidor,url]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:30.0];
    
    //Autentificacion
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user, pass]; //usuario y password
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [self base64Encoded:basicAuthCredentials]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"URL: %@%@", ip_servidor,url);
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //el json se guarda en este array
    
    return dictionary;
}

+(NSString*)base64Encoded:(NSString*) string{
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}



+(void)getJSONfromURL:(NSURL *)url{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
    
}


+(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    //return json;
    NSLog(@"json %@", json);
}


@end
