//
//  XLObjectTwo.m
//  XLMultiCastDelegate
//
//  Created by 王凯 on 14-4-4.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLObjectTwo.h"

@implementation XLObjectTwo

- (id)init
{
    if (self = [super init]) {
        self.queue = dispatch_queue_create("object two", NULL);
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"object two");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"end Decelerating. two");
}

@end
