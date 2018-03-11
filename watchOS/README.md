## watchOS Runtime Browser

This project allows for dumping the Objective-C headers of all frameworks and libraries contained on a given version of watchOS.

The general approach is to:
- Individually load frameworks on the watch, and unload after dumping each's classes.
- Dump any new classes each to a string representing the final header file
- Transfer strings via WatchConnectivity to the companion iOS app
- Write each string to their appropriate header file in the iOS app's Documents directory.
- Run a webserver from the companion iOS app to subsequently access stored headers

It's not the most efficient, but, it works!

### Usage

The process of dumping headers on the watch can take up to 20 minutes.

To run this yourself:
1. Compile and install the iOS application target to your iPhone.
2. Change your Apple Watch's display timeout to maximum, and place it on your charger.
3. Start the iOS companion app, then the watchOS app.
4. Tap "Dump Dyld" on the Apple Watch to begin dumping.

The webserver should be running on port 10000 of your iPhone.

Please note that this is not reliable when the Apple Watch goes to sleep. This is since the current release runs the dumping code in the `WKInterfaceController` of the main application UI. A future release will correct this; for now, keep the display active manually.

NOTE: The current release of wRB does not have the webserver functional - resultant headers were obtained via SSH to a jailbroken iPhone.

### License

Licensed under the GPLv2.
