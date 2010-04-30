//
//  FLCell.m
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FLCell.h"
#import "FLItem.h"

@implementation FLCell

@synthesize delegate;
@synthesize item, itemToRemove, row, col;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		frame.size.width --;
		frame.size.height --;
		self.frame = frame;
		self.backgroundColor = [UIColor grayColor];
		self.opaque = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc 
{
	[item release];
	[itemToRemove release];
	
    [super dealloc];
}


-(BOOL) setItemWithColor:(UIColor*)color
{
	//setsItemIfPossible
	
	if(item)
		return NO;

	
	FLItem* _item = [[FLItem alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	self.item = _item;	
	[_item release];
	
	item.backgroundColor = color;
	[self addSubview:item];
	
	return YES;
	
	
}

-(BOOL) haveItem
{
	return (item == nil)?NO:YES;
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([animationID isEqualToString:@"removing"])
	{
		[itemToRemove removeFromSuperview];
	}
}

-(void) removeItem
{
	if(!item)
		return;

	self.itemToRemove = item;
	
	[item release];
	item = nil;		

	[UIView beginAnimations:@"removing" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.3f];
	
	itemToRemove.transform = CGAffineTransformMakeScale(0.1, 1.0);
	
	[UIView commitAnimations];
	
}
#pragma mark -
#pragma mark Selection

- (void) touchesBegan: (NSSet*)touches withEvent:(UIEvent*)event 
{
}
- (void) touchesEnded: (NSSet*)touches withEvent:(UIEvent*)event 
{	
	if(delegate)
		[delegate didSelectCell:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event 
{ 
} 

@end
