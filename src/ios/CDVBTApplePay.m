//
//  CDVBTApplePay.m
//
//  Copyright (c) 2016 Robin Engbersen. All rights reserved.
//

#import "CDVBTApplePay.h"
#import <objc/runtime.h>
#import <BraintreeUI/BTPaymentRequest.h>
#import <BraintreeUI/BTDropInViewController.h>
#import <BraintreeCore/BTAPIClient.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreeCard/BTCardNonce.h>
#import <BraintreePayPal/BraintreePayPal.h>
#import <BraintreeApplePay/BraintreeApplePay.h>
#import <Braintree3DSecure/Braintree3DSecure.h>
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <PassKit/PassKit.h>

@interface CDVBTApplePay() <BTDropInViewControllerDelegate>

@property (nonatomic, strong) BTAPIClient *braintreeClient;

@end

@implementation CDVBTApplePay

NSString *amount;
NSString *countryCode;
NSString *currency;
NSString *dropInUIcallbackId;
NSString *itemName;
NSString *paymentReceiver;

NSString *merchantId;

- (void)initialize:(CDVInvokedUrlCommand *)command {
    
    NSLog(@"Initialize Braintree Apple-Pay Plugin");
    merchantId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ApplePayMerchant"];
    
    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 1) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A token is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    // Obtain the arguments.
    NSString* token = [command.arguments objectAtIndex:0];
    
    if (!token) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A token is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:token];
    
    if (!self.braintreeClient) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The Braintree client failed to initialize."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)paymentRequest:(CDVInvokedUrlCommand *)command {
    
    if (!self.braintreeClient) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The Braintree client must first be initialized via BraintreePlugin.initialize(token)"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    itemName = [command.arguments objectAtIndex:0];
    
    if (!itemName) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"itemName is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    paymentReceiver = [command.arguments objectAtIndex:1];
    
    if (!paymentReceiver) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"paymentReceiver is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    amount = [command.arguments objectAtIndex:2];
    
    if (!amount) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"amount is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    countryCode = [command.arguments objectAtIndex:3];
    
    if (!countryCode) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"countryCode is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    currency = [command.arguments objectAtIndex:4];
    
    if (!currency) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"currency is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }
    
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = merchantId;
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = countryCode; // e.g. US
    paymentRequest.currencyCode = currency; // e.g. USD
    paymentRequest.paymentSummaryItems =
    @[
      [PKPaymentSummaryItem summaryItemWithLabel:itemName amount:[NSDecimalNumber decimalNumberWithString:amount]],
      // Add add'l payment summary items...
      [PKPaymentSummaryItem summaryItemWithLabel:paymentReceiver amount:[NSDecimalNumber decimalNumberWithString:amount]]
      ];
    
    PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    vc.delegate = self;
    [self.viewController presentViewController:vc animated:YES completion:nil];
}


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    CDVPluginResult* pluginResult = nil;
    
    // Example: Tokenize the Apple Pay payment
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
                                        initWithAPIClient:self.braintreeClient];
    [applePayClient tokenizeApplePayPayment:payment
                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
                                              NSError *error) {
                                     if (tokenizedApplePayPayment) {
                                         // On success, send nonce to your server for processing.
                                         // If applicable, address information is accessible in `payment`.
                                         NSLog(@"nonce = %@", tokenizedApplePayPayment.nonce);
                                         
                                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:tokenizedApplePayPayment.nonce];
                                         [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                         
                                         // Then indicate success or failure via the completion callback, e.g.
                                         completion(PKPaymentAuthorizationStatusSuccess);
                                     } else {
                                         // Tokenization failed. Check `error` for the cause of the failure.
                                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                                         [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                         
                                         // Indicate failure via the completion callback:
                                         completion(PKPaymentAuthorizationStatusFailure);
                                     }
                                 }];
}

// Be sure to implement -paymentAuthorizationViewControllerDidFinish:
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end