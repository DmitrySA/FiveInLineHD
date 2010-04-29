//
//  FiveInLineHDAppDelegate.m
//  FiveInLineHD
//
//  Created by Dmitry Sukhorukov on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FiveInLineHDAppDelegate.h"
#import "FiveInLineHDViewController.h"

@implementation FiveInLineHDAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
