//
//  FiveInLineViewController.h
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLCell.h"

#define kScoreInc 30

@interface FiveInLineViewController : UIViewController<FLCellDelegate> {

	NSUInteger	kRowCount;
	NSUInteger	kColCount;
	CGFloat		cellsOffsetX;
	CGFloat		cellsOffsetY;
	
	FLCell* cells[20][20];
	
	BOOL isGameOver;
	BOOL isUseGravity;
	
	UIColor* colors[8];
	UIColor* currentColors[3];
	
	NSUInteger score;
	NSUInteger bestScore;
	
	CGFloat cellWidth;
	CGFloat cellHeight;
	
	UInt32			boxDropSoundId;
	UInt32			fadeOutSoundId;
	
	UIView* scoreViewContainer;
	UIView* bestScoreViewContainer;
	
	BOOL isClearedInStep;
	BOOL isDroppingDown;
	
	UIImage* numbers[10];

}

-(void) configureCells;
-(void) cleanupFieldRows;
-(void) cleanupFieldCols;
-(void) addNextItems;
-(void) setupCells;
-(void) setupColors;

-(void) saveGame;
-(void) loadSavedGame;
-(FLCell*) findFirstCell;
-(void) updateScoreBoard;

-(void) gameOver;

-(IBAction) newGame;

@end

