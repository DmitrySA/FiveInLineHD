//
//  FLItem.m
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FLItem.h"
#import "QuartzCore/QuartzCore.h"


@implementation FLItem

@synthesize selected, image, bgColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		frame.origin.x++;
		frame.origin.y++;
		frame.size.width-=2;
		frame.size.height-=2;
		self.frame = frame;
		self.backgroundColor =  [UIColor clearColor];
		self.opaque = NO;
						
    }
    return self;
}

static UIImage* maskImage2 = nil;

-(void) createImageFromColor:(UIColor*)color
{

	UIGraphicsBeginImageContext(self.frame.size);
	CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
	CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10));
	
		
	if(!maskImage2)
		maskImage2 = [UIImage imageNamed:@"itemLight.png"];		

	[maskImage2 drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
	self.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
}
#define USE_MASK_IMAGE
#ifdef USE_MASK_IMAGE
-(void) setBgColor:(UIColor *)val
{
	[self createImageFromColor:val];
	[val retain];
	[bgColor release];
	bgColor = val;
	
}
#endif

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	[image drawInRect:rect];
}


-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	
	if(!selected)
		return;
	
	if([animationID isEqualToString:@"scaleDown"])
	{
		[UIView beginAnimations:@"scaleUp" context:nil];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationDelegate:self];
		
		self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
		[UIView commitAnimations];
		
	}
	else if ([animationID isEqualToString:@"scaleUp"])
	{
		[UIView beginAnimations:@"scaleDown" context:nil];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationDelegate:self];
		
		self.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
		[UIView commitAnimations];
		
	}
}

-(void) setSelected:(BOOL)val
{
	selected = val;
	if(selected)
	{
		[UIView beginAnimations:@"scaleDown" context:nil];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationDelegate:self];
		
		self.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
		[UIView commitAnimations];
	}
	else 
	{
		self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
	}

}

- (void)dealloc 
{
	[bgColor release];
	[image release];
    [super dealloc];
}


@end
