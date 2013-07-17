//
//  UIControl+Animation.h
//  iDig
//
//  Created by Jay Domagala on 7/17/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Animation)

- (void) moveInStraightPathTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option;
- (void) moveInCurvedPathTo:(CGPoint)destination duration:(float)secs;

@end
