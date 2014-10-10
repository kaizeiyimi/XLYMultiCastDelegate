//
//  SimpleProtocol.h
//  XLMultiCastDelegate
//
//  Created by kaizei on 14/9/26.
//  Copyright (c) 2014年 kaizei. All rights reserved.
//

@protocol SimpleProtocol <NSObject>

- (id)someRequiredMethod:(id)object;

@optional
- (void)someOptionalMethod;


@end

