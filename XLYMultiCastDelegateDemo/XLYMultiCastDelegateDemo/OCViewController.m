//
//  OCViewController.m
//  XLMultiCastDelegate
//
//  Created by kaizei on 14/9/26.
//  Copyright (c) 2014年 kaizei. All rights reserved.
//

#import "OCViewController.h"

#import "XLYMultiCastDelegate.h"
#import "SimpleProtocol.h"

@interface OCViewController () <SimpleProtocol>

@property (nonatomic, strong) id<SimpleProtocol> multiDelegate;

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XLYMultiCastDelegate *multiDelegate = [[XLYMultiCastDelegate alloc] initWithConformingProtocol:@protocol(SimpleProtocol)];
    [multiDelegate addDelegate:self dispatchQueue:dispatch_get_main_queue()];
    self.multiDelegate = (id<SimpleProtocol>)multiDelegate;
    //check will get YES
    __unused BOOL result = [self.multiDelegate conformsToProtocol:@protocol(SimpleProtocol)];
}

- (void)dealloc
{
    NSLog(@"oc viewController dealloc");
}

- (IBAction)buttonClicked:(UIButton *)button
{
    [self.multiDelegate someOptionalMethod];
    //you should not use multiCastDelegate for method which has a return value.
    __unused id result = [self.multiDelegate someRequiredMethod:button];
}

#pragma mark - simple protocol
- (void)someOptionalMethod
{
    NSLog(@"OC viewController optional method.");
}

- (id)someRequiredMethod:(id)object
{
    NSLog(@"OC viewController requierd method. %@", object);
    return object;
}

@end
