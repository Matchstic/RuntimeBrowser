//
//  InterfaceController.m
//  wRB WatchKit Extension
//
//  Created by Matt Clarke on 17/02/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self.currentImageLabel setText:@"Not running..."];
    [self.transferLabel setText:@""];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = (id<WCSessionDelegate>)self;
        [session activateSession];
    }
    
    NSLog(@"Starting app...");
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)startDumpingFrameworks:(id)sender {
    [self.currentImageLabel setText:@"Starting..."];
    [self.startButton setEnabled:NO];
    [self.startButton setTitle:@"Working..."];
    
    [self dumpFrameworks];
}

- (void)dumpFrameworks {
    // Setup frameworks
    self.publicFrameworks = [self frameworksAtPath:@"/System/Library/Frameworks"];
    self.privateFrameworks = [self frameworksAtPath:@"/System/Library/PrivateFrameworks"];
    self.allClasses = [RTBRuntime sharedInstance];
    self.bundleFrameworks = [self loadedBundleFrameworks];
    
    self.queuedFrameworks = [[self.publicFrameworks arrayByAddingObjectsFromArray:self.privateFrameworks] mutableCopy];
    [self.queuedFrameworks addObjectsFromArray:self.bundleFrameworks];
    
    __weak typeof(self) weakSelf = self;
    
    NSBundle *nextFramework = [self.queuedFrameworks firstObject];
    [weakSelf.queuedFrameworks removeObjectAtIndex:0];
    
    [self _dumpFramework:nextFramework weakSelf:weakSelf bundleCount:0 bundleTotal:self.queuedFrameworks.count];
}

- (void)_dumpFramework:(NSBundle*)framework weakSelf:(InterfaceController*)weakSelf bundleCount:(int)count bundleTotal:(int)total {
    int __block _count = count;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        float percent = (float)_count++ / (float)total;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateLoadingProgressTo:percent];
            [weakSelf updateCurrentImageLabelTo:[[framework bundlePath] lastPathComponent]];
            [weakSelf updateTransferringTextWithPercent:0.0];
        });
        
        @try {
            //NSLog(@"-- %@", b);
            NSError *loadError = nil;
            
            BOOL success = [framework loadAndReturnError:&loadError];
            if(success == NO) {
                //NSLog(@"-- couln't load %@", b);
                NSLog(@"-- [ERROR] %@", [loadError localizedDescription]);
            }
            
            // Now, load up the new classes.
            [weakSelf.allClasses readAllRuntimeClasses];
            
            // For these new classes, send across to iOS companion.
            [weakSelf transferClassHeadersToiOSCompanion:[weakSelf.allClasses.allClassStubsByImagePath objectForKey:[framework executablePath]] forImage:[framework bundlePath]];
            
            // Unload new classes
            [weakSelf.allClasses removeImageClasses:[framework bundlePath]];
            [framework unload];
            
        } @catch (NSException * e) {
            NSLog(@"-- exception while loading bundle %@", framework);
        }
        
        // Continue onwards!
        if (weakSelf.queuedFrameworks.count > 0) {
            NSBundle *nextFramework = [weakSelf.queuedFrameworks firstObject];
            [weakSelf.queuedFrameworks removeObjectAtIndex:0];
        
            // Recurse around again...
            [weakSelf _dumpFramework:nextFramework weakSelf:weakSelf bundleCount:_count++ bundleTotal:total];
        } else {
            // Done!
            [weakSelf updateLoadingProgressTo:1.0];
        }
    });
}

- (void)updateLoadingProgressTo:(CGFloat)percent {
    [self.progressLabel setText:[NSString stringWithFormat:@"%d%% loaded", (int)(percent*100.0)]];
}

- (void)updateCurrentImageLabelTo:(NSString*)text {
    [self.currentImageLabel setText:text];
}

- (void)updateTransferringTextWithPercent:(CGFloat)percent {
    [self.transferLabel setText:[NSString stringWithFormat:@"%d%% transferred", (int)(percent*100.0)]];
}


///////////////////////////////////////////////////////////////////////////////////////////
// The fun stuff
///////////////////////////////////////////////////////////////////////////////////////////

- (NSArray *)frameworksAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:@[] options:0 errorHandler:^BOOL(NSURL *url, NSError *error) {
        NSLog(@"Error for framework at URL %@ -- %@", url, error);
        return YES;
    }];
    
    NSMutableArray *frameworks = [NSMutableArray array];
    for( NSURL *fileURL in directoryEnumerator ) {
        if ( [fileURL.absoluteString.pathExtension isEqualToString:@"framework"] ) {
            [frameworks addObject:fileURL.relativePath];
        }
    }
    
    NSMutableArray *bundles = [NSMutableArray array];
    for( NSString *frameworkPath in frameworks ) {
        NSBundle *bundle = [NSBundle bundleWithPath:frameworkPath];
        if( bundle ) {
            [bundles addObject:bundle];
        }
    }
    
    return bundles;
}

- (NSArray *)loadedBundleFrameworks {
    NSArray *bundles = [NSBundle allFrameworks];
    NSMutableArray *a = [NSMutableArray array];
    for(NSBundle *b in bundles) {
        if([b isLoaded]) {
            [a addObject:b];
        }
    }
    return a;
}

- (BOOL)transferClassHeadersToiOSCompanion:(NSArray*)classStubs forImage:(NSString*)imagePath {
    int total = [classStubs count];
    for (RTBClass *classStub in classStubs) {
        int current = [classStubs indexOfObject:classStub];
        float percent = (float)current / (float)total;
        [self updateTransferringTextWithPercent:percent];
        
        NSString *header = [classStub getHeader];
        NSString *classname = [classStub classObjectName];
        NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[header, classname, imagePath] forKeys:@[@"header", @"classname", @"imagePath"]];
        
        [[WCSession defaultSession] sendMessage:applicationData
                                   replyHandler:^(NSDictionary *reply) {
                                       //handle reply from iPhone app here
                                   }
                                   errorHandler:^(NSError *error) {
                                       //catch any errors here
                                   }
         ];
    }
    
    [self updateTransferringTextWithPercent:1.0];
    
    return YES;
}

@end



