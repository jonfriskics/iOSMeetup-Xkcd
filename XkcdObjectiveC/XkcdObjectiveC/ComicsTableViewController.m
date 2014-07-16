//
//  ComicsTableViewController.m
//  XkcdObjectiveC
//
//  Created by Jon Friskics on 7/13/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

#import "ComicsTableViewController.h"

#import "ComicViewController.h"

@interface ComicsTableViewController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation ComicsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self) {
        [self setupDataSource];
    }
    return self;
}

- (void)setupDataSource
{
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *currentComicURLString = @"http://xkcd.com/info.0.json";
    NSURL *currentComicURL = [NSURL URLWithString:currentComicURLString];
    NSURLRequest *currentComicURLRequest = [[NSURLRequest alloc] initWithURL:currentComicURL];
    
    NSURLSessionDataTask *getCurrentComicTask = [self.session dataTaskWithRequest:currentComicURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonParsingError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonParsingError];
        
        if(jsonResponse == nil) {
            NSLog(@"error reading json: %@",jsonParsingError.localizedDescription);
        } else {
            NSInteger rowCount = [jsonResponse[@"num"] integerValue];
            
            NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
            for(int i = 1; i <= rowCount; i++) {
                NSDictionary *comic = @{@"comicNumber": @(i)};
                [mutableArray addObject:comic];
            }
            
            NSSortDescriptor *reverseSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"comicNumber"
                                                                                    ascending:NO];
            [mutableArray sortUsingDescriptors:@[reverseSortDescriptor]];
            
            self.dataSource = [mutableArray copy];
            
            if(self.dataSource && self.tableView) {
                [self.tableView reloadData];
            }
        }
    }];
    
    [getCurrentComicTask resume];
}

/* ************************************* */
#pragma mark - View controller lifecycle
/* ************************************* */

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"comicCell"];
    
    UIView *headerView = [[UIView alloc] init];
    
    headerView.frame = CGRectMake(0,
                                  0,
                                  320,
                                  100);
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImage *headerImage = [UIImage imageNamed:@"terrible_small_logo"];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:headerImage];
    
    headerImageView.frame = CGRectMake(CGRectGetMidX(headerView.frame) - headerImage.size.width / 2,
                                       CGRectGetMidY(headerView.frame) - headerImage.size.height / 2,
                                       headerImage.size.width,
                                       headerImage.size.height);
    [headerView addSubview:headerImageView];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.frame;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


/* ************************************* */
   #pragma mark - Table view data source
/* ************************************* */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comicCell"
                                                            forIndexPath:indexPath];
    
    NSDictionary *comic = self.dataSource[indexPath.row];

    cell.textLabel.text = [comic[@"comicNumber"] stringValue];
    
    return cell;
}

/* ********************************** */
   #pragma mark - Table view delegate
/* ********************************** */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    ComicViewController *comicVC = [[ComicViewController alloc] init];

    NSDictionary *comic = self.dataSource[indexPath.row];
    comicVC.comicToLoad = comic;
    
    [self.navigationController pushViewController:comicVC
                                         animated:YES];
}

@end
