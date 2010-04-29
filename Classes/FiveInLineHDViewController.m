//
//  FiveInLineHDViewController.m
//  FiveInLineHD
//
//  Created by Dmitry Sukhorukov on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
#import "FiveInLineHDViewController.h"
#import "FLCell.h"
#import "FLItem.h"

@implementation FiveInLineHDViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


-(void) configureCells
{
	kRowCount = 12;
	kColCount = 12;
	
	cellWidth = 61;
	cellHeight = 61;	

	cellsOffsetX = 15;
	cellsOffsetY = 15;

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hdbg.png"]];
	[super viewDidLoad];
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
