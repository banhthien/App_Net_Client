//
//  UtilsManager.m
//  App_Net_Client
//
//  Created by iOSx New on 5/12/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import "UtilsManager.h"

@implementation UtilsManager

+ (UtilsManager *)shared;
{
    static dispatch_once_t once;
    static UtilsManager *_utils = nil;
    dispatch_once(&once, ^
                  {
                      
                      _utils = [[UtilsManager alloc] init];
                      
                  });
    
    return _utils;
}

/**
 *  add new data from json file
 *
 *  @param dataPost              nsarray load from json
 *  @param _managedObjectContext managerobjectcontext(coredata)
 */
-(void)addObjectFromJsonToData:(NSArray *)dataPost withManagerObject:(NSManagedObjectContext*)_managedObjectContext
{
    NSError *error;
    for (NSDictionary *dict in dataPost)
    {
        PostCore *post = [NSEntityDescription insertNewObjectForEntityForName:@"PostCore" inManagedObjectContext:_managedObjectContext];
        post.postText =[dict objectForKey:POST_KEY];
        post.time= [dict objectForKey:TIME_KEY];
        
        NSDictionary* user = [dict valueForKey:USER_KEY];
        if(user)
        {
            NSDictionary* avatarImage = [user valueForKey:AVATAR_KEY];
            if (avatarImage)
            {
                post.imageUrl = [avatarImage valueForKey:URL_IMAGE_KEY];
            }
            post.name = [user objectForKey:USER_NAME_KEY];
        }
        
        if(![_managedObjectContext save:&error]){
            NSLog(@"co loi , %@", [error localizedDescription]);
        }
        
    }
}

@end
