//
//  AppDelegate.h
//  wRB iOS App
//
//  Created by Matt Clarke on 17/02/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDWebServer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GCDWebServer *webServer;

- (GCDWebServerResponse *)responseForPath:(NSString *)path;
- (NSString *)myIPAddress;
- (UInt16)serverPort;

@end

