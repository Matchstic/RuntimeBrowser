//
//  ViewController.m
//  wRB iOS App
//
//  Created by Matt Clarke on 17/02/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    NSString *header = [message objectForKey:@"header"];
    NSString *classname = [message objectForKey:@"classname"];
    NSString *imagePath = [message objectForKey:@"imagePath"];
    
    [self writeHeader:header withImagePath:imagePath andClassName:classname];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.outputLabel.text = [NSString stringWithFormat:@"Got header for class:\n%@\nfrom:\n%@", classname, imagePath];
    });
}

- (BOOL)writeHeader:(NSString*)header withImagePath:(NSString*)imagePath andClassName:(NSString*)className {
    // We write into /<documents_dir>/<imagePath>/<classname>.h
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    
    basePath = [basePath stringByAppendingString:[NSString stringWithFormat:@"/dyld%@/", imagePath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                        error:nil];
    
    NSError *error;
    NSString *headerFile = [basePath stringByAppendingFormat:@"%@.h", className];
    [header writeToFile:headerFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    return error != nil;
}

- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    // nop
}


- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {
    // nop
}


- (void)sessionDidDeactivate:(nonnull WCSession *)session {
    // nop
}


@end
