//
//  IDMenuItem.h
//  iDig
//
//  Created by Jonathan Domagala on 7/16/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+Animation.h"

@class IDSubMenuItem;

@interface IDMenuItem : UIControl

- (id)initWithFrame:(CGRect)frame numberOfSubItems:(int)count withImage:(UIImage *)image;

@property (nonatomic)           CGPoint         *centerPoint;
@property (strong, nonatomic)   UIImageView     *normalImage;
//@property (strong, nonatomic)   UIImage         *pressedImage;
@property (strong, nonatomic)   UIColor         *normalColor;
@property (strong, nonatomic)   UIColor         *pressedColor;
@property (strong, nonatomic)   UILabel         *textLabel;
@property (strong, nonatomic)   NSMutableArray  *subMenuItems;
@property (strong, nonatomic)   NSMutableArray  *subMenuPositions;
@property (nonatomic)           BOOL            isSubMenuDisplayed;

@end

@interface IDSubMenuItem : IDMenuItem

@end