//
//  TMTCFNetworkSocketController.m
//  SocketDemo
//
//  Created by tianmaotao on 2017/6/2.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import "TMTCFNetworkSocketController.h"

#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23
#define kBufferSize 1024

@interface TMTCFNetworkSocketController ()<UITextViewDelegate> {
    NSMutableData * _receivedData;
    CFReadStreamRef readStream;
    CFRunLoopRef runLoop;
}

@end

@implementation TMTCFNetworkSocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithVariable];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)initWithVariable {
    NSInteger port = kTestPort;
    self.portTextField.text = [NSString stringWithFormat:@"%ld", port];
    self.addressTextField.text = kTestHost;
    self.showTextView.delegate = self;
}

- (IBAction)connectButton:(id)sender {
    NSString *addressString = self.addressTextField.text;
    NSString *portString = self.portTextField.text;
    if (!addressString || [addressString isEqualToString:@""]) {
        [self showAlertWithTitle:@"error" message:@"Server address cann't be empty!"];
        return;
    }
    
    if (!portString || [portString isEqualToString:@""]) {
        [self showAlertWithTitle:@"error" message:@"Server port cann't be empty!"];
        return;
    }
    
    //开启新线程请求数据
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", self.addressTextField.text, self.portTextField.text]];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadDataFromServerWithUrl:) object:url];
    [thread start];

}

#pragma mark - 创建socket连接
//发送socket请求
- (void)loadDataFromServerWithUrl:(NSURL *)url {
    NSString *host = [url host];
    NSInteger port = [[url port] integerValue];
    
    // 创建socket
    CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFOptionFlags registeredEcents = (kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered);
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)host, port, &readStream, NULL);
    
    
    //设置
    if (CFReadStreamSetClient(readStream, registeredEcents, socketCallback, &ctx)) {
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    
    //打开流对象
    CFReadStreamOpen(readStream);
    
    runLoop = CFRunLoopGetCurrent();
    //放入runloop，开始处理
    CFRunLoopRun();
}

//数据返回时，回调函数
void socketCallback(CFReadStreamRef stream, CFStreamEventType event, void * myPtr)
{
    NSLog(@" >> socketCallback in Thread %@", [NSThread currentThread]);
    
    TMTCFNetworkSocketController * controller = (__bridge TMTCFNetworkSocketController *)myPtr;
    
    switch(event) {
        case kCFStreamEventHasBytesAvailable: {
            // Read bytes until there are no more
            //
            while (CFReadStreamHasBytesAvailable(stream)) {
                UInt8 buffer[kBufferSize];
                long int numBytesRead = CFReadStreamRead(stream, buffer, kBufferSize);
                
                [controller didReceiveData:[NSData dataWithBytes:buffer length:numBytesRead]];
            }
            
            break;
        }
            
        case kCFStreamEventEndEncountered:
            // Finnish receiveing data
            //
            [controller didFinishReceivingData];
            
            // Clean up
            //
            CFReadStreamClose(stream);
            CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            CFRunLoopStop(CFRunLoopGetCurrent());
            
            break;
            
        default:
            break;
    }
}

#pragma mark data
//数据传输完成
- (void)didReceiveData:(NSData *)data {
    if (_receivedData == nil) {
        _receivedData = [[NSMutableData alloc] init];
    }
    
    [_receivedData appendData:data];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.showTextView.text = resultsString;
    }];
}

//收到一批数据
- (void)didFinishReceivingData
{
    [self networkSucceedWithData:_receivedData];
}

- (void)networkSucceedWithData:(NSData *)data
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@" >> Received string: '%@'", resultsString);
        
        self.showTextView.text = resultsString;
    }];
}
#pragma mark -
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    if (!title || !message) {
        return;
    }
    
    UIAlertController *showMessage = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [showMessage addAction:ok];
    [showMessage addAction:cancel];
    
    [self presentViewController:showMessage animated:YES completion:nil];
}
- (IBAction)back:(id)sender {
    
    //停止socket 并从runloop中移除事件
    CFReadStreamUnscheduleFromRunLoop(readStream, runLoop, kCFRunLoopCommonModes);
    CFReadStreamClose(readStream);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
