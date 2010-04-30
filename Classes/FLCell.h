//
//  FLCell.h
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLCell;

@protocol FLCellDelegate

-(void) didSelectCell:(FLCell*)cell;
-(void) didCellTouchDown:(FLCell*)cell;

@end


@class FLItem;

@interface FLCell : UIView {

	FLItem* item;
	FLItem* itemToRemove;
	
	NSUInteger row;
	NSUInteger col;
	
	id<FLCellDelegate> delegate;
}

@property (nonatomic, assign) id<FLCellDelegate> delegate;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger col;
@property (nonatomic, retain) FLItem* item;
@property (nonatomic, retain) FLItem* itemToRemove;

-(BOOL) setItemWithColor:(UIColor*)color;
-(BOOL) haveItem;
-(void) removeItem;

@end
