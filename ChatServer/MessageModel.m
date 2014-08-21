//
//  MessageModel.m
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel
@synthesize message = _message, timestamp = _timestamp;
@synthesize image = _image;
- (BOOL) isPicMessage {
    return _image != nil;
}
- (BOOL) isTextMessage {
    return _message != nil;
}


@end
