//
//  AppDelegate.m
//  wRB iOS App
//
//  Created by Matt Clarke on 17/02/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "AppDelegate.h"
#import "RTBMyIP.h"

#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//////////////////////////////////////////////////////////////////////////////
// Web server
//////////////////////////////////////////////////////////////////////////////

/*- (NSString *)myIPAddress {
    NSString *myIP = [[[RTBMyIP sharedInstance] ipsForInterfaces] objectForKey:@"en0"];
    
#if TARGET_IPHONE_SIMULATOR
    if(!myIP) {
        myIP = [[[RTBMyIP sharedInstance] ipsForInterfaces] objectForKey:@"en1"];
    }
#endif
    
    return myIP;
}

- (void)stopWebServer {
    [_webServer stop];
}

- (void)startWebServer {
    NSDictionary *ips = [[RTBMyIP sharedInstance] ipsForInterfaces];
    BOOL isConnectedThroughWifi = [ips objectForKey:@"en0"] != nil;
    
    if(isConnectedThroughWifi || TARGET_IPHONE_SIMULATOR) {
        
        [GCDWebServer setLogLevel:2];
        
        self.webServer = [[GCDWebServer alloc] init];
        
        __weak typeof(self) weakSelf = self;
        
        [_webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                      
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      if(strongSelf == nil) return nil;
                                      
                                      //NSLog(@"-- %@ %@", request.method, request.path);
                                      
                                      return [strongSelf responseForPath:request.path];
                                      
                                  }];
        
        BOOL success = [_webServer startWithPort:10000 bonjourName:@"RuntimeBrowser"];
        
        if(success == NO) {
            NSLog(@"Error starting HTTP Server.");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error starting HTTP Server"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self.webServer stop];
            self.webServer = nil;
        } else {
            NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
            [UIApplication sharedApplication].idleTimerDisabled = YES; // prevent sleep
        }
    } else {
        // TODO: allow USB connection..
        NSLog(@"Not connected through wifi, don't start web server.");
    }
}

- (NSString *)htmlHeader {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"header" ofType:@"html"];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)htmlFooter {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"footer" ofType:@"html"];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)htmlPageWithContents:(NSString *)contents title:(NSString *)title {
    NSString *header = [[[self htmlHeader] mutableCopy] stringByReplacingOccurrencesOfString:@"__TITLE__" withString:title];
    return [@[header, contents, [self htmlFooter]] componentsJoinedByString:@"\n"];
}*/



/*- (GCDWebServerDataResponse *)responseForProtocolHeaderPath:(NSString *)headerPath {
    NSString *fileName = [headerPath lastPathComponent];
    NSString *protocolName = [fileName stringByDeletingPathExtension];
    
    RTBProtocol *p = [RTBProtocol protocolStubWithProtocolName:protocolName];
    NSString *header = [RTBRuntimeHeader headerForProtocol:p];
    
    return [GCDWebServerDataResponse responseWithText:header];
}*/

/*- (GCDWebServerDataResponse *)responseForTreeWithFrameworksName:(NSString *)name directory:(NSString *)dir {
    
    if([[name pathExtension] isEqualToString:@"framework"] == NO) return nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    
    basePath = [basePath stringByAppendingString:[NSString stringWithFormat:@"/dyld%@/",name]];
    
    NSArray *classes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
    
    NSMutableString *ms = [NSMutableString string];
    [ms appendFormat:@"%@\n%@ classes\n\n", name, @([classes count])];
    
    NSArray *sortedDylibs = [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
        return [s1 compare:s2];
    }];
    
    for(NSString *s in sortedDylibs) {
        [ms appendFormat:@"<A HREF=\"/tree%@/%@\">%@</A>\n", name, s, s];
    }
    
    NSString *html = [self htmlPageWithContents:ms title:[name lastPathComponent]];
    
    return [GCDWebServerDataResponse responseWithHTML:html];
}

- (GCDWebServerResponse *)responseForTreeWithDylibWithName:(NSString *)name {
    
    if([[name pathExtension] isEqualToString:@"dylib"] == NO) return nil;
    
    NSDictionary *allClassesByImagesPath = [[RTBRuntime sharedInstance] allClassStubsByImagePath];
    __block NSArray *classes = nil;
    
    [allClassesByImagesPath enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL isDylib = [[key pathExtension] isEqualToString:@"dylib"];
        if([key rangeOfString:name].location != NSNotFound || (isDylib && [[key lastPathComponent] isEqualToString:[name lastPathComponent]])) {
            classes = obj;
            *stop = YES;
        }
    }];
    
    NSMutableString *ms = [NSMutableString string];
    [ms appendFormat:@"%@\n%@ dylibs\n\n", name, @([classes count])];
    
    NSArray *sortedDylibs = [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
        return [s1 compare:s2];
    }];
    
    for(NSString *s in sortedDylibs) {
        [ms appendFormat:@"<A HREF=\"/tree%@/%@.h\">%@.h</A>\n", name, s, s];
    }
    
    NSString *html = [self htmlPageWithContents:ms title:[name lastPathComponent]];
    
    return [GCDWebServerDataResponse responseWithHTML:html];
}

- (GCDWebServerResponse *)responseForTreeWithPath:(NSString *)path {
    
    GCDWebServerResponse *response = [self responseForTreeWithFrameworksName:path directory:@"/System/Library/"];
    if(response) return response;
    
    response = [self responseForTreeWithDylibWithName:path];
    if(response) return response;
    
    if([path isEqualToString:@"/"]) {
        
        NSString *s = @"<a href=\"/tree/Frameworks/\">/Frameworks/</a>\n"
        "<a href=\"/tree/PrivateFrameworks/\">/PrivateFrameworks/</a>\n"
        "<a href=\"/tree/lib/\">/lib/</a>\n"
        "<a href=\"/tree/protocols/\">/protocols/</a>\n";
        
        NSString *html = [self htmlPageWithContents:s title:@"iOS Runtime Browser - Tree View"];
        
        return [GCDWebServerDataResponse responseWithHTML:html];
    }
    
    NSMutableString *ms = [NSMutableString string];
    
    if([@[@"/Frameworks/", @"/PrivateFrameworks/"] containsObject:path]) {
        
        NSDictionary *classStubsByImagePath = [[RTBRuntime sharedInstance] allClassStubsByImagePath];
        
        NSMutableArray *files = [NSMutableArray array];
        [classStubsByImagePath enumerateKeysAndObjectsUsingBlock:^(NSString *imagePath, RTBClass *classStub, BOOL *stop) {
            
            NSString *prefix = [NSString stringWithFormat:@"/System/Library%@", path];
            if([imagePath hasPrefix:prefix] == NO) {
                return;
            }
            
            if([[imagePath pathExtension] isEqualToString:@"dylib"]) {
                // eg. /System/Library/Frameworks/AVFoundation.framework/libAVFAudio.dylib
                return;
            }
            
            NSArray *pathComponents = [imagePath pathComponents];
            if([pathComponents count] < 2) return;
            NSString *frameworkName = [pathComponents objectAtIndex:[pathComponents count]-2];
            if([[frameworkName pathExtension] isEqualToString:@"framework"] == NO) return;
            
            [files addObject:frameworkName];
        }];
        [files sortUsingSelector:@selector(compare:)];
        
        [ms appendFormat:@"%@\n%@ frameworks loaded\n\n", path, @([files count])];
        
        for(NSString *fileName in files) {
            [ms appendFormat:@"<a href=\"/tree%@%@\">%@/</a>\n", path, fileName, fileName];
        }
        
    } else if([path isEqualToString:@"/lib/"]) {
        
        NSDictionary *classStubsByImagePath = [[RTBRuntime sharedInstance] allClassStubsByImagePath];
        
        NSMutableArray *files = [NSMutableArray array];
        [classStubsByImagePath enumerateKeysAndObjectsUsingBlock:^(NSString *imagePath, RTBClass *classStub, BOOL *stop) {
            if([[imagePath pathExtension] isEqualToString:@"dylib"] == NO) return;
            [files addObject:[imagePath lastPathComponent]];
        }];
        [files sortUsingSelector:@selector(compare:)];
        
        [ms appendFormat:@"%@\n%@ dylibs\n\n", path, @([files count])];
        
        for(NSString *fileName in files) {
            [ms appendFormat:@"<a href=\"/tree%@%@\">%@/</a>\n", path, fileName, fileName];
        }
    } else if([path isEqualToString:@"/protocols/"]) {
        
        NSMutableArray *sortedProtocolStubs = [[[RTBRuntime sharedInstance] sortedProtocolStubs] mutableCopy];
        
        NSMutableArray *files = [NSMutableArray array];
        [sortedProtocolStubs enumerateObjectsUsingBlock:^(RTBProtocol *p, NSUInteger idx, BOOL *stop) {
            [files addObject:[p protocolName]];
        }];
        
        [ms appendFormat:@"%@\n%@ protocols\n\n", path, @([files count])];
        
        for(NSString *fileName in files) {
            [ms appendFormat:@"<a href=\"/tree%@%@.h\">%@.h</a>\n", path, fileName, fileName];
        }
    }
    NSString *html = [self htmlPageWithContents:ms title:@"iOS Runtime Browser - Tree View"];
    
    return [GCDWebServerDataResponse responseWithHTML:html];
}

- (GCDWebServerResponse *)responseForPath:(NSString *)path {
    
    BOOL isProtocol = [path hasPrefix:@"/protocols/"] || [path hasPrefix:@"/tree/protocols/"];
    BOOL isHeaderFile = [path hasSuffix:@".h"];
    
    if(isHeaderFile) {
        //if(isProtocol) {
        //    return [self responseForProtocolHeaderPath:path];
        //} else {
            return [self responseForClassHeaderPath:path];
        //}
    }
    
    if([path hasPrefix:@"/classes"]) {
        return [self responseForList];
    } else if ([path hasPrefix:@"/tree"]) {
        NSString *subPath = [path substringFromIndex:[@"/tree" length]];
        return [self responseForTreeWithPath:subPath];
    } else if ([path isEqualToString:@"/"]) {
        NSString *s = [NSString stringWithFormat:
                       @" You can browse the loaded <a href=\"/classes/\">classes</a>, or browse everything presented in <a href=\"/tree/\">tree</a>.\n\n"
                       " To retrieve the headers as on <a href=\"https://github.com/nst/iOS-Runtime-Headers\">https://github.com/nst/iOS-Runtime-Headers</a>:\n\n"
                       "     1. iOS OCRuntime > Frameworks tab > Load All\n"
                       "     2. $ wget -r http://%@:10000/tree/\n", [self myIPAddress]];
        
        NSString *html = [self htmlPageWithContents:s title:@"iOS Runtime Browser"];
        
        return [GCDWebServerDataResponse responseWithHTML:html];
    }
    
    return nil;
}*/

@end
