//
//  XLYMultiCastDelegate.m
//
//  Created by 王凯 on 14-9-26.
//  Copyright (c) 2014年 kaizei. All rights reserved.
//

#import "XLYMultiCastDelegate.h"

#import <objc/runtime.h>

#pragma mark - XLYDelegateNode
@interface XLYDelegateNode : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
- (instancetype)initWithDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue;

@end

@implementation XLYDelegateNode

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

#pragma mark - XLYMultiCastDelegate
@interface XLYMultiCastDelegate ()

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong, readonly) Protocol *protocol;

@end

@implementation XLYMultiCastDelegate

- (instancetype)initWithProtocolName:(NSString *)protocolName
{
    Protocol *protocol = objc_getProtocol(protocolName.UTF8String);
    return [self initWithConformingProtocol:protocol];
}

- (instancetype)initWithConformingProtocol:(Protocol *)protocol;
{
    NSAssert(protocol, @"must give a valid protocol.");
    _delegates = [NSMutableArray array];
    _protocol = protocol;
    class_addProtocol(self.class, protocol);
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"use '-initWithProtocolName:' instead.");
    return nil;
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
    XLYDelegateNode *node = [[XLYDelegateNode alloc] initWithDelegate:delegate dispatchQueue:queue];
    [self.delegates addObject:node];
    return YES;
}

- (BOOL)hasDelegate:(id)delegate
{
    return [self hasDelegate:delegate dispatchQueue:nil];
}

- (BOOL)hasDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
    for (XLYDelegateNode *node in self.delegates) {
        if (node.delegate == delegate) {
            if (!queue || queue == node.dispatchQueue) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSUInteger)removeDelegate:(id)delegate
{
    return [self removeDelegate:delegate dispatchQueue:nil];
}

- (NSUInteger)removeDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
    if (!delegate) {
        return 0;
    }
    NSMutableArray *nodesToRemove = [NSMutableArray arrayWithCapacity:self.delegates.count];
    for (XLYDelegateNode *node in self.delegates) {
        if (node.delegate == delegate) {
            if (!queue || queue == node.dispatchQueue) {
                [nodesToRemove addObject:node];
            }
        } else if (!node.delegate) { //顺便删除无效的代理
            [nodesToRemove addObject:node];
        }
    }
    [self.delegates removeObjectsInArray:nodesToRemove];
    return nodesToRemove.count;
}
- (void)cleanInvalidDelegates
{
    NSMutableArray *nodesToRemove = [NSMutableArray arrayWithCapacity:self.delegates.count];
    for (XLYDelegateNode *node in self.delegates) {
        if (!node.delegate) {
            [nodesToRemove addObject:node];
        }
    }
    [self.delegates removeObjectsInArray:nodesToRemove];
}

#pragma mark - runtime
- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation retainArguments];
    [self cleanInvalidDelegates];
    NSMethodSignature *sig = invocation.methodSignature;
    const char *returnType = sig.methodReturnType;
    NSArray *delegates = [self.delegates copy];
    if (strcmp(returnType, "v") == 0) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        for (XLYDelegateNode *node in delegates) {
            if ([node.delegate respondsToSelector:invocation.selector]) {
                dispatch_async(node.dispatchQueue, ^{
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    [invocation invokeWithTarget:node.delegate];
                    dispatch_semaphore_signal(semaphore);
                });
            }
        }
    } else { //just in case
        for (XLYDelegateNode *node in delegates) {
            if ([node.delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:node.delegate];
                break;
            }
        }
    }
}

//to see if any delegate can respondsToSelector
- (BOOL)respondsToSelector:(SEL)aSelector
{
    for(XLYDelegateNode *node in self.delegates) {
        if ([node.delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for(XLYDelegateNode *node in self.delegates) {
        if ([node.delegate respondsToSelector:aSelector]) {
            return [node.delegate methodSignatureForSelector:aSelector];
        }
    }
    return [self.class instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)doNothing{}

@end
