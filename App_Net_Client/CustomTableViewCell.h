//
//  CustomTableViewCell.h
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostNSObject.h"
@interface CustomTableViewCell : UITableViewCell
{
    
    __weak IBOutlet UIImageView *thumbImageView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *postLabel;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UIButton *replyButton;
    __weak IBOutlet UIButton *reportButton;
    __weak IBOutlet UIButton *starButton;
}

-(void)setupCellwithPost:(PostNSObject*)post;
@end
