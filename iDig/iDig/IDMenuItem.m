//
//  IDMenuItem.m
//  iDig
//
//  Created by Jonathan Domagala on 7/16/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import "IDMenuItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation IDMenuItem

- (id)initWithFrame:(CGRect)frame numberOfSubItems:(int)count withImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.normalColor = [UIColor redColor];
        self.layer.cornerRadius = 25.0;
        self.pressedColor = [UIColor darkGrayColor];
        self.backgroundColor = self.normalColor;
        
        if (image)
        {
            self.normalImage = [[UIImageView alloc] initWithImage:image];
            self.normalImage.frame = frame;
        }
        
        self.frame = frame;
        
        
        if (count)
        {
            self.subMenuItems = [[NSMutableArray alloc] init];
            self.subMenuPositions = [[NSMutableArray alloc] init];
            self.isSubMenuDisplayed = NO;
        
            int points = count;
            CGPoint center = self.center;
            double slice = 2 * M_PI / points;
            double radius = frame.size.width * 2.5;
        
            for (int i = 0; i < points; i++)
            {
                double angle = slice * i;
                int newX = (int)(center.x + radius * cos(angle));
                int newY = (int)(center.y + radius * sin(angle));
                CGPoint p = CGPointMake(newX - (frame.size.width / 4), newY - (frame.size.height / 4));
            
                IDSubMenuItem *subMenuItem = [[IDSubMenuItem alloc] initWithFrame:CGRectMake(center.x - (frame.size.width / 4), center.y - (frame.size.height / 4), frame.size.width / 2, frame.size.height / 2)];
                [self.subMenuItems addObject:subMenuItem];
                [self.subMenuPositions addObject:[NSValue valueWithCGPoint:p]];
            }
            
            [self addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addTarget:self action:@selector(menuPressed:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(menuReleased:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addObserver:self forKeyPath:@"self.frame" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"self.superview" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"self.frame"])
    {
        if (!self.normalImage.superview) {
            [self.superview insertSubview:self.normalImage aboveSubview:self];
        }
        self.normalImage.frame = self.frame;
    }
}

- (void) menuPressed:(id)sender
{
    IDMenuItem *menuItem = (IDMenuItem *)sender;
    menuItem.backgroundColor = self.pressedColor;
}

- (void) menuReleased:(id)sender
{
    IDMenuItem *menuItem = (IDMenuItem *)sender;
    menuItem.backgroundColor = self.normalColor;
}

- (void) menuTapped:(id)sender
{
    IDMenuItem *menuItem = (IDMenuItem *)sender;
    
    if (menuItem.isSubMenuDisplayed)
    {
        for (IDSubMenuItem *subMenuItem in menuItem.subMenuItems)
        {
            [((UIControl *)subMenuItem) moveInStraightPathTo:CGPointMake(menuItem.center.x - (subMenuItem.frame.size.width / 2), menuItem.center.y - (subMenuItem.frame.size.height / 2)) duration:2.0 option:UIViewAnimationOptionCurveEaseIn];
        }
        
        menuItem.isSubMenuDisplayed = NO;
    }
    else
    {
        for (IDSubMenuItem *subMenuItem in menuItem.subMenuItems)
        {
            int index = [menuItem.subMenuItems indexOfObject:subMenuItem];
            [((UIControl *)subMenuItem) moveInStraightPathTo:[menuItem.subMenuPositions[index] CGPointValue] duration:2.0 option:UIViewAnimationOptionCurveEaseInOut];
        }
        
        menuItem.isSubMenuDisplayed = YES;
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@implementation IDSubMenuItem

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame numberOfSubItems:0 withImage:nil];
    if (self)
    {
        self.normalColor = [UIColor clearColor];
        self.pressedColor = [UIColor lightGrayColor];
        self.backgroundColor = self.normalColor;
    }
    return self;
}

@end