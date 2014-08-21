//
//  UserModel.m
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import "UserModel.h"
#import "MessageModel.h"

@implementation UserModel
@synthesize name = _name, ip = _ip, port = _port;
- (id)init
{
    self = [super init];
    if (self) {
        _allMessages = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void) addOneMessage:(NSString *)msg {
    if (msg == nil || [msg isEqualToString:@""]) return;
    MessageModel *mm = [[MessageModel alloc] init];
    mm.message = msg;
    [_allMessages addObject:mm];
}
- (void) addOneImageMessage:(UIImage *)imgMsg {
    if (imgMsg == nil) return;
    MessageModel *mm = [[MessageModel alloc] init];
    mm.image = imgMsg;
    [_allMessages addObject:mm];
}
- (int) getMessageCounts {
    return [_allMessages count];
}

- (NSArray *) getAllMessages {
    return [_allMessages copy]; // 把mutablearray --->array
    // mutableCopy arrray -->mutablearray
}

@end
