//
//  ComicViewController.m
//  XkcdObjectiveC
//
//  Created by Jon Friskics on 7/13/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

#import "ComicViewController.h"

@interface ComicViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSDictionary *comicJsonInfo;
@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (strong, nonatomic) UIImageView *imageViewInScrollView;
@property (strong, nonatomic) UILabel *comicTitle;

@end

@implementation ComicViewController

/* ****************************************** */
#pragma mark - View controller initialization
/* ****************************************** */

- (id)init {
    self = [super init];
    if(self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

/* ************************************* */
#pragma mark - View controller lifecycle
/* ************************************* */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageScrollView = [[UIScrollView alloc] init];
    self.imageScrollView.delegate = self;
    self.imageScrollView.maximumZoomScale = 5.0f;
    self.imageScrollView.backgroundColor = [UIColor lightGrayColor];
    
    self.imageViewInScrollView = [[UIImageView alloc] init];
    self.imageViewInScrollView.userInteractionEnabled = YES;
    
    [self.imageScrollView addSubview:self.imageViewInScrollView];
    [self.view addSubview:self.imageScrollView];
    
    self.comicTitle = [[UILabel alloc] init];
    self.comicTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.comicTitle];
    
    UILongPressGestureRecognizer *longPressOnImage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongPressed:)];
    [self.imageViewInScrollView addGestureRecognizer:longPressOnImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSString *comicNumber = [self.comicToLoad[@"comicNumber"] stringValue];
    NSString *comicURLString = [NSString stringWithFormat:@"http://xkcd.com/%@/info.0.json",comicNumber];
    NSURL *comicURL = [NSURL URLWithString:comicURLString];
    
    NSURLRequest *comicURLRequest = [[NSURLRequest alloc] initWithURL:comicURL];
    
    NSURLSessionDataTask *getComic = [self.session dataTaskWithRequest:comicURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonParsingError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonParsingError];
        
        if(jsonResponse == nil) {
            NSLog(@"error reading json: %@",jsonParsingError.localizedDescription);
        } else {
            self.comicJsonInfo = jsonResponse;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = [NSString stringWithFormat:@"%@-%@-%@",
                              jsonResponse[@"month"],
                              jsonResponse[@"day"],
                              jsonResponse[@"year"]];
            });
            
            [self displayComic];
        }
        
    }];
    
    [getComic resume];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if(self.imageViewInScrollView.frame.size.height > 400) {
        self.imageScrollView.frame = CGRectMake(0,
                                                self.topLayoutGuide.length,
                                                320,
                                                400);
    } else {
        self.imageScrollView.frame = CGRectMake(0,
                                                self.topLayoutGuide.length,
                                                320,
                                                self.imageViewInScrollView.frame.size.height);
    }
    self.imageScrollView.contentSize = CGSizeMake(self.imageViewInScrollView.frame.size.width,
                                                  self.imageViewInScrollView.frame.size.height);
    
    self.comicTitle.frame = CGRectMake(0,
                                       CGRectGetMaxY(self.imageScrollView.frame),
                                       320,
                                       30);
}

/* **************************************** */
#pragma mark - Scroll view delegate methods
/* **************************************** */

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageViewInScrollView;
}

/* ************************** */
#pragma mark - Action methods
/* ************************** */

- (void)displayComic {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.comicTitle.text = self.comicJsonInfo[@"safe_title"];
        [self.comicTitle sizeToFit];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:self.comicJsonInfo[@"img"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        CGSize size = img.size;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageViewInScrollView.image = img;
            self.imageViewInScrollView.contentMode = UIViewContentModeScaleAspectFit;

            CGFloat heightToSet;
            if(size.height > 400) {
                heightToSet = 400;
            } else {
                heightToSet = size.height;
            }
            
            self.imageViewInScrollView.frame = CGRectMake(0, 0, 320, heightToSet);

            [self.view setNeedsLayout];
        });
    });
}

- (void)imageLongPressed:(UILongPressGestureRecognizer *)gesture {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:self.comicJsonInfo[@"alt"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.delegate = self;
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        [alertView show];
    }
}

@end
