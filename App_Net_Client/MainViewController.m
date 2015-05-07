//
//  CustomCellTableViewController.m
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import "MainViewController.h"
#import "Post.h"
#import "AFNetWorking.h"
@interface MainViewController ()

@property (nonatomic, strong) CustomTableViewCell *prototypeCell;

@end


@implementation MainViewController
#define REFRESH_HEADER_HEIGHT 52.0f
#define REFRESH_TEXT_PULL "Pull down to refresh..."
#define REFRESH_RELEASE "Release to refresh..."
#define REFRESH_LOADING "Loading..."

@synthesize isDragging;
@synthesize isLoading;
@synthesize refreshArrow;
@synthesize refreshControl;
@synthesize refreshHeaderView;
@synthesize refreshLabel;
@synthesize refreshSpinner;
@synthesize listPost;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addPullToRefreshHeader];
     [self refreshData];
//    [self.mainTableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return listPost.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = @REFRESH_RELEASE;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = @REFRESH_TEXT_PULL;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}
- (void)addPullToRefreshHeader {
    //setup header
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}
- (void) refresh:(id)sender
{
    // Can do some thing..
    //[self clearDataOld];
    [self refreshData];
    NSLog(@"da vao load");
    // Time delay is 3 seconds, sure the request load ok, load data or information done.
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       // Close control when over time delay
                       [self.refreshControl endRefreshing];
                   });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text =@REFRESH_LOADING;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
     [self refreshData];
    // Hide the header
    [UIView animateWithDuration:2.0 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = @REFRESH_TEXT_PULL;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
   
}

- (void)refresh {
    //refesh
       [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

#pragma Funtion
-(void) refreshData{
    NSString *string = [NSString stringWithFormat:@"http://alpha-api.app.net/stream/0/posts/stream/global"];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        listPost = [NSMutableArray array];
        self.data = (NSDictionary *)responseObject;
        NSArray* dataPost = [responseObject valueForKeyPath:@"data"];
        
        for (NSDictionary *dict in dataPost)
        {
            Post *post = [[Post alloc] init];
            
            post.post= [dict objectForKey:@"text"];
            post.time= [dict objectForKey:@"created_at"];
            post.repliesNumber = [dict objectForKey:@"num_replies"];
            post.reportsNumber = [dict objectForKey:@"num_reposts"];
            post.starsNumber = [dict objectForKey:@"num_stars"];
            
            NSDictionary* user = [dict valueForKey:@"user"];
            if(user){
                NSDictionary* avatarImage = [user valueForKey:@"avatar_image"];
                if (avatarImage) {
                    post.avatar = [avatarImage valueForKey:@"url"];
                }
                post.name = [user objectForKey:@"username"];
            }
            
            if (![self.listPost containsObject:post]) {
                [self.listPost addObject:post];
            }
        }
        
        NSArray* sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO], nil];
        [self.listPost sortUsingDescriptors: sortDescriptors];
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
    
}

#pragma Table

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     static NSString *cellindentifier = @"CustomCell";
    
     CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindentifier];
    if (!cell)
    {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindentifier];
    }
    
     Post *post = [listPost objectAtIndex:indexPath.row];
    // show text
     cell.nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
     cell.postLabel.text = post.post;
     cell.nameLabel.text = post.name;
    
    //config time and show time
     NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
     [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
     NSDate *formatterDate = [inputFormatter dateFromString:post.time];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    cell.time.text=newDateString;
    
    // load image then fix border
     NSURL *url = [NSURL URLWithString:post.avatar];
     NSData *data = [NSData dataWithContentsOfURL:url];
     UIImage * image = [UIImage imageWithData:data];
    
     cell.avatar.image = image;
     cell.avatar.layer.borderWidth = 0.5f;
     cell.avatar.layer.borderColor = [UIColor grayColor].CGColor;
     cell.avatar.layer.masksToBounds = NO;
     cell.avatar.layer.cornerRadius = 20;
     cell.avatar.clipsToBounds = YES;
    
    //set text button
    [cell.repliesButton setTitle:[NSString stringWithFormat:@"%@ Replies",post.repliesNumber] forState:UIControlStateNormal];
    [cell.reportButton setTitle:[NSString stringWithFormat:@"%@ Reports",post.reportsNumber] forState:UIControlStateNormal];
    [cell.starButton setTitle:[NSString stringWithFormat:@"%@ Stars",post.starsNumber] forState:UIControlStateNormal];
    
     return cell;
 
 }


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Post *post = [listPost objectAtIndex:indexPath.row];
    
    
    NSString *headline  = post.post;
    UIFont *font        = [UIFont boldSystemFontOfSize:18];
    CGRect  rect        = [headline boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    CGFloat height      = roundf(rect.size.height +4);
    return height+120;
    
}


@end
