//
//  ViewController.h
//  wRB iOS App
//
//  Created by Matt Clarke on 17/02/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface ViewController : UIViewController <WCSessionDelegate>

@property (strong, nonatomic) IBOutlet UILabel *outputLabel;

@end

