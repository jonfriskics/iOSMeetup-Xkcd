//
//  AppDelegate.m
//  XkcdObjectiveC
//
//  Created by Jon Friskics on 7/13/14.
//  Copyright (c) 2014 Code School. All rights reserved.
//

#import "AppDelegate.h"

#import "ComicsTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ComicsTableViewController *comicsTVC = [[ComicsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:comicsTVC];
    
    self.window.rootViewController = navController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
