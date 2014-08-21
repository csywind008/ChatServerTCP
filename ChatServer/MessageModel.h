//
//  MessageModel.h
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject {
    NSString *_message;
    UIImage *_image;
    //NSTimeInterval == double
    // 表示从1970.1.1. 00:00:00 到现在的时间
    NSTimeInterval _timestamp;
}
- (BOOL) isPicMessage;
- (BOOL) isTextMessage;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end
