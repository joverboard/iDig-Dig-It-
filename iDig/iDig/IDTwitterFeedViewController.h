//
//  IDTwitterFeedViewController.h
//  iDig
//
//  Created by Jonathan Domagala on 7/16/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDTwitterFeedViewController : UITableViewController
{
    NSMutableDictionary *currentRequests;
    NSArray             *statusArray;
}

@end
