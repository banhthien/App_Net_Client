//
//  CustomCellTableViewController.h
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableViewCell.h"
#import "AFNetworking.h"

@interface MainViewController : UITableViewController
@property BOOL isDragging;
@property BOOL isLoading;
@property(strong) NSDictionary *data;
@property (strong) NSMutableArray *listPost;

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@end
