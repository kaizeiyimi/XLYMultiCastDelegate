//
//  XLObjectOne.m
//  XLMultiCastDelegate
//
//  Created by 王凯 on 14-4-4.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLObjectOne.h"

@implementation XLObjectOne

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"object one");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"end Decelerating. one");
}

@end
