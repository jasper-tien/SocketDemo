//
//  TMTCFNetworkSocketController.h
//  SocketDemo
//
//  Created by tianmaotao on 2017/6/2.
//  Copyright © 2017年 tianmaotao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMTCFNetworkSocketController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@property (weak, nonatomic) IBOutlet UITextView *showTextView;


- (void)didReceiveData:(NSData *)data;
@end
