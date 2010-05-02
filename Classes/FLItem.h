//
//  FLItem.h
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FLItem : UIView {
@private
	BOOL selected;
	UIImage* image;
	UIColor* bgColor;
}

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) UIColor* bgColor;

@end
