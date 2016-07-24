//
//  BraintreeApplePayPlugin.h
//
//  Copyright (c) 2016 Robin Engbersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <PassKit/PassKit.h>

@interface CDVBTApplePay : CDVPlugin <PKPaymentAuthorizationViewControllerDelegate>
- (void)initialize:(CDVInvokedUrlCommand *)command;
- (void)paymentRequest:(CDVInvokedUrlCommand *)command;
@end
