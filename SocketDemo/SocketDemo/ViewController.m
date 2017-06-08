//
//  ViewController.m
//  SocketDemo
//
//  Created by tianmaotao on 2017/6/2.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import "ViewController.h"
#import "TMTBSDSocketController.h"
#import "TMTNSStreamSocketController.h"
#import "TMTCFNetworkSocketController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
/*Cocoa层
 是最上层的基于 Objective-C 的 API，比如 URL访问，NSStream，Bonjour，GameKit等，这是大多数情况下我们常用的 API。Cocoa 层是基于 Core Foundation 实现的。
 */
- (IBAction)NSStreamSocketAcion:(id)sender {
    TMTNSStreamSocketController *socketNSStream = [[TMTNSStreamSocketController alloc] init];
    [self presentViewController:socketNSStream animated:YES completion:nil];
}

/*Core Foundation层
 因为直接使用 socket 需要更多的编程工作，所以苹果对 OS 层的 socket 进行简单的封装以简化编程任务。该层提供了 CFNetwork 和 CFNetServices，其中 CFNetwork 又是基于 CFStream 和 CFSocket。
 */
- (IBAction)CFNetworkSocketAction:(id)sender {
    TMTCFNetworkSocketController *socketNetwork = [[TMTCFNetworkSocketController alloc] init];
    [self presentViewController:socketNetwork animated:YES completion:nil];
}

/*OS层
 最底层的 BSD socket 提供了对网络编程最大程度的控制，但是编程工作也是最多的。因此，苹果建议我们使用 Core Foundation 及以上层的 API 进行编程。
 */
- (IBAction)BSDSocketAction:(id)sender {
    TMTBSDSocketController *socketBSD = [[TMTBSDSocketController alloc] init];
    [self presentViewController:socketBSD animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
