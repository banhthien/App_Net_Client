//
//  UtilsManager.h
//  App_Net_Client
//
//  Created by iOSx New on 5/12/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostCore.h"
#import "define.h"
@interface UtilsManager : NSObject
+ (UtilsManager *)shared;

/**
 *  add new data from json file
 *
 *  @param dataPost              nsarray load from json
 *  @param _managedObjectContext managerobjectcontext(coredata)
 */
-(void)addObjectFromJsonToData:(NSArray *)dataPost withManagerObject:(NSManagedObjectContext*)_managedObjectContext;
@end
