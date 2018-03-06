//
//  InterfaceController.h
//  wRB WatchKit Extension
//
//  Created by Matt Clarke on 17/02/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "RTBRuntime.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController : WKInterfaceController

// UI
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *currentImageLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *progressLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *startButton;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *transferLabel;

// dyld_shared_cache fun
- (IBAction)startDumpingFrameworks:(id)sender;

@property (strong, nonatomic) NSArray *publicFrameworks;
@property (strong, nonatomic) NSArray *privateFrameworks;
@property (strong, nonatomic) NSArray *bundleFrameworks;
@property (strong, nonatomic) NSMutableArray *queuedFrameworks;
@property (strong, nonatomic) RTBRuntime *allClasses;
@property (nonatomic, readwrite) int countOfDumped;

@end
