//
//  CustomCellTableViewController.m
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import "MainViewController.h"
#import "PostNSObject.h"
#import "define.h"
@interface MainViewController ()

@property (nonatomic, strong) CustomTableViewCell *prototypeCell;

@end


@implementation MainViewController


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
    NSString *string = [NSString stringWithFormat:@JSON_LINK];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        listPost = [NSMutableArray array];
        self.data = (NSDictionary *)responseObject;
        NSArray* dataPost = [responseObject valueForKeyPath:@DATA_NAME];
        
        for (NSDictionary *dict in dataPost)
        {
            PostNSObject *post = [[PostNSObject alloc] init];
            
            post.post= [dict objectForKey:@POST_KEY];
            post.time= [dict objectForKey:@TIME_KEY];
            post.repliesNumber = [dict objectForKey:@REPLY_KEY];
            post.reportsNumber = [dict objectForKey:@REPORT_KEY];
            post.starsNumber = [dict objectForKey:@STAR_KEY];
            
            NSDictionary* user = [dict valueForKey:@USER_KEY];
            if(user){
                NSDictionary* avatarImage = [user valueForKey:@AVATAR_KEY];
                if (avatarImage) {
                    post.avatar = [avatarImage valueForKey:@URL_IMAGE_KEY];
                }
                post.name = [user objectForKey:@USER_NAME_KEY];
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
    
     PostNSObject *post = [listPost objectAtIndex:indexPath.row];
    // show text
    [cell setupCellwithPost:post];
     return cell;
 
 }


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PostNSObject *post = [listPost objectAtIndex:indexPath.row];
    
    
    NSString *headline  = post.post;
    UIFont *font        = [UIFont boldSystemFontOfSize:18];
    CGRect  rect        = [headline boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    CGFloat height      = roundf(rect.size.height +4);
    return height+120;
    
}


@end
