//
//  FLItem.h
//  FiveInLine
//
//  Created by Dmitry Sukhorukov on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FLItem : UIImageView {
@private
	BOOL selected;
}

@property (nonatomic, assign) BOOL selected;

@end
