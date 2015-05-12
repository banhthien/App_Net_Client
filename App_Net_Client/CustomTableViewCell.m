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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
/**
 *  setup UI off cell
 *
 *  @param post is Post model(coredata), not null
 */
-(void)setupCellwithPost:(PostCore *)post
{
    nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    postLabel.text = post.postText;
    nameLabel.text = post.name;
   
    //config time and show time
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:post.time];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    timeLabel.text=newDateString;
    
    //Load image then fix border
    NSURL *url = [NSURL URLWithString:post.imageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage * image = [UIImage imageWithData:data];
    
    thumbImageView.image = image;
    thumbImageView.layer.borderWidth = 0.5f;
    thumbImageView.layer.borderColor = [UIColor grayColor].CGColor;
    thumbImageView.layer.masksToBounds = NO;
    thumbImageView.layer.cornerRadius = CORNER_RADIUS;
    thumbImageView.clipsToBounds = YES;


}
@end
