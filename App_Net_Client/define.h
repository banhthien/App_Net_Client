//
//  define.h
//  App_Net_Client
//
//  Created by iOSx New on 5/11/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#ifndef App_Net_Client_define_h
#define App_Net_Client_define_h
/**
 *  call utilmanager
 */
#define UTILS   [UtilsManager shared]

/**
 *  Json link
 */
#define JSON_LINK @"http://alpha-api.app.net/stream/0/posts/stream/global"

/**
 *  json key
 */
#define DATA_NAME @"data"
#define USER_KEY @"user"
#define POST_KEY @"text"
#define TIME_KEY @"created_at"
#define REPLY_KEY @"num_replies"
#define REPORT_KEY @"num_reposts"
#define STAR_KEY @"num_stars"
#define AVATAR_KEY @"avatar_image"
#define URL_IMAGE_KEY @"url"
#define USER_NAME_KEY @"username"

/**
 *  Define constant variable
 */
#define REFRESH_HEADER_HEIGHT 52.0f
#define BONUS_HEIGHT  100
#define CORNER_RADIUS 20
#endif
