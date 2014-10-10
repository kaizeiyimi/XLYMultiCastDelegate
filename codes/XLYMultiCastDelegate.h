//
// XLYMultiCastDelegate.h
//
//  Created by 王凯 on 14-9-26.
// Copyright (c) 2014年 王凯. All rights reserved.
//

/*
 this class is designed to make notifications act like calling delegate methods.
 it uses method forward to notify every delegate which is added already.
 one important thing: you should not use MultiCastDelegate for method which has a return value,
 the multiCastDelegate only find the first delegate who can response to the selector and invoke the invocation
 right in the calling queue not in the delegateQueue. if no delegate can response to the selector, then you will
 always get nil as the return value which stands for nothing.
 
 once again: MultiCastDelegate only want to make notifications more comfortable.
 */

#import <Foundation/Foundation.h>
@interface XLYMultiCastDelegate : NSObject
/**
 the protocol the delegates should confirm. it must not be nil.
 */
- (instancetype)initWithProtocolName:(NSString *)protocolName;
- (instancetype)initWithConformingProtocol:(Protocol *)protocol;
///return the number of total delegates.
- (NSUInteger)numberOfDelegates;
/**
 add a delegate and a dispatch_queue, if queue is not given, is will use the main_queue.
 the method sent to the delegate will be in the queue.
 */
- (BOOL)addDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue;
///check whether a delegate is already added.
- (BOOL)hasDelegate:(id)delegate;
///check whether a delegate is already added and assosicated to a queue.
- (BOOL)hasDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue;
///remove delegate. this method remove all the delegates that equal the given delegate. remove is not necessary, since we keep a weak refrence to the delegate.
- (NSUInteger)removeDelegate:(id)delegate;
///remove delegate. this method remove all the delegates that equal the given delegate which assosiated with the queue.
- (NSUInteger)removeDelegate:(id)delegate dispatchQueue:(dispatch_queue_t)queue;

@end