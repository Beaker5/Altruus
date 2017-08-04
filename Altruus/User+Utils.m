//
//  User+Utils.m
//  Altruus
//
//  Created by CJ Ogbuehi on 5/5/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "User+Utils.h"
#import "constants.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import <AFHTTPRequestOperationManager.h>

@implementation User (Utils)


- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.linkedFB = [NSNumber numberWithBool:NO];
    self.linkedIG = [NSNumber numberWithBool:NO];
    self.linkedTW = [NSNumber numberWithBool:NO];
    self.firstLogin = [NSNumber numberWithBool:YES];
    self.fbPostPermission = [NSNumber numberWithBool:NO];
    self.fbUser = [NSNumber numberWithBool:NO];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
    
}

+ (NSString *)name
{
    return @"User";
}

- (NSString *)localUsername
{
    if (self.username){
        return self.username;
    }
    else if(self.firstname && self.lastname){
        return [NSString stringWithFormat:@"%@ %@",self.firstname, self.lastname];
    }
    else{
        return NSLocalizedString(@"No Username Set", nil);
    }
}


- (NSURL *)imageUrl
{
    NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.fbID];
    return [NSURL URLWithString:fbString];
  
}


+ (User *)createLocalUserInContext:(NSManagedObjectContext *)context
{
    User *user = [NSEntityDescription insertNewObjectForEntityForName:[User name] inManagedObjectContext:context];
    NSError *e;
    if (![user.managedObjectContext save:&e]){
        DLog(@"Unresolved error %@, %@", e, [e userInfo]);
        abort();
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *objectID = [[user objectID] URIRepresentation];
    [defaults setURL:objectID forKey:kAltruusLocalUser];
    
    
    

    return user;
    
}

+(NSInteger)esPrimerLogueo:(NSManagedObjectContext*)context{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result.count == 0) {
        return 0;
    }else{
        User *usuario = [result objectAtIndex:0];
        NSLog(@"Logueo User: %@", usuario.firstLogin);
        return usuario.firstLogin.integerValue;
    }
}

+(void)eliminaUsuario:(NSManagedObjectContext*)context{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [request setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *usuarios = [context executeFetchRequest:request error:&error];
    
    for (NSManagedObject *rec in usuarios) {
        [context deleteObject:rec];
    }
}

+(User*)getLocalUserSesion:(NSManagedObjectContext*)managedContext{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedContext];
    /*
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"email", @"fbID", @"fbIDAltruus", @"fbProviderID", @"fbToken", @"fbUser", @"firstLogin", @"firstname", @"lastname", @"loggedIn", @"picData", @"pushID", @"tokenAltruus", @"userID", @"userIDAltruus", @"username"]];
     */
    NSError *error = nil;
    NSArray *result = [managedContext executeFetchRequest:request error:&error];
    if ([result count] > 0) {
        User *usuario = [result objectAtIndex:0];
        //NSLog(@"Usuario: %@", usuario);
        return usuario;
    }
    return nil;
    /*
    NSDictionary *dict = [result objectAtIndex:0];
    User *usuario = [User new];
    usuario.email = [dict objectForKey:@"email"];
    usuario.fbID = [dict objectForKey:@"fbID"];
    usuario.fbIDAltruus = [dict objectForKey:@"fbIDAltruus"];
    usuario.fbProviderID = [dict objectForKey:@"fbProviderID"];
    usuario.fbToken = [dict objectForKey:@"fbToken"];
    usuario.fbUser = [dict objectForKey:@"fbUser"];
    usuario.firstLogin = [dict objectForKey:@"firstLogin"];
    usuario.firstname = [dict objectForKey:@"firstname"];
    usuario.lastname = [dict objectForKey:@"lastname"];
    usuario.loggedIn = [dict objectForKey:@"loggedIn"];
    usuario.picData = [dict objectForKey:@"picData"];
    usuario.pushID = [dict objectForKey:@"pushID"];
    usuario.tokenAltruus = [dict objectForKey:@"tokenAltruus"];
    usuario.userID = [dict objectForKey:@"userID"];
    usuario.userIDAltruus = [dict objectForKey:@"userIDAltruus"];
    usuario.username = [dict objectForKey:@"username"];
    NSLog(@"-------------------------------------------------------------------------------------------------");
    NSLog(@"Diccionario: %@", result);
    NSLog(@"Usuario: %@", usuario);
    NSLog(@"-------------------------------------------------------------------------------------------------");
    */
}

+ (User *)getLocalUserInContext:(NSManagedObjectContext *)context
{
    // hold value in constants
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *objectURL = [defaults URLForKey:kAltruusLocalUser];
    NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURL];
    NSError *e;
    NSManagedObject *userObject = [context existingObjectWithID:objectID error:&e];
    if (!userObject){
        DLog(@"error %@",e);
        abort();
    }
    
    return (User *)userObject;
}



// API

+ (void)getUserInfoWithBlock:(PromoBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    [client GET:APICurrentUserString parameters:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            if (block){
                block(YES,responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (block){
                block(NO,nil);
            }
        }];
    
}
+ (void)registerWithParams:(NSDictionary *)params
                     block:(LoginBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APIRegisterString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             
             id success = responseObject[@"success"];
             NSString *userToken = responseObject[@"user"][@"authentication_token"];
             if ((BOOL)success && block){
                 block(APIRequestStatusSuccess,userToken,responseObject);
             }
             else{
                 block(APIRequestStatusFail,nil,nil);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             NSLog(@"Erroooor: %@", error.localizedDescription);
             DLog(@"%@",error.localizedDescription);
             
             if (block){
                 block(APIRequestStatusFail,nil,nil);
             }
         }];
    

}




+ (void)submitFeedbackWithParams:(NSDictionary *)params
                           block:(FeedbackBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APIFeedbackString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             DLog(@"%@",responseObject);
             NSString *merchant_name = responseObject[@"merchant_name"];
             if (block){
                 block(APIRequestStatusSuccess,merchant_name);
             }
             
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             
             if (block){
                 block(APIRequestStatusFail,nil);
             }
         }];
}

+ (void)fetchUsersGiftsWithBlock:(PromoListBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client GET:APIUserGiftsString parameters:@{}
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            if (block){
                
                block(APIRequestStatusSuccess,responseObject[@"gifts"]);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(APIRequestStatusFail,nil);
            }
        }];
}

+ (void)fetchMerchantGiftsWithParams:(NSDictionary *)params
                               block:(MerchantPromoBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APIMerchantGiftScanString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             NSString *merchant = responseObject[@"merchant_name"];
             NSNumber *friendsCount = responseObject[@"friends"];
             if (block){
                 block(APIRequestStatusSuccess,responseObject[@"promotions"],merchant,friendsCount);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail,nil,nil,nil);
             }
         }];
}

+ (void)shareMerchantGiftsWithParams:(NSDictionary *)params
                               block:(PromoBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];

    [client POST:APIMerchantGiftShareString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 block(APIRequestStatusSuccess,responseObject);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail,nil);
             }

         }];
}

+ (void)fetchMerchantRedeemsWithParams:(NSDictionary *)params
                                 block:(MerchantPromoBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    NSString *url = APIRedeemScanString;
  
    [client POST:url parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             NSString *merchant = responseObject[@"merchant_name"];
             //NSNumber *friendsCount = responseObject[@"friends"];
             if (block){
                 block(APIRequestStatusSuccess,responseObject[@"gifts"],merchant,nil);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail,nil,nil,nil);
             }
         }];
}

+ (void)redeemMerchantRedeemsWithParams:(NSDictionary *)params
                                  block:(PromoBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APIRedeemConfirmString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 block(APIRequestStatusSuccess,responseObject);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail,nil);
             }
         }];
}

+ (void)fetchAllRedeemsWithBlock:(PromoListBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];

    [client GET:APIRedemptionString parameters:@{}
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            if (block){
                block(APIRequestStatusSuccess,responseObject[@"redemptions"]);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(APIRequestStatusFail,nil);
            }
        }];
}

+ (void)socialShareWithParams:(NSDictionary *)params
                        block:(NoDataBlock2)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];

    [client POST:APISocialShareString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 block(APIRequestStatusSuccess);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail);
             }
         }];
    
}
/*
+ (void)fetchGiftDetailsWithParams:(NSDictionary *)params
                             block:(PromoBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client GET:APIQRRetrieveString parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            if (block){
                block(APIRequestStatusSuccess,responseObject);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(APIRequestStatusFail,nil);
            }
            
        }];
    

}
 */

+ (void)shareGiftWithParams:(NSDictionary *)params
                      block:(NoDataBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:nil parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 block(APIRequestStatusSuccess);
             }
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail);
             }
             
         }];

}

+ (void)linkProvider:(APIProvider)provider
          withParams:(NSDictionary *)params
               block:(ProviderBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    NSString *social;
    if (provider == APIProviderFacebook){
        social = @"facebook";
    }
    else if (provider == APIProviderTwitter){
        social = @"twitter";
    }
    else if (provider == APIProvideriOS){
        social = @"ios";
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",APIProvidersString,social];
    [client POST:url parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 //int providerID = (int)responseObject[@"provider"][@"id"];
                 //NSNumber *pID = [NSNumber numberWithInt:providerID];
                 block(YES);
             }
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(NO);
             }

         }];
    
}

+ (void)deleteProvider:(APIProvider)provider
                 block:(NoDataBlock)block
{
    NSString *providerString;
    if (provider == APIProviderFacebook){
        providerString = @"facebook";
    }
    else if (provider == APIProviderTwitter){
        providerString = @"twitter";
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",APIProvidersString,providerString];
    
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    [client DELETE:url parameters:@{}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               [client stopNetworkActivity];
               if (block){
                   block(YES);
               }
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               [client stopNetworkActivity];
               DLog(@"%@",error.localizedDescription);
               if (block){
                   block(NO);
               }
           }];
    
}

+ (void)getProvidersWithBlock:(ProvidersSocialBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client GET:APIProvidersString parameters:@{}
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            BOOL fbYes = NO;
            BOOL twYes = NO;
            NSString *fbToken;
            NSString *twToken;
            NSArray *providers = responseObject[@"providers"];
            for (NSDictionary *dict in providers){
                if ([dict[@"provider"] isEqualToString:@"facebook"]){
                    fbYes = YES;
                    fbToken = dict[@"token"];
                }
                
                if ([dict[@"provider"] isEqualToString:@"twitter"]){
                    twYes = YES;
                    twToken = dict[@"token"];
                }
            }
            
            if (block){
                block(fbYes,twYes,fbToken,twToken);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(NO,NO,nil,nil);
            }

        }];
}

+ (void)fetchFriendsOrFollowersOnScreen:(FriendScreen)screen
                              withBlock:(FriendsBlock)block;
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    NSString *url = nil;
    NSString *paramName = nil;
    if (screen == FriendScreenFriends){
        url = APIFriendsString;
        paramName = @"friends";
    }
    else if (screen == FriendScreenFollowers)
    {
        url = APIFollowersString;
        paramName = @"followers";
    }
    
    [client GET:url parameters:@{}
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            if (block){
                block(YES,responseObject[paramName]);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(NO,nil);
            }
        }];
}

+ (void)createFriendshipWithParams:(NSDictionary *)params
                             block:(NoDataBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    [client POST:APICreateFriendsString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             //
            [client stopNetworkActivity];
             if (block){
                 block(YES);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             //
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             if (block){
                 block(NO);
             }
         }];
}
+ (void)sendErrorToServerWithParams:(NSDictionary *)params
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APIErrorsString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             DLog(@"Posted error message");
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"Error posting error message");
         }];
}
/*
 [client POST:postString parameters:params
 success:^(NSURLSessionDataTask *task, id responseObject) {
 [client stopNetworkActivity];
 
 if (block){
 block(APIRequestStatusSuccess,responseObject);
 }
 
 } failure:^(NSURLSessionDataTask *task, NSError *error) {
 [client stopNetworkActivity];
 
 if (block){
 block(APIRequestStatusFail,nil);
 }
 
 }];
*/

// Helpers

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}





@end
