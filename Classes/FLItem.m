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

@synthesize selected;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		frame.origin.x++;
		frame.origin.y++;
		frame.size.width-=2;
		frame.size.height-=2;
		self.frame = frame;
		self.opaque = YES;
						
    }
    return self;
}

static UIImage* maskImage1 = nil;
static UIImage* maskImage2 = nil;

-(UIImage*) createImageFromColor:(UIColor*)color
{
	CGRect frame = self.frame;
	
	UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]; 
	UIImageView* theView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	theView.backgroundColor = color;
	
	{
		if(!maskImage1)
			maskImage1 = [UIImage imageNamed:@"itemMask.png"];
		
		CALayer* maskLayer = [CALayer layer];
		maskLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
		maskLayer.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
		[maskLayer setContents:(id)maskImage1.CGImage];
		self.layer.mask = maskLayer;			
	}
	
	{
		
		if(!maskImage2)
			maskImage2 = [UIImage imageNamed:@"itemLight.png"];		
		theView.image = maskImage2;			
	}
	
	[container addSubview:theView];
	
	UIGraphicsBeginImageContext(self.bounds.size);
	[container.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[theView release];
	[container release];
	
	return viewImage;
	
}
#define USE_MASK_IMAGE
#ifdef USE_MASK_IMAGE
-(void) setBackgroundColor:(UIColor *)val
{
	self.image = [self createImageFromColor:val];
	[super setBackgroundColor:val];
}
#endif
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    [super dealloc];
}


@end
