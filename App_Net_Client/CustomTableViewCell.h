//
//  CustomTableViewCell.h
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCore.h"
#import "define.h"
@interface CustomTableViewCell : UITableViewCell
{
    
    __weak IBOutlet UIImageView *thumbImageView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *postLabel;
    __weak IBOutlet UILabel *timeLabel;
}

-(void)setupCellwithPost:(PostCore*)post;
@end
