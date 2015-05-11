//
//  CustomTableViewCell.m
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setupCellwithPost:(PostNSObject *)post
{
    nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    postLabel.text = post.post;
    nameLabel.text = post.name;
    
    //config time and show time
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:post.time];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    timeLabel.text=newDateString;
    
    // load image then fix border
    NSURL *url = [NSURL URLWithString:post.avatar];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage * image = [UIImage imageWithData:data];
    
    thumbImageView.image = image;
    thumbImageView.layer.borderWidth = 0.5f;
    thumbImageView.layer.borderColor = [UIColor grayColor].CGColor;
    thumbImageView.layer.masksToBounds = NO;
    thumbImageView.layer.cornerRadius = 20;
    thumbImageView.clipsToBounds = YES;
    
    //set text button
    [replyButton setTitle:[NSString stringWithFormat:@"%@ Replies",post.repliesNumber] forState:UIControlStateNormal];
    [reportButton setTitle:[NSString stringWithFormat:@"%@ Reports",post.reportsNumber] forState:UIControlStateNormal];
    [starButton setTitle:[NSString stringWithFormat:@"%@ Stars",post.starsNumber] forState:UIControlStateNormal];

}
@end
