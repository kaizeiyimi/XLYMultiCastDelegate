//
//  SimpleProtocol.h
//  XLMultiCastDelegate
//
//  Created by kaizei on 14/9/26.
//  Copyright (c) 2014年 kaizei. All rights reserved.
//

#ifndef XLMultiCastDelegate_SimpleProtocol_h
#define XLMultiCastDelegate_SimpleProtocol_h

@protocol SimpleProtocol <NSObject>

- (id)someRequiredMethod:(id)object;

@optional
- (void)someOptionalMethod;


@end

#endif
