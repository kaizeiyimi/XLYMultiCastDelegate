//
//  XLViewController.m
//  XLMultiCastDelegate
//
//  Created by 王凯 on 14-4-4.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLViewController.h"

#import "XLMultiCastDelegate.h"
#import "XLObjectOne.h"
#import "XLObjectTwo.h"

@interface XLViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) XLMultiCastDelegate *multiCastDelegate;
@property (nonatomic, strong) XLObjectOne *one;
@property (nonatomic, strong) XLObjectTwo *two;

@end

@implementation XLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     this demo shows how to use multiCaseDelegate to multicast event to multi delegates.
     we use the scrollView and set the delegate using multiCastDelegate.
     when you run this demo, you scroll the scrollView and take care of the console.
     */
    self.multiCastDelegate = [[XLMultiCastDelegate alloc]initWithProtocol:@protocol(UIScrollViewDelegate)];
    self.one = [XLObjectOne new];
    [self.multiCastDelegate addDelegate:self.one dispatchQueue:nil];
    self.two = [XLObjectTwo new];
    [self.multiCastDelegate addDelegate:self.two dispatchQueue:self.two.queue];
    [self.multiCastDelegate addDelegate:self dispatchQueue:nil];
    /*
     scroll will cache the result if delegate can respond to scrollViewDidScroll:, scrollViewDidZoom: and scrollView:contentSizeForZoomScale:withProposedSize: methods. so we set the delegate at last.
     */
    self.scrollView.delegate = (id<UIScrollViewDelegate>)self.multiCastDelegate;

    //here we delete one delegate after 2 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.one = nil;
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"view controller");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"end Decelerating. view controller");
}

@end
