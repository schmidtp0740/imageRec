# iOS ChatBot lite app

This application shows you how iOS apps created with Swift 3 can integrate with the Oracle ChatBots platform and chat through WebSocket.

## Requirements

* XCode 8 or higher
* iOS 10.0 or higher

## Support for Standard User Inputs in the ChatVC.swift App

This app provides bot users with the following input options:

* Soft keyboard for standard text messaging.
* Selection through choices - The app automatically sends the selected option to the ChatBot.
* Microphone - The Apple Speech-recognition technology that converts speech to text.

This app also replies to the user using native Speech framework. This includes replies to a user's choices (with appropriate pauses).

## Local Notifications Support in CBManager.swift

If the app is in the background when an incoming message arrives from the bot, it triggers a notification that allows the user to reply to the bot by tapping the notification's reply button.

## The Settings Tab (Runtime)

You configure the BaseURL and channelID in the app's Settings tab as required fields.
**Note**: You must restart the iOS app whenever you save changes to the either the BaseURL or the channelID settings.

Users can enable and disable the voice output for the bot's reply by toggling the button on or off.

## Third-Party Use:
[https://github.com/daltoniam/Starscream/blob/master/Source](https://github.com/daltoniam/Starscream/blob/master/Source) (using the `SSLSecurity` and  `WebSocket` classes)

