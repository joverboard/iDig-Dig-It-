//
//  IDTwitterAuthHandle.h
//  iDig
//
//  Created by Jay Domagala on 7/17/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTwitterAuthHandle : NSObject
{
    NSString *token;
}

@property (nonatomic,retain)    NSString    *token;

+ (IDTwitterAuthHandle *) getInstance;

@end
