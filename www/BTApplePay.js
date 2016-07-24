"use strict";

var exec = require("cordova/exec");

var PLUGIN_ID = "BTApplePay";
var BraintreePlugin = {};

/**
 * Init of BraintreePlugin.
 *
 * The client has to be initialized before other methods can be used.
 *
 * @param {string} token - The client token or tokenization key to use with the Braintree client. Generate it in your BrainTree config panel under Account -> Settings
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
BraintreePlugin.initialize = function initialize(token, successCallback, failureCallback) {

    if (!token || typeof(token) !== "string") {
        failureCallback("A non-null, non-empty string must be provided for the token parameter.");
        return;
    }

    exec(successCallback, failureCallback, PLUGIN_ID, "initialize", [token]);
};

/**
 * Shows ApplePays drop-in UI.
 *
 * @param {object} options - The options used to control the drop-in payment UI.
 * @param [function] successCallback - The success callback for this asynchronous function; receives a result object.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
BraintreePlugin.paymentRequest = function paymentRequest(options, successCallback, failureCallback) {

    if (!options) {
        options = {};
    }

    if (typeof(options.itemName) !== "string") {
        options.itemName = "Cancel";
    }

    if (typeof(options.paymentReceiver) !== "string") {
        options.paymentReceiver = "";
    };

    if (typeof(options.amount) !== "string") {
        options.amount = "";
    };

    if (typeof(options.countryCode) !== "string") {
        options.countryCode = "";
    };

    if (typeof(options.currency) !== "string") {
        options.currency = "";
    };

    var pluginOptions = [
        options.itemName,
        options.paymentReceiver,
        options.amount,
        options.countryCode,
        options.currency
    ];

    exec(successCallback, failureCallback, PLUGIN_ID, "paymentRequest", pluginOptions);
};

module.exports = BraintreePlugin;
