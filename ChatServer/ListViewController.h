//
//  ListViewController.h
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface ListViewController : UIViewController
    <UITableViewDataSource, UITableViewDelegate, AsyncSocketDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_userArray;
    NSMutableArray *_allClientSocket;
    
    // 1. 定义一个tcp socket 欧阳坚写
    AsyncSocket *serverSocket;
    
    // 2. 定义tcp 客户端的socket
    AsyncSocket *clientSocket;
    
}

@end
