//
//  ViewController.h
//  Test3
//
//  Created by Regan Russell on 5/8/19.
//  Copyright © 2019 PymbleSoftware Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTPaymentMethodNonce.h"

@interface ViewController : UIViewController


@property (nonatomic, weak) void (^progressBlock)(NSString *newStatus);
@property (nonatomic, weak) void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce);
@property (nonatomic, weak) void (^transactionBlock)(void);

@end

