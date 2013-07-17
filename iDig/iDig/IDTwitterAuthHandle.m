//
//  IDTwitterAuthHandle.m
//  iDig
//
//  Created by Jay Domagala on 7/17/13.
//  Copyright (c) 2013 Jay Domagala. All rights reserved.
//

#import "IDTwitterAuthHandle.h"

@implementation IDTwitterAuthHandle

@synthesize token;

static IDTwitterAuthHandle *instance = nil;

+ (IDTwitterAuthHandle *) getInstance
{
    @synchronized(self)
    {
        if (!instance)
            instance = [IDTwitterAuthHandle new];
    }
    return instance;
}

@end
