//
//  CustomCellTableViewController.m
//  App_Net_Client
//
//  Created by iOSx New on 5/6/15.
//  Copyright (c) 2015 BanhThien. All rights reserved.
//

#import "MainViewController.h"
#import "PostCore.h"
#import "define.h"
#import "Reachability.h"
@interface MainViewController ()

@property (nonatomic) Reachability *internetReachability;
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

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *apdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [apdelegate managedObjectContext];
    listPost = [NSMutableArray array];
    /**
     *  check internet connection
     */
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"no internet connection,load local data");
            [self selectAll];
        }
            break;
            
        case ReachableViaWWAN:
        {
            NSLog(@"internet WWAN");
            [self refreshData];
        }
            break;
            
        case ReachableViaWiFi:
        {
            NSLog(@"internet WIFI");
            [self refreshData];
        }
            break;
            
    }
    /**
     *  add refresh header
     */
    [self addPullToRefreshHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return listPost.count;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                refreshLabel.text = @REFRESH_RELEASE;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                refreshLabel.text = @REFRESH_TEXT_PULL;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

#pragma mark - setup UI Refresh Header
/**
 *  setup UI
 */
- (void)addPullToRefreshHeader {
   
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

#pragma mark - refresh header funtion
- (void) refresh:(id)sender
{
   
    [self refreshData];
    /**
     *  Time delay is 3 seconds, sure the request load ok, load data or information done.
     */
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
        /**
         *  Released above the header
         */
        [self startLoading];
    }
}
/**
 *  start load header
 */
- (void)startLoading {
    isLoading = YES;
    
    /**
     *  show the header
     */
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text =@REFRESH_LOADING;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    /**
     *  refresh action
     */
    [self refresh];
}
/**
 *  stop load header
 */
- (void)stopLoading {
    isLoading = NO;
     [self refreshData];
    /**
     *  hide the header
     */
    [UIView animateWithDuration:2.0 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    /**
     *  reset the header
     */
    refreshLabel.text = @REFRESH_TEXT_PULL;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
   
}

- (void)refresh {
    //refesh
       [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

#pragma mark - data Funtion
/**
 *  call refresh data from json file.
 */
-(void) refreshData{
    
    //get link to json file
    NSString *string = [NSString stringWithFormat:@JSON_LINK];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        
        NSArray* dataPost = [responseObject valueForKeyPath:@DATA_NAME];
        //delete old data from coredata
        [self deleteAll];
        
        //insert data from json file to coredata
        for (NSDictionary *dict in dataPost)
        {
            PostCore *post = [NSEntityDescription insertNewObjectForEntityForName:@"PostCore" inManagedObjectContext:_managedObjectContext];
            post.postText =[dict objectForKey:@POST_KEY];
            post.time= [dict objectForKey:@TIME_KEY];
            //post.reply = [dict objectForKey:@REPLY_KEY];
            //post.report = [dict objectForKey:@REPORT_KEY];
            //post.star = [dict objectForKey:@STAR_KEY];
            NSDictionary* user = [dict valueForKey:@USER_KEY];
            if(user)
            {
                NSDictionary* avatarImage = [user valueForKey:@AVATAR_KEY];
                if (avatarImage)
                {
                    post.imageUrl = [avatarImage valueForKey:@URL_IMAGE_KEY];
                }
                post.name = [user objectForKey:@USER_NAME_KEY];
            }
                       
            if(![_managedObjectContext save:&error]){
                NSLog(@"co loi , %@", [error localizedDescription]);
            }

        }
        
        // select all data, then add to listPost
        [self selectAll];
        // sort by time
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
/**
 *  select all data from coredata
 */
-(void)selectAll
{
    NSError *error;
    NSFetchRequest *fetch= [[NSFetchRequest alloc] init];
    NSEntityDescription *entityselect=[NSEntityDescription entityForName:@"PostCore" inManagedObjectContext:_managedObjectContext];
    [fetch setEntity:entityselect];
    
    listPost= [[_managedObjectContext executeFetchRequest:fetch error:&error] mutableCopy];
}

/**
 *  delete all data from coredata
 */
-(void)deleteAll
{
    NSError *error;
    NSFetchRequest *fetch= [[NSFetchRequest alloc] init];
    NSEntityDescription *entitydelete=[NSEntityDescription entityForName:@"PostCore" inManagedObjectContext:_managedObjectContext];
    [fetch setEntity:entitydelete];
    
    
    NSMutableArray *listPostDelete =[[_managedObjectContext executeFetchRequest:fetch error:&error] mutableCopy];
    for (PostCore *Entity in listPostDelete) {
        [_managedObjectContext deleteObject:Entity];
    }
    if(![_managedObjectContext save:&error]){
        NSLog(@"co loi , %@", [error localizedDescription]);
    }

}
#pragma mark - Table

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     static NSString *cellindentifier = @"CustomCell";
    
     CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindentifier];
    if (!cell)
    {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindentifier];
    }
    
     PostCore *post = [listPost objectAtIndex:indexPath.row];
    /**
     *  custom cell funtion
     */
    [cell setupCellwithPost:post];
     return cell;
 
 }


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  set height of cell by height of post text
     */
    PostCore *post = [listPost objectAtIndex:indexPath.row];
    
    NSString *headline  = post.postText;
    UIFont *font        = [UIFont boldSystemFontOfSize:18];
    CGRect  rect        = [headline boundingRectWithSize:CGSizeMake(300, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    CGFloat height      = roundf(rect.size.height +4);
    return height+120;
    
}


@end
