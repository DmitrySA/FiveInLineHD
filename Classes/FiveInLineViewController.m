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
#include "SoundEngine.h"

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
	
	SoundEngine_Teardown();
	
	for (NSUInteger row = 0; row < kRowCount; ++ row) {
		for (NSUInteger col = 0; col < kColCount; ++col) {
			[cells[row][col] release];
		}
	}
	
	[scoreViewContainer release];
	[bestScoreViewContainer release];
	
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
				if(CGColorEqualToColor(item.bgColor.CGColor, colors[i].CGColor))
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
			FLCell* cell = [[FLCell alloc] initWithFrame:CGRectMake(cellsOffsetX + col * (cellWidth+1), cellsOffsetY + row * cellHeight, cellWidth, cellHeight)];
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

-(void) setupNumberImages
{
	
	for(NSUInteger i = 0; i < 10; ++i)
	{
		numbers[i] = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i]];
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
		
	if(![self haveFreeCells])
		[self gameOver];
			
}

-(void) clearBackColsFromRow:(NSUInteger)row col:(NSUInteger)col count:(NSUInteger)cnt
{
	if(cnt >= 5)
	{
#if(TARGET_IPHONE_SIMULATOR)		
		NSLog(@"cnt=%d row=%d col=%d",cnt,row,col);
#endif	
		
		isClearedInStep = YES;
		
		SoundEngine_SetListenerPosition(0, 0, 1.0f);
		SoundEngine_SetEffectPosition(fadeOutSoundId,0, 0, 0.0f);
		SoundEngine_StartEffect(fadeOutSoundId);
		
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
				itemColor = item.bgColor; //init color here
				cnt = 1;
			} 
			else if(CGColorEqualToColor(itemColor.CGColor, item.bgColor.CGColor))
			{
				if(col)
					cnt++;
			}
			else
			{
				[self clearBackColsFromRow:row col:col-1 count:cnt];
				cnt = 1;
			}
				
			itemColor = item.bgColor;

		} // for
		
		[self clearBackColsFromRow:row col:kColCount-1 count:cnt];
		
	} // for
}

-(void) allItemsDown
{
#if(TARGET_IPHONE_SIMULATOR)		
	NSLog(@"allItemsDown");
#endif		
	if(!isClearedInStep)
	{
		[self addNextItems];
	}
	
	isClearedInStep = NO;
	isDroppingDown = NO;			
}

-(void) clearBackRowsFromRow:(NSUInteger)row col:(NSUInteger)col count:(NSUInteger)cnt
{
	if(cnt >= 5)
	{
#if(TARGET_IPHONE_SIMULATOR)		
		NSLog(@"cnt=%d row=%d col=%d",cnt,row,col);
#endif		
		
		SoundEngine_SetListenerPosition(0, 0, 1.0f);
		SoundEngine_SetEffectPosition(fadeOutSoundId,0, 0, 0.0f);
		SoundEngine_StartEffect(fadeOutSoundId);
		
		score += kScoreInc * cnt;
		for(NSUInteger i = 0; i < cnt; ++i)
		{
			[cells[row-i][col] removeItem];
		}
		
		isClearedInStep = YES;
		
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
			{
				if(nextRow == row+1)
					break;
					
				[self performSelector:@selector(allItemsDown) withObject:nil afterDelay:0.3*cnt];

				break;
			}

			nextCell = cells[nextRow][col];
				
			if([nextCell haveItem])
			{
				
				if(nextRow == row+1)
					break;

				[self performSelector:@selector(allItemsDown) withObject:nil afterDelay:0.3*cnt];

				break;
			}
			
			isDroppingDown = YES;
			
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
						
		} //while
	
		
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
				itemColor = item.bgColor; //init color here
				cnt =1;
			} 
			else if(CGColorEqualToColor(itemColor.CGColor, item.bgColor.CGColor))
			{
				if(row)
					cnt++;
			}
			else
			{
				[self clearBackRowsFromRow:row-1 col:col count:cnt];
				cnt = 1;
			}
			
			itemColor = item.bgColor;
			
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
	
	//scoreLabel.text = [NSString stringWithFormat:@"%d",score];
	
	if(scoreViewContainer)
	{
		[scoreViewContainer removeFromSuperview];
	}
	
	scoreViewContainer = [[UIView alloc] initWithFrame:CGRectMake(810,125,200,28)];	
	[self.view addSubview:scoreViewContainer];
	scoreViewContainer.transform = CGAffineTransformMakeRotation(-M_PI/180*10);
	
	NSString* scoreStr = [NSString stringWithFormat:@"%d",score];
	
	for(NSUInteger pos = 0; pos < [scoreStr length]; pos++)
	{
		NSRange r = NSMakeRange(pos,1);
		NSString* pc = [scoreStr substringWithRange:r];
		NSUInteger index = [pc integerValue];
		
		UIImage* numImage = numbers[index];
		
		UIImageView* theView = [[UIImageView alloc] initWithFrame:CGRectMake(pos*20, 1, 20, 26)];
		theView.image = numImage;
		[scoreViewContainer addSubview:theView];
		[theView release];
	}
	
	[scoreViewContainer release];
	
	if(score > bestScore)
	{
		bestScore = score;
		[ud setInteger:bestScore forKey:@"best"];
		[ud synchronize];
	}
	
	
	if(bestScoreViewContainer)
	{
		[bestScoreViewContainer removeFromSuperview];
	}
	
	bestScoreViewContainer = [[UIView alloc] initWithFrame:CGRectMake(870,75,150,28)];	
	[self.view addSubview:bestScoreViewContainer];
	bestScoreViewContainer.transform = CGAffineTransformMakeRotation(-M_PI/180*10);
	
	NSString* bestScoreStr = [NSString stringWithFormat:@"%d",bestScore];
	
	for(NSUInteger pos = 0; pos < [bestScoreStr length]; pos++)
	{
		NSRange r = NSMakeRange(pos,1);
		NSString* pc = [bestScoreStr substringWithRange:r];
		NSUInteger index = [pc integerValue];
		
		UIImage* numImage = numbers[index];
		
		UIImageView* theView = [[UIImageView alloc] initWithFrame:CGRectMake(pos*20, 1, 20, 26)];
		theView.image = numImage;
		[bestScoreViewContainer addSubview:theView];
		[theView release];
	}
	
	[bestScoreViewContainer
	 release];
	
	//bestLabel.text = [NSString stringWithFormat:@"%d",bestScore];
	
	
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
#if(TARGET_IPHONE_SIMULATOR)
	NSLog(@"%@",animationID);
#endif	
	if([animationID isEqualToString:@"swapCells"])
	{
		if([self haveFreeCells])			
		{
			[self clearAllSelections];	
			[self cleanupFieldCols];
			[self cleanupFieldRows];
			
			if(!isClearedInStep && !isDroppingDown)
			{
				[self addNextItems];
			}

			isClearedInStep = NO;
			
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
	else if([animationID isEqualToString:@"moveDownNext"])
	{
		SoundEngine_SetListenerPosition(0, 0, 1.0f);
		SoundEngine_SetEffectPosition(boxDropSoundId,0, 0, 0.0f);
		SoundEngine_StartEffect(boxDropSoundId);
	}
}

-(void) loadSounds
{
	NSBundle*	bundle = [NSBundle mainBundle];	

	SoundEngine_Initialize(44100);	
	
	
	SoundEngine_LoadBackgroundMusicTrack([[bundle pathForResource:@"hopemeon1" ofType:@"mp3"] UTF8String], true, true);
	SoundEngine_StartBackgroundMusic();

	SoundEngine_LoadEffect([[bundle pathForResource:@"boxDrop" ofType:@"caf"] UTF8String], &boxDropSoundId);
	SoundEngine_LoadEffect([[bundle pathForResource:@"fadeOut" ofType:@"caf"] UTF8String], &fadeOutSoundId);
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	score = 0;
	
	isGameOver = NO;
	isUseGravity = YES;
	
	[self setupNumberImages];
	[self loadSounds];
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

-(void) didCellTouchDown:(FLCell*)cell
{
		
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
