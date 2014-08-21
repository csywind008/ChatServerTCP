//
//  ChatViewController.h
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "AsyncSocket.h"
@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;

    UserModel *_userModel;
}
@property (nonatomic, retain) UserModel *userModel;

@end
