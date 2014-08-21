//
//  ListViewController.m
//  ChatServer
//
//  Created by yang on 12/10/13.
//  Copyright (c) 2013 北京千锋互联科技有限公司. All rights reserved.
//

#import "ListViewController.h"
#import "UserModel.h"
#import "ChatViewController.h"

@interface ListViewController ()
- (void) handleClient:(id)arg ;

@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"用户列表";
    
    _allClientSocket = [[NSMutableArray alloc] init];
    _userArray = [[NSMutableArray alloc] init];
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    // 1. 创建客户端
    clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
    // 2. 连接服务端
    [clientSocket connectToHost:@"192.168.118.144" onPort:6789 withTimeout:100 error:nil];
    // 这个函数就是告诉系统去连接 192.168.118.144 端口6789的服务器
    // 如果100s不能成功连接 那么就出错...
    // 这个函数不会执行100s 而是让后台系统默默的执行。。。。
    // ????什么时候连接成功????
    
    // 1. 创建套接字
    serverSocket = [[AsyncSocket alloc] initWithDelegate:self];
    // 2. 绑定端口 并在端口6789上监听客户端连接...
    [serverSocket acceptOnPort:6789 error:nil];
    // 等待有客户端来连接端口6789 如果有人来连接了 那么就触发代理函数
}
- (void) loginToServer {
    // 本函数一定要保证在 didConnectToHost调用完成后才能使用
    if (![clientSocket isConnected]) {
        // 判断时候已经连接上...
        return;
    }
    NSString *s = @"login:欧阳坚";
    NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [clientSocket writeData:d withTimeout:60 tag:100];
    // TCP发给服务器...这里不需要再次指定 ip和端口了
    // 因为..... 已经连接上了
    
    // 启动一个读取服务端的函数
    [clientSocket readDataWithTimeout:-1 tag:200];
}
- (void) getAllUsers:(id)sender {
    if (![clientSocket isConnected]) return;
    NSString *s = @"getuser:online";
    NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
    // 写个服务器
    [clientSocket writeData:d withTimeout:60 tag:100];
    // 500表示读取发过来的用户列表
    [clientSocket readDataWithTimeout:-1 tag:500];
}

- (NSData *) getImageData:(UIImage *)img {
    NSData *d = UIImagePNGRepresentation(img);
    if (d == nil) {
        d = UIImageJPEGRepresentation(img, 0.8);
    }
    return d;
}
- (void) sendImage {
    UIImage *img = [UIImage imageNamed:@"xxx.png"];
    // png , jpg
    NSData *imgData = [self getImageData:img];
    /* 发图片 
     message:pic:len
     图片的二进制 img
     
     // 文字
     message:text:文字 
     // mp3
     message:voice:len
     声音的二进制
     */
    NSString *metaStr = [NSString stringWithFormat:@"message:pic:%d", [imgData length]];
    NSData *imgMeta = [metaStr dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:imgMeta withTimeout:-1 tag:600];
    [clientSocket writeData:imgData withTimeout:-1 tag:601];
    // 发图片分2步。。1把图片的信息发过去 2 把图片二进制发过去
    // 分了2个数据包
}

//- (void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//}
// 连接成功的代理函数......
- (void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"连接成功");
}
// 已经有一个新的客户单来连接当前机器
// 如果有一个客户端连接 这个函数就执行一次 如果有2个客户端连接 这个函数就执行2次
- (void) onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    // newSocket就是 系统 新创建的socket
    // newSocket就是用来专门处理和连接的客户端通讯的
    [_allClientSocket addObject:newSocket];
    [self handleClient:newSocket];
}
- (void) handleClient:(id)arg {
    AsyncSocket *newSocket = (AsyncSocket *)arg;
    // 往这个clientSockt里面写的内容就会到客户端
    // 首先来看对方ip是什么????
    NSString *ip = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    NSLog(@"ip is %@:%d", ip, port);
    // 告诉系统从客户端 读取数据 只读一次
    [newSocket readDataWithTimeout:-1 tag:100];
}
// 真正有数据来了....
// data就是真正的数据....
- (void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (tag == 500) {
        // 读取服务器发过来的数据...
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str is %@", str);
        return;
    }
    if (tag == 700) {
        // 说明shi .... 读取的是图片 ....
        UIImage *img = [[UIImage alloc] initWithData:data];
        // 如何知道到底是谁.....
        NSString *ip = [sock connectedHost];
        UserModel *thisUm = nil;
        for (UserModel *um in _userArray) {
            if ([um.ip isEqualToString:ip]) {
                thisUm = um; break;
            }
        }
        [thisUm addOneImageMessage:img];
        [sock readDataWithTimeout:-1 tag:100];
        return;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"read %@:%d %@", [sock connectedHost], [sock connectedPort], str);
    //str 应该是 login:xxxx
    NSArray *subArr = [str componentsSeparatedByString:@":"];
    if ([subArr count] < 2) {
        [sock readDataWithTimeout:-1 tag:100];
        return;
    }
    NSString *type = [subArr objectAtIndex:0];
    if ([type isEqualToString:@"message"]) {
        NSString *subType = [subArr objectAtIndex:1];
        if ([subType isEqualToString:@"pic"]) {
            NSUInteger len = [[subArr objectAtIndex:2] integerValue];
            NSLog(@"recv (%@:%d) len is %d",
                  [sock connectedHost],
                  [sock connectedPort], len);
            [sock readDataToLength:len withTimeout:-1 tag:700];
            return;
        }
    }
    if ([type isEqualToString:@"login"]) {
        NSString *name = [subArr objectAtIndex:1];        
        BOOL hasThisName = NO;
        for (UserModel *um in _userArray) {
            if ([um.name isEqualToString:name]) {
                hasThisName = YES;
                NSString *res = @"return:已经登陆";
                NSData *responseData = [res dataUsingEncoding:NSUTF8StringEncoding];
                [sock writeData:responseData withTimeout:-1 tag:200];
            }
        }
        if (hasThisName == NO) {
            UserModel *um = [[UserModel alloc] init];
            um.name = name;
            um.ip = [sock connectedHost];
            um.port = [sock connectedPort];
            [_userArray addObject:um];
            [_tableView reloadData];
            NSString *res = @"return:OK";
            NSData *responseData = [res dataUsingEncoding:NSUTF8StringEncoding];
            [sock writeData:responseData withTimeout:-1 tag:200];
        }

    }
    if ([type isEqualToString:@"getuser"]) {
        /* _userArray
         <name:ip>|<name:ip>|<name:ip>|<name:ip>
         */
        NSString *resStr = @"";
        for (UserModel *um in _userArray) {
            NSString *itm = [NSString stringWithFormat:@"<%@:%@>", um.name, um.ip];
            resStr = [resStr stringByAppendingFormat:@"%@|", itm];
        }
        // |
        NSData *resData = [resStr dataUsingEncoding:NSUTF8StringEncoding];
        [sock writeData:resData withTimeout:-1 tag:600];
    }
    [sock readDataWithTimeout:-1 tag:100];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_userArray count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"My cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    UserModel *um = [_userArray objectAtIndex:indexPath.row];
    NSString *userName = um.name;
    int messageCount = [um getMessageCounts];
//    NSString *userName =  [_userArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%d)", userName, messageCount];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserModel *um = [_userArray objectAtIndex:indexPath.row];
    ChatViewController *cvc = [[ChatViewController alloc] init];
    cvc.userModel = um;
    [self.navigationController pushViewController:cvc animated:YES];
}
@end
