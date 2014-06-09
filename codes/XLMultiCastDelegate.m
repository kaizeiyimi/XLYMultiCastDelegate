//
//  XLMultiCastDelegate.m
//  testWhat
//
//  Created by 王凯 on 14-3-24.
//  Copyright (c) 2014年 王凯. All rights reserved.
//

#import "XLMultiCastDelegate.h"

#pragma mark - XLDelegateNode
@interface XLDelegateNode : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (instancetype)initWithDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue;

@end


@implementation XLDelegateNode

- (instancetype)initWithDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        self.delegate = delegate;
        if (queue) {
            self.dispatchQueue = queue;
        } else {
            self.dispatchQueue = dispatch_get_main_queue();
        }
    }
    return self;
}

@end


#pragma mark - XLMultiCastDelegate
@interface XLMultiCastDelegate ()

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) Protocol *protocol;

@end


@implementation XLMultiCastDelegate

- (instancetype)initWithProtocol:(Protocol *)protocol
{
    NSParameterAssert(protocol);
    self.delegates = [NSMutableArray array];
    self.protocol = protocol;
    return self;
}

- (NSUInteger)numberOfDelegates
{
    return self.delegates.count;
}

- (BOOL)addDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
    if (!delegate || ![delegate conformsToProtocol:self.protocol]) {
        return NO;
    }
    XLDelegateNode *node = [[XLDelegateNode alloc] initWithDelegate:delegate dispatchQueue:queue];
    [self.delegates addObject:node];
    return YES;
}

- (NSUInteger)removeDelegate:(id)delegate
{
    return [self removeDelegate:delegate dispatchQueue:NULL];
}

- (NSUInteger)removeDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
    if (!delegate) {
        return 0;
    }
    NSMutableArray *nodesToRemove = [NSMutableArray arrayWithCapacity:self.delegates.count];
    for (XLDelegateNode *node in self.delegates) {
        if (node.delegate == delegate) {
            if (!queue || queue == node.dispatchQueue) {
                [nodesToRemove addObject:node];
            }
        } else if (!node.delegate) {    //顺便删除无效的代理
            [nodesToRemove addObject:node];
        }
    }
    [self.delegates removeObjectsInArray:nodesToRemove];
    return nodesToRemove.count;
}

- (void)cleanInvalidDelegates
{
    NSMutableArray *nodesToRemove = [NSMutableArray arrayWithCapacity:self.delegates.count];
    for (XLDelegateNode *node in self.delegates) {
        if (!node.delegate) {
            [nodesToRemove addObject:node];
        }
    }
    [self.delegates removeObjectsInArray:nodesToRemove];
}

#pragma mark - runtime
- (void)forwardInvocation:(NSInvocation *)invocation
{
    [self cleanInvalidDelegates];
    NSMethodSignature *sig = invocation.methodSignature;
    const char *returnType = sig.methodReturnType;
    NSArray *delegates = [self.delegates copy];
    if (strcmp(returnType, "v") == 0) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        for (XLDelegateNode *node in delegates) {
            if ([node.delegate respondsToSelector:invocation.selector]) {
                    dispatch_async(node.dispatchQueue, ^{
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        [invocation invokeWithTarget:node.delegate];
                        dispatch_semaphore_signal(semaphore);   
                    });
            }
        }
    } else {
        for (XLDelegateNode *node in delegates) {
            if ([node.delegate respondsToSelector:invocation.selector]) {
                dispatch_async(node.dispatchQueue, ^{
                    [invocation invokeWithTarget:node.delegate];
                });
                break;
            }
        }
    }
}

//to see if any delegate can respondsToSelector
- (BOOL)respondsToSelector:(SEL)aSelector
{
    for(XLDelegateNode *node in self.delegates) {
        if ([node.delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for(XLDelegateNode *node in self.delegates) {
        if ([node.delegate respondsToSelector:aSelector]) {
            return [node.delegate methodSignatureForSelector:aSelector];
        }
    }
    return nil;
}

@end
