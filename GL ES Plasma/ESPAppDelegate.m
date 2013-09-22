//
//  ESPAppDelegate.m
//  GL ES Plasma
//
//  Created by Thomas Harte on 21/09/2013.
//  Copyright (c) 2013 Thomas Harte. All rights reserved.
//

#import "ESPAppDelegate.h"
#import "ESPPlasmaViewController.h"

@interface ESPAppDelegate ()

@property (nonatomic, strong) IBOutlet ESPPlasmaViewController *plasmaViewController;

@end

@implementation ESPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
	self.window.rootViewController = self.plasmaViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
