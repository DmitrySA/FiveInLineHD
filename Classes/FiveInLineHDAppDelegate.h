//
//  FiveInLineHDAppDelegate.h
//  FiveInLineHD
//
//  Created by Dmitry Sukhorukov on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FiveInLineHDViewController;

@interface FiveInLineHDAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FiveInLineHDViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FiveInLineHDViewController *viewController;

@end

