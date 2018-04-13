//
//  Servicios.h
//  Altruus
//
//  Created by Alberto Rivera on 19/03/17.
//  Copyright © 2017 Altruus LLC. All rights reserved.
//

#define FACEBOOK_SIGN_IN @"http://altruus.com/altruus-v2-authentication/api/v2/consumer/facebook_sign_in"
#define FACEBOOK_SIGN_UP @"http://altruus.com/altruus-v2-authentication/api/v2/consumer/facebook_sign_up"
#define FREE_GIFTS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_free_gifts"
#define PAID_GIFTS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_paid_gifts"
#define POPULAR_GIFTS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_popular_gifts"
#define GIFT_INFO @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_gift_info"
#define SEND_FREE_GIFT_FACEBOOK @"http://altruus.com/altruus-v2-services/api/v2/consumer/send_free_gift_facebook"

#define SEARCH_USER_BY_NAME @"http://altruus.com/altruus-v2-services/api/v2/consumer/search_user_by_name"

#define SEND_FREE_GIFT @"http://altruus.com/altruus-v2-services/api/v2/consumer/send_free_gift"
#define SEND_PAID_GIFT @"http://altruus.com/altruus-v2-services/api/v2/consumer/send_paid_gift"

#define UPDATES_FRIENDS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_friends_updates"
#define UPDATES_USER @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_user_updates"
#define UPDATES_COMPANY @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_company_updates"

#define USER_PROFILE @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_profile"

#define PREFIJO_PHOTO @"http://res.cloudinary.com/altruus/image/upload/c_fill,w_200,h_200,r_max/"
//#define PREFIJO_PHOTO_DETALLE @"http://res.cloudinary.com/altruus/image/upload/c_fill,h_157,w_260,r_max/"
#define PREFIJO_PHOTO_DETALLE @"http://res.cloudinary.com/altruus/image/upload/c_fill,h_200,w_300,r_max/"

#define LIST_CARDS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_payment_methods"
#define NEW_CARD @"http://altruus.com/altruus-v2-services/api/v2/consumer/create_payment_method"

#define BUSINESS_ORGANIZATIONS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_business_organizations"

#define FREE_GIFTS_MERCHANT @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_free_gifts_by_merchant"
#define PAID_GIFTS_MERCHANT @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_paid_gifts_by_merchant"
#define POPULAR_GIFTS_MERCHANT @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_popular_gifts_by_merchant"

#define RETRIEVE_USER_GIFTS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_user_gifts"
#define RETRIEVE_SENT_GIFT_INFO @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_sent_gift_info"

#define RETRIEVE_TOTAL_USERS @"http://altruus.com/altruus-v2-services/api/v2/consumer/retrieve_total_users"

#define REDEEM_GIFT @"http://altruus.com/altruus-v2-services/api/v2/consumer/redeem_gift"

#define FIND_ALTRUUS_USER @"http://altruus.com/altruus-v2-services/api/v2/consumer/find_altruus_user_by_phone"

#define VERIFY_CONTACT_PHONES @"http://altruus.com/altruus-v2-services/api/v2/consumer/verify_contact_phones"

#define STRIPE_KEY @"pk_live_6wEPvr7EvsQLKFuOWwPjRTr8";
#define STRIPE_KEY_TEST @"pk_test_mbNdkqdHkyz6d5CB9SZYlaUQ";


///////////////////////////////////////////////////////////////// VERSIÓN 3
#define SUFIJO @"http://altruus.com:8180/altruus-v3-ws-services/v3"

#define PREFIJO_PHOTO_V3 @"http://res.cloudinary.com/altruus/image/upload/c_fill,w_200,h_200,r_max/"

#define FACEBOOK_LOGIN_V3 @"http://altruus.com:8180/altruus-v3-ws-auth/v3/facebookLogin"
#define FACEBOOK_SIGN_UP_V3 @"http://altruus.com:8180/altruus-v3-ws-auth/v3/facebookSignup"

#define FREE_GIFTS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/findFree"
#define PAID_GIFTS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/findPaid"
#define POPULAR_GIFTS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/findPopulars"

#define FREE_GIFTS_MERCHANT_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/findByTypeAndMerchant"
#define PAID_GIFTS_MERCHANT_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/findByTypeAndMerchant"
#define POPULAR_GIFTS_MERCHANT_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/findPopularsByMerchant"

#define GIFT_INFO_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/gift/singleGift"

#define BUSINESS_ORGANIZATIONS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/merchant/findByType"

#define SEND_FREE_GIFT_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/sentGift/sendFreeGift"
#define SEND_PAID_GIFT_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/sentGift/sendPaidGift"

#define LIST_CARDS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/payment/findAll"
#define NEW_CARD_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/payment/create"

#define USER_PROFILE_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/user/getProfile"

#define SEARCH_USER_BY_NAME_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/user/searchByName"

#define RETRIEVE_TOTAL_USERS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/user/getCount"

#define FIND_ALTRUUS_USER_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/user/findByPhone"
#define VERIFY_CONTACT_PHONES_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/user/verifyPhoneNumbers"

#define UPDATES_USER_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/user/findUpdates"
#define RETRIEVE_USER_GIFTS_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/sentGift/findByUser"

#define REDEEM_GIFT_V3 @"http://altruus.com:8180/altruus-v3-ws-services/v3/sentGift/redeemGift"
/*
#define SUFIJO @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3"

#define PREFIJO_PHOTO_V3 @"http://res.cloudinary.com/altruus/image/upload/c_fill,w_50,h_50,r_max"

#define FACEBOOK_LOGIN_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-auth/v3/facebookLogin"
#define FACEBOOK_SIGN_UP_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-auth/v3/facebookSignup"

#define FREE_GIFTS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/findFree"
#define PAID_GIFTS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/findPaid"
#define POPULAR_GIFTS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/findPopulars"

#define FREE_GIFTS_MERCHANT_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/findByTypeAndMerchant"
#define PAID_GIFTS_MERCHANT_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/findByTypeAndMerchant"
#define POPULAR_GIFTS_MERCHANT_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/findPopularsByMerchant"

#define GIFT_INFO_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/gift/singleGift"

#define BUSINESS_ORGANIZATIONS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/merchant/findByType"

#define SEND_FREE_GIFT_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/sentGift/sendFreeGift"
#define SEND_PAID_GIFT_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/sentGift/sendPaidGift"

#define LIST_CARDS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/payment/findAll"
#define NEW_CARD_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/payment/create"

#define USER_PROFILE_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/user/getProfile"

#define SEARCH_USER_BY_NAME_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/user/searchByName"

#define RETRIEVE_TOTAL_USERS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/user/getCount"

#define FIND_ALTRUUS_USER_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/user/findByPhone"
#define VERIFY_CONTACT_PHONES_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/user/verifyPhoneNumbers"

#define UPDATES_USER_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/user/findUpdates"
#define RETRIEVE_USER_GIFTS_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/sentGift/findByUser"

#define REDEEM_GIFT_V3 @"http://ec2-18-216-12-171.us-east-2.compute.amazonaws.com:8180/altruus-v3-ws-services/v3/sentGift/redeemGift"
*/
