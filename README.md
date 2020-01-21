# Ionic / Cordova Plugin Braintree Apple Pay

This plugin is a basic implementation of Braintree and Apple Pay with the purpose of returning a Braintree-Token to create a transaction. It works on Cordova / Ionic.

## Installation

1. Setup a Braintree account and follow the steps to create a tokenized key (Account > User > API keys).
2. In xCode navigate to the **Capabilities** and add **Apple Pay**.
3. Install the plugin

```sh
cordova plugin add https://github.com/nim901/cordova-plugin-braintree-applepay \
  --variable APPLE_PAY_MERCHANT="merchant.com.apple.test"
```

4. In xCode < version 8.0 select your app and click on targets. There navigate to **Build Phases** / **Embed Frameworks** and select **Code Sign on Copy** for every file. In xCode >= version 8.0 add braintree frameworks under **Targets** / **Embedded Binaries**

5. For Archiving you have to set **Enable Bitcode on Debug** in **Build Settings** in xCode to **YES** and during the Archiving process uncheck checkbox saying **Rebuild from bitcode**.

## Supported Platforms

- iOS

## Methods

```js
- BTApplePay.initialize
- BTApplePay.paymentRequest
```

#### BTApplePay.initialize

Must be called before **BTApplePay.paymentRequest** in order to set the tokenization key provided by Braintree. If this token has not been already generated, it needs to be generated in the Braintree backend. Navigate to Account > My user > API Keys, Tokenizations Keys, Encryption Keys.

#### BTApplePay.paymentRequest

Is called to open the native Apple Pay payment footer. Options need to be defined. Returns a Braintree token nonce if the generation was successful. This token need to be sent to the server for further processing.

## Example

```js
BTApplePay.initialize("tokenization_key",
  function () { console.log("init OK!"); },
  function (error) { console.error(error); });

var options = {
  itemName: "Bicycle for kids",
  paymentReceiver: "OX Bar",
  amount: "255.50",
  countryCode: "SG",
  currency: "SGD",
  merchantIdentifier: "merchant..."
};

BTApplePay.paymentRequest(options, function (nonce) {
  console.log(nonce);
}, function() {
  // Catch error
});
```

## Impressions

![alt tag](http://xorox.io/wp-content/uploads/2016/07/iphone-payment-applepay.png)
