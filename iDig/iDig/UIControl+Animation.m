//
//  UIControl+Animation.m
//  iDig
//
//  Created by Jay Domagala on 7/17/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import "UIControl+Animation.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIControl (Animation)

//    UIViewAnimationOptionCurveEaseInOut
//    UIViewAnimationOptionCurveEaseIn
//    UIViewAnimationOptionCurveEaseOut
//    UIViewAnimationOptionCurveLinear

- (void) moveInStraightPathTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option
{
    [UIControl animateWithDuration:secs delay:0.0 options:option animations:^{
        self.frame = CGRectMake(destination.x,destination.y, self.frame.size.width, self.frame.size.height);
        
    } completion:nil];
}

- (void) moveInCurvedPathTo:(CGPoint)destination duration:(float)secs
{
//    CGRect viewFrame = self.frame;
    CGPoint viewOrigin = self.center;
//    viewOrigin.y = viewOrigin.y + viewFrame.size.height / 2.0f;
//    viewOrigin.x = viewOrigin.x + viewFrame.size.width / 2.0f;
    
//    self.frame = viewFrame;
//    self.layer.position = viewOrigin;

    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = secs;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, destination.x, viewOrigin.y, destination.x, viewOrigin.y, destination.x, destination.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    [self.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
}

@end
