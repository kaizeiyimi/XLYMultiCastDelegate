XLYMultiCastDelegate
===================

allow people to multicast the delegate methods invocation to multi delegate objects.

updated for mixing with swift. see demo for more detail.

Description
===================
it uses some runtime methods such as respondsToSelector:, methodSignatureForSelector: and forwardInvocation: to achieve the method invocation cast.

you can set some object's delegate property like this:

```objective-c
XLYMultiCastDelegate *multiCastDelegate = [[XLYMultiCastDelegate alloc]initWithConformingProtocol:@protocol(AProtocol)];
[multiCastDelegate addDelegate:firstDelegate dispatchQueue:firstDispatchQueue];
[multiCastDelegate addDelegate:secondDelegate dispatchQueue:secondDispatchQueue];
object.delegate = (id<AProtocol>)multiCastDelegate;
````

then when the object call a delegate method for example 'hello', the multiCastDelegate can forward the invocation to firstDelegate and then to secondDelegate. firstDelegate will receive 'hello' in firstDispatchQueue and secondDelegate will receive in secondDispatchQueue.

this is different with normal delegate. Normal delegate can only be a single object who confirms to 'AProtocol', while using MultiCastDelegate, all the interesting objects can receive a method calling.

It is also different with Notification. Notification ask for a string to be the Notification name and a selector to be called when Notification post. Developers should also remove observer at appropriate time. MultiCastDelegate require all the delegates added to confirm a certain protocol, or else the add action will fail at rumtime. It use method call rather than a string and a selector which is hard to maintain to achieve multi notification.
