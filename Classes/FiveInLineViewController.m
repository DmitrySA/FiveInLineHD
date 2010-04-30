//
//  FiveInLineViewController.m
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FiveInLineViewController.h"
#import "FLItem.h"
#import "FLCell.h"

@implementation FiveInLineViewController



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
	kRowCount = 10;
	kColCount = 12;
	
	cellWidth = 30;
	cellHeight = 30;	
	
	cellsOffsetX = 10;
	cellsOffsetY = 10;
}

- (void)dealloc 
{
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			[cells[row][col] release];
		}
	}
	
    [super dealloc];
}

-(void) saveGame
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableArray* a = [[NSMutableArray alloc] init];
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			
			FLCell* cell = cells[row][col];
			if(![cell haveItem])
			{
				[a addObject:[NSNumber numberWithInt:10]];
				continue;
			}
			
			FLItem* item = cell.item;
			
			for (NSUInteger i=0; i<8; ++i) {
				if(CGColorEqualToColor(item.backgroundColor.CGColor, colors[i].CGColor))
				{
					[a addObject:[NSNumber numberWithInt:i]];
					break;
				}
			}
		}
	}

	[userDefaults setObject:a forKey:@"field"];
	[userDefaults setObject:[NSNumber numberWithInt:score] forKey:@"score"];
	
	[userDefaults synchronize];
	[a release];
}

-(void) loadSavedGame
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSArray* a = [userDefaults objectForKey:@"field"];

	if(!a)
	{
		[self addNextItems];
		return;
	}
	
	NSNumber* scoreNum = [userDefaults objectForKey:@"score"];
	if(scoreNum)
		score = [scoreNum integerValue];
	NSUInteger index = 0;
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			NSUInteger colorIndex = [[a objectAtIndex:index] integerValue];
			
			index++;

			if(colorIndex > 7)
				continue;
			
			UIColor* color = colors[colorIndex];
			
			FLCell* cell = cells[row][col];
			
			[cell setItemWithColor:color];
			
			}
	}
	
}

-(void) swapCell:(FLCell*)cell1 withCell:(FLCell*)cell2 withId:(NSString*)animationId
{
	CGPoint c1 = cell1.center;
	CGPoint c2 = cell2.center;
	
	NSUInteger tempRow, tempCol;
	
	tempRow = cell1.row;
	tempCol = cell1.col;
	
	cells[tempRow][tempCol] = cell2;
	cells[cell2.row][cell2.col] = cell1;
	
	cell1.row = cell2.row;
	cell1.col = cell2.col;
	
	cell2.row = tempRow;
	cell2.col = tempCol;
	
	if(animationId)
	{
		[UIView beginAnimations:animationId context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5];		
	}
	
	if([cell1 haveItem])
		[self.view bringSubviewToFront:cell1];
	if([cell2 haveItem])
		[self.view bringSubviewToFront:cell2];
	cell1.center = c2;
	cell2.center = c1;
	
	if(animationId)
		[UIView commitAnimations];
}


-(void) setupCells
{
	srandom([[NSDate date] timeIntervalSince1970]);

	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			FLCell* cell = [[FLCell alloc] initWithFrame:CGRectMake(cellsOffsetX + col * cellWidth, cellsOffsetY + row * cellHeight, cellWidth, cellHeight)];
			cell.delegate = self;
			cell.row = row;
			cell.col = col;
			cells[row][col] = cell;
			[self.view addSubview:cell];
		}
	}
}

-(void) clearAllSelections
{
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			cells[row][col].item.selected = NO;
		}
	}
}

-(void) setupColors
{
	colors[0] = [UIColor redColor];
	colors[1] = [UIColor blueColor];
	colors[2] = [UIColor greenColor];
	colors[3] = [UIColor yellowColor];
	colors[4] = [UIColor orangeColor];
	colors[5] = [UIColor magentaColor];
	colors[6] = [UIColor cyanColor];
	colors[7] = [UIColor purpleColor];
}

-(void) setupNextColors
{
	srand([[NSDate date] timeIntervalSince1970 ]);
	random();
	for(NSUInteger i=0; i<3; ++i)
	{
		currentColors[i] = colors[random() % 7];
	}
}

-(FLCell*) findSelectedCell
{
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			FLCell* cell = cells[row][col];
			
			if(cell.item.selected)
				return cell;
		}
	}
	
	return nil;
	
}

-(FLCell*) findFirstCell
{
	//find first not empty cell
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			FLCell* cell = cells[row][col];
			
			if([cell haveItem])
				return cell;
		}
	}
	
	return nil;
	
}

-(BOOL) haveFreeCells
{
	NSUInteger freeCells = 0;
	
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			if(![cells[row][col] haveItem])
				freeCells++;
		}
	}
	
	return (freeCells > 2);
}

-(BOOL) clearAllCells
{
	NSUInteger freeCells = 0;
	
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			[cells[row][col] removeItem];
		}
	}
	
	return (freeCells > 2);
}

-(void) addNextItems
{
	[self configureCells];
	[self setupNextColors];
	
	NSUInteger itemCnt = 3;
	while (itemCnt) {
		
		NSUInteger randomRow = ((CGFloat)random()/(CGFloat)RAND_MAX) * kRowCount;		
		NSUInteger randomCol = ((CGFloat)random()/(CGFloat)RAND_MAX) * kColCount;
		
		FLCell* randomCell = cells[randomRow][randomCol];
		
		BOOL success = [randomCell setItemWithColor:currentColors[itemCnt-1]];
		
		if(success)
			itemCnt--;
		
	}
			
}

-(void) clearBackColsFromRow:(NSUInteger)row col:(NSUInteger)col count:(NSUInteger)cnt
{
	if(cnt >= 5)
	{
#if(TARGET_IPHONE_SIMULATOR)		
		NSLog(@"cnt=%d row=%d col=%d",cnt,row,col);
#endif		
		score += kScoreInc * cnt;
		for(NSUInteger i = 0; i < cnt; ++i)
		{
			[cells[row][col-i] removeItem];
		}
		
	}	
}
-(void) cleanupFieldCols
{
	NSUInteger cnt = 0;
	
	UIColor* itemColor = nil;
	
	// check for cols
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		cnt = 0; itemColor = nil;
		for (NSUInteger col = 0; col < kColCount; ++col) {

			FLCell* cell = cells[row][col];
			
			if(![cell haveItem] && cnt)
			{
				[self clearBackColsFromRow:row col:col-1 count:cnt];
				cnt = 0;				
				continue;
			}
			
			FLItem* item = cell.item;
			
			if(!itemColor)
			{
				itemColor = item.backgroundColor; //init color here
				cnt = 1;
			} 
			else if(CGColorEqualToColor(itemColor.CGColor, item.backgroundColor.CGColor))
			{
				if(col)
					cnt++;
			}
			else
			{
				[self clearBackColsFromRow:row col:col-1 count:cnt];
				cnt = 1;
			}
				
			itemColor = item.backgroundColor;

		} // for
		
		[self clearBackColsFromRow:row col:kColCount-1 count:cnt];
		
	} // for
}

-(void) clearBackRowsFromRow:(NSUInteger)row col:(NSUInteger)col count:(NSUInteger)cnt
{
	if(cnt >= 5)
	{
#if(TARGET_IPHONE_SIMULATOR)		
		NSLog(@"cnt=%d row=%d col=%d",cnt,row,col);
#endif		
		score += kScoreInc * cnt;
		for(NSUInteger i = 0; i < cnt; ++i)
		{
			[cells[row-i][col] removeItem];
		}
		
	}	
	else if((cnt>2) && isUseGravity && (row < kRowCount-1))
	{
		// perform gravity fall
		NSUInteger nextRow = row;
		
		FLCell* nextCell = nil;
		

		while (1) 
		{
			nextRow++;
			
			if(nextRow == kRowCount)
				break;

			nextCell = cells[nextRow][col];
				
			if([nextCell haveItem])
				break;
			
			
			// move items down
			for(NSUInteger i = 0; i < cnt; ++i)
			{
				FLCell* cell1 =  cells[nextRow-i][col];
				FLCell* cell2 =  cells[nextRow-i-1][col];
				
				if(i == (cnt-1))
					[UIView beginAnimations:@"moveDown" context:nil];
				else
					[UIView beginAnimations:@"moveDownNext" context:nil];
				
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDuration:0.3];		
				[UIView setAnimationDelay:0.2*i];
				[UIView setAnimationBeginsFromCurrentState:YES];

				[self swapCell:cell1 withCell:cell2 withId:nil];				

				[UIView commitAnimations];
			}			
						
		}
		
		
	}
}

-(void) cleanupFieldRows
{
	NSUInteger cnt = 1;
	
	UIColor* itemColor = nil;
	
	// check for cols
	for (NSUInteger col = 0; col < kColCount; ++ col) {
		cnt = 0; itemColor = nil;
		for (NSUInteger row = 0; row < kRowCount; ++row) {
			
			FLCell* cell = cells[row][col];
			
			if(![cell haveItem] && cnt)
			{
				[self clearBackRowsFromRow:row-1 col:col count:cnt];
				cnt = 0;				
				continue;
			}
			
			FLItem* item = cell.item;
			
			if(!itemColor)
			{
				itemColor = item.backgroundColor; //init color here
				cnt =1;
			} 
			else if(CGColorEqualToColor(itemColor.CGColor, item.backgroundColor.CGColor))
			{
				if(row)
					cnt++;
			}
			else
			{
				[self clearBackRowsFromRow:row-1 col:col count:cnt];
				cnt = 1;
			}
			
			itemColor = item.backgroundColor;
			
		} // for
		
		[self clearBackRowsFromRow:kRowCount-1 col:col count:cnt];
		
	} // for
}

-(void) gameOver
{
	isGameOver = YES;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Game over!" message:[NSString stringWithFormat:@"Total score %d", score]
												   delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void) updateScoreBoard
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	 
	bestScore = [ud integerForKey:@"best"];
	
	scoreLabel.text = [NSString stringWithFormat:@"%d",score];
	
	if(score > bestScore)
	{
		bestScore = score;
		[ud setInteger:bestScore forKey:@"best"];
		[ud synchronize];
	}
	
	bestLabel.text = [NSString stringWithFormat:@"%d",bestScore];
	
	
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([animationID isEqualToString:@"swapCells"])
	{
		if([self haveFreeCells])			
		{
			[self addNextItems];
			[self clearAllSelections];	
			[self cleanupFieldCols];
			[self cleanupFieldRows];
			[self updateScoreBoard];
		}
		else 
		{
			// fail here
			[self gameOver];
		}

	}
	else if([animationID isEqualToString:@"moveDown"])
	{
		[self cleanupFieldCols];
		[self cleanupFieldRows];
		[self updateScoreBoard];		
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	score = 0;
	
	isGameOver = NO;
	isUseGravity = YES;
	
	[self configureCells];
	
	[self setupCells];
	[self setupColors];

	[self loadSavedGame];
	
	FLCell* cell = [self findFirstCell];
	cell.item.selected = YES;
	
	[self updateScoreBoard];
	
    [super viewDidLoad];
}


-(void) didSelectCell:(FLCell*)cell
{
	
	if(isGameOver)
		return;
	
	BOOL cellHaveItem = [cell haveItem];
	
	if(cellHaveItem && cell.item.selected)
	{
		[self clearAllSelections];		
	}
	else if(cellHaveItem && !cell.item.selected)
	{
		[self clearAllSelections];		
		cell.item.selected = YES;
	}
	
	if(!cellHaveItem)
	{
		FLCell* selectedCell = [self findSelectedCell];
		if (selectedCell) 
		{
			[self swapCell:cell withCell:selectedCell withId:@"swapCells"];
		}
	}

	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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


-(IBAction) newGame
{
	score = 0;
	isGameOver = NO;
	[self clearAllCells];
	
	[self updateScoreBoard];
	[self addNextItems];
}

@end
