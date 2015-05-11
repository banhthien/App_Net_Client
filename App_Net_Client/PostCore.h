//
//  PostCore.h
//  App_Net_Client
//
//  Created by iOSx New on 5/11/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostCore : NSManagedObject

@property (nonatomic, retain) NSString * postText;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * reply;
@property (nonatomic, retain) NSString * report;
@property (nonatomic, retain) NSString * star;
@property (nonatomic, retain) NSString * time;

@end
