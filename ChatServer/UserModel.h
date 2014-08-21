//
//  UserModel.h
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"

@interface UserModel : NSObject {
    NSString *_name;
    NSString *_ip;
    UInt16 _port;
    NSMutableArray *_allMessages;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) UInt16 port;
// 我并没有写 @property (nonatomic, retain) NSMutableArray *allMessages;
//@property (nonatomic, retain) NSMutableArray *allMessages;
- (void) addOneMessage:(NSString *)msg;
- (void) addOneImageMessage:(UIImage *)imgMsg;
- (int) getMessageCounts;
- (NSArray *) getAllMessages;

@end
