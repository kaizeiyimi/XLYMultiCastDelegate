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
    self.dispatchQueue = queue ? queue : dispatch_get_main_queue();
  }
  return self;
}

@end

#pragma mark - XLYMultiCastDelegate

@interface XLYMultiCastDelegate ()

@property (nonatomic, strong) NSMutableArray *delegateNodes;
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
  _delegateNodes = [NSMutableArray array];
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
  [self cleanInvalidDelegates];
  return self.delegateNodes.count;
}

- (BOOL)addDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
  if (!delegate || ![delegate conformsToProtocol:self.protocol]) {
    return NO;
  }
  XLYDelegateNode *node = [[XLYDelegateNode alloc] initWithDelegate:delegate dispatchQueue:queue];
  [self.delegateNodes addObject:node];
  return YES;
}

- (BOOL)hasDelegate:(id)delegate
{
  return [self hasDelegate:delegate dispatchQueue:nil];
}

- (BOOL)hasDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue
{
  if (!delegate) {
    return NO;
  }
  for (XLYDelegateNode *node in self.delegateNodes) {
    if (node.delegate == delegate && (!queue || queue == node.dispatchQueue)) {
      return YES;
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
  __block NSInteger count = 0;
  [self.delegateNodes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(XLYDelegateNode *node, NSDictionary *bindings) {
    if (node.delegate == delegate) {
      count ++;
      return NO;
    }
    if (!node.delegate) {
      return NO;
    }
    return YES;
  }]];
  return count;
}

#pragma mark - private methods
- (void)cleanInvalidDelegates
{
  [self.delegateNodes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(XLYDelegateNode *node, NSDictionary *bindings) {
    return node.delegate != nil;
  }]];
}

#pragma mark - runtime
- (void)forwardInvocation:(NSInvocation *)invocation
{
  [invocation retainArguments];
  [self cleanInvalidDelegates];
  NSMethodSignature *sig = invocation.methodSignature;
  const char *returnType = sig.methodReturnType;
  NSArray *delegates = [self.delegateNodes copy];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (strcmp(returnType, "v") == 0) {
      dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
      for (XLYDelegateNode *node in delegates) {
        if ([node.delegate respondsToSelector:invocation.selector]) {
          dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
          dispatch_async(node.dispatchQueue, ^{
            @autoreleasepool {
              [invocation invokeWithTarget:node.delegate];
            }
            dispatch_semaphore_signal(semaphore);
          });
        }
      }
    } else {
      for (XLYDelegateNode *node in delegates) {
        if ([node.delegate respondsToSelector:invocation.selector]) {
          dispatch_async(node.dispatchQueue, ^{
            [invocation invokeWithTarget:node.delegate];
          });
          break;
        }
      }
    }
  });
}

//to see if any delegate can respondsToSelector
- (BOOL)respondsToSelector:(SEL)aSelector
{
  for(XLYDelegateNode *node in self.delegateNodes) {
    if ([node.delegate respondsToSelector:aSelector]) {
      return YES;
    }
  }
  return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  for(XLYDelegateNode *node in self.delegateNodes) {
    if ([node.delegate respondsToSelector:aSelector]) {
      return [node.delegate methodSignatureForSelector:aSelector];
    }
  }
  return [self.class instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)doNothing{}

@end
