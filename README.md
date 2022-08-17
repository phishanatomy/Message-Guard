<p align="center">
  <img width="256" height="256" src="/src/art/messageguard-transparent-256.png" alt="Message Guard Logo">
</p>

# Message Guard
Filter phishing, malware, and spam SMS messages on iOS.

## How it Works
Message Guard utilizes iOS's Message Filter Extension feature to filter messages from unknown senders. It checks incoming messages for signs of phishing, malware, and other spammy characteristics and sends them to the junk folder if they match.

Message Guard uses on-device filtering to determine if a message is malicious, so your data never leaves your device.

## How to Install Message Guard
Message Guard is not yet in the iOS App Store, so you'll need to install it form source if you want to try it out.

The general steps to do so would be:

1. Install Xcode
2. Download the Message Guard repository
3. Open the `src/` direcotry in Xcode
4. Plug in your iOS device and install the necessary runtimes
5. Push the app to your device

## Privacy
Message Guard takes your privacy seriously. No data is collected by Message Guard at any point, and no connections are ever made to any remote servers.