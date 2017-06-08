//
//  TMTNSStreamSocketController.m
//  SocketDemo
//
//  Created by tianmaotao on 2017/6/2.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import "TMTNSStreamSocketController.h"

#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23
#define kBufferSize 1024

@interface TMTNSStreamSocketController ()<UITextViewDelegate, NSStreamDelegate>
@property(nonatomic, copy) NSMutableData *readData;
@end

@implementation TMTNSStreamSocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithVariable];
    // Do any additional setup after loading the view from its nib.
}

- (void)initWithVariable {
    NSInteger port = kTestPort;
    self.portTextView.text = [NSString stringWithFormat:@"%ld", port];
    self.addressTextView.text = kTestHost;
    self.showTextView.delegate = self;
    self.addressTextView.layer.cornerRadius = 10.0;
    self.portTextView.layer.cornerRadius = 10.0;
    self.showTextView.layer.cornerRadius = 5.0;
    
}

- (IBAction)connectAction:(id)sender {
    NSString *addressString = self.addressTextView.text;
    NSString *portString = self.portTextView.text;
    if (!addressString || [addressString isEqualToString:@""]) {
        [self showAlertWithTitle:@"error" message:@"Server address cann't be empty!"];
        return;
    }
    
    if (!portString || [portString isEqualToString:@""]) {
        [self showAlertWithTitle:@"error" message:@"Server port cann't be empty!"];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", self.addressTextView.text, self.portTextView.text]];
    NSThread *backgroundThread = [[NSThread alloc] initWithTarget:self
                                                         selector:@selector(loadDataFromServerWithURL:)
                                                           object:url];
    [backgroundThread start];
}

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataFromServerWithURL:(NSURL *)url {
    NSInputStream *inputStream;
    [NSStream getStreamsToHostWithName:[url host]
                                  port:[url port].integerValue
                           inputStream:&inputStream outputStream:NULL];
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable: {
            if (_readData == nil) {
                _readData = [[NSMutableData alloc] init];
            }
            
            uint8_t buf[kBufferSize];
            long int numBytesRead = [(NSInputStream *)stream read:buf maxLength:1024];
            if (numBytesRead > 0) {
                [self didReceiveData:[NSData dataWithBytes:buf length:numBytesRead]];
                
            } else if (numBytesRead == 0) {
                NSLog(@" >> End of stream reached");
                
            } else {
                NSLog(@" >> Read error occurred");
            }
        }
            
            break;
        case NSStreamEventEndEncountered:{
            [self cleanUpStream:stream];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveData:(NSData *)data {
    if (_readData == nil) {
        _readData = [[NSMutableData alloc] init];
    }
    
    [_readData appendData:data];
    
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.showTextView.text = resultsString;
    }];
}

- (void)cleanUpStream:(NSStream *)stream
{
    [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stream close];
    
    stream = nil;
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
