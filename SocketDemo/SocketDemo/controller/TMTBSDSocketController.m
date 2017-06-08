//
//  TMTBSDSocketController.m
//  SocketDemo
//
//  Created by tianmaotao on 2017/6/2.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import "TMTBSDSocketController.h"
#import <arpa/inet.h>
#import <netdb.h>

#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23

@interface TMTBSDSocketController ()
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextView *showTextView;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@end

@implementation TMTBSDSocketController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addressTextField.text = kTestHost;
    self.portTextField.text = [NSString stringWithFormat:@"%d", kTestPort];
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)connectAction:(id)sender {
    if (!self.addressTextField.text ||[self.addressTextField.text isEqualToString:@""] ||
        !self.portTextField.text || [self.portTextField.text isEqualToString:@""]) {
        
        [self showAlertViewWithTitle:@"提示" message:@"address 或者 port 不能为空！！！"];
        
    }
    
    NSString * serverHost = self.addressTextField.text;
    NSString * serverPort = self.portTextField.text;
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", serverHost, serverPort]];
    NSThread * backgroundThread = [[NSThread alloc] initWithTarget:self
                                                          selector:@selector(loadDataFromServerWithURL:)
                                                            object:url];
    [backgroundThread start];
    
}

- (void)loadDataFromServerWithURL:(NSURL *)url {
    NSString * host = [url host];
    NSNumber * port = [url port];
    
    // Create socket
    //
    int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == socketFileDescriptor) {
        NSLog(@"Failed to create socket.");
        return;
    }
    
    // Get IP address from host
    //
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        close(socketFileDescriptor);
        
        [self showAlertViewWithTitle:@"提示" message:@"地址解析失败!"];
        return;
    }
    
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    // Set the socket parameters
    //
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons([port intValue]);
    
    // Connect the socket
    //
    int ret = connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(socketFileDescriptor);
        
        NSString * errorInfo = [NSString stringWithFormat:@"连接失败 %@:%@", host, port];
        [self showAlertViewWithTitle:@"提示" message:errorInfo];
        return;
    }
    
    NSLog(@" >> Successfully connected to %@:%@", host, port);
    
    NSMutableData * data = [[NSMutableData alloc] init];
    // Continually receive data until we reach the end of the data
    //
    int maxCount = 5;   // just for test.
    int i = 0;
    BOOL waitingForData = YES;
    while (waitingForData && i < maxCount) {
        const char * buffer[1024];
        int length = sizeof(buffer);
        
        // Read a buffer's amount of data from the socket; the number of bytes read is returned
        //
        long int result = recv(socketFileDescriptor, &buffer, length, 0);
        if (result > 0) {
            [data appendBytes:buffer length:result];
        }
        else {
            // if we didn't get any data, stop the receive loop
            //
            waitingForData = NO;
        }
        ++i;
    }
    
    // Close the socket
    //
    close(socketFileDescriptor);
    
    [self networkSucceedWithData:data];

}

- (void)networkSucceedWithData:(NSData *)data {
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@" >> Received string: '%@'", resultsString);
        
        self.showTextView.text = resultsString;
    }];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
